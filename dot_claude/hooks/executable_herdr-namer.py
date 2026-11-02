#!/usr/bin/env python3
"""Names the herdr space a Claude Code session runs in, using Haiku.

A Claude Code Stop hook. It returns at once and does its work in a detached child, so
a turn never waits on it. Only the first agent of a space names it. Haiku is asked
again only when the session's folder or branch has changed since the last name (an
agent that moved from develop into a worktree). A space is left alone once someone
else has named it: a name that is neither herdr's default nor the last one set here.
"""

import fcntl
import json
import os
import subprocess
import sys
import time
from pathlib import Path

GUARD = "HERDR_NAMER"
STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "herdr-namer"
STATE_FILE = STATE_DIR / "spaces.json"
LOG_FILE = STATE_DIR / "log"
MAX_NAME = 40
SYSTEM_PROMPT = (
    "You name terminal workspaces so a developer can tell them apart at a glance. "
    "Reply with the name only: 2 to 4 lowercase words, no quotes, no punctuation. "
    "If the branch starts with an issue number, begin with that number. "
    "Never include the project name, and describe the task, not the tools."
)


def run(argv, cwd=None, env=None, timeout=30):
    return subprocess.run(argv, cwd=cwd, env=env, capture_output=True, text=True, timeout=timeout)


def log(message):
    with LOG_FILE.open("a") as file:
        file.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} {message}\n")


def git(folder, *args):
    result = run(["git", "-C", folder, *args])
    return result.stdout.strip() if result.returncode == 0 else ""


def default_name(folder):
    """What herdr calls a space nobody named: its repo, else its folder, ~ at home."""
    if not folder or os.path.realpath(folder) == os.path.realpath(Path.home()):
        return "~"
    toplevel = git(folder, "rev-parse", "--show-toplevel")
    return os.path.basename(toplevel or folder.rstrip("/"))


def project_name(folder):
    common = git(folder, "rev-parse", "--path-format=absolute", "--git-common-dir")
    if not common:
        return ""
    remote = git(os.path.dirname(common), "remote", "get-url", "origin")
    return os.path.basename(remote.removesuffix(".git")) if remote else os.path.basename(os.path.dirname(common))


def read_transcript(path):
    """The session's first typed request and Claude's latest title for it."""
    first_request, title = "", ""
    try:
        lines = Path(path).read_text().splitlines()
    except OSError:
        return first_request, title
    for line in lines:
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue
        if entry.get("type") == "ai-title":
            title = entry.get("aiTitle") or title
        elif not first_request and entry.get("type") == "user" and not entry.get("isMeta"):
            content = (entry.get("message") or {}).get("content")
            if isinstance(content, list):
                content = " ".join(part.get("text", "") for part in content if part.get("type") == "text")
            if isinstance(content, str) and content.strip() and not content.lstrip().startswith("<"):
                first_request = content.strip()
    return first_request, title


def find_space(terminal):
    """The space holding this terminal, and whether this terminal is its first agent."""
    result = run(["herdr-app", "ls"])
    if result.returncode != 0:
        return None, False
    for space in json.loads(result.stdout).get("spaces", []):
        terminals = [t for tab in space.get("tabs", []) for t in tab.get("terminals", [])]
        if any(t.get("terminal") == terminal for t in terminals):
            agents = [t.get("terminal") for t in terminals if t.get("app")]
            return space, bool(agents) and agents[0] == terminal
    return None, False


def first_terminal_folder(space):
    first = next((t.get("terminal") for tab in space.get("tabs", []) for t in tab.get("terminals", [])), None)
    result = run(["hc", "ls", "--json"])
    if not first or result.returncode != 0:
        return ""
    data = json.loads(result.stdout)
    terminals = data.get("terminals", []) if isinstance(data, dict) else data
    return next((t.get("cwd") or "" for t in terminals if t.get("address") == first), "")


def ask_haiku(project, branch, folder, title, first_request):
    prompt = "\n".join(
        [
            f"Project: {project or 'none'}",
            f"Branch: {branch or 'none'}",
            f"Folder: {folder.replace(str(Path.home()), '~')}",
            f"Session title: {title or 'none'}",
            f"First request: {first_request[:1500]}",
        ]
    )
    result = run(
        [
            "claude", "-p", "--model", "haiku", "--tools", "", "--strict-mcp-config",
            "--no-session-persistence", "--system-prompt", SYSTEM_PROMPT, prompt,
        ],
        cwd=STATE_DIR,
        env={**os.environ, GUARD: "1"},
        timeout=120,
    )
    if result.returncode != 0:
        raise RuntimeError(f"claude -p failed: {result.stderr.strip()[:300]}")
    name = result.stdout.strip().splitlines()[0] if result.stdout.strip() else ""
    name = name.strip(" \"'`.").lower()
    return name[:MAX_NAME].strip()


def name_space(payload, terminal):
    space, is_first_agent = find_space(terminal)
    if not space or not is_first_agent:
        return
    space_id = space["id"]

    with (STATE_DIR / f"{space_id}.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        state = json.loads(STATE_FILE.read_text()) if STATE_FILE.exists() else {}
        entry = state.get(space_id)
        current = space.get("name", "")
        ours = entry and current == entry.get("name")
        if not ours and current != default_name(first_terminal_folder(space)):
            return

        folder = payload.get("cwd") or ""
        branch = git(folder, "branch", "--show-current") if folder else ""
        context = f"{folder}|{branch}"
        if entry and entry.get("context") == context and ours:
            return

        first_request, title = read_transcript(payload.get("transcript_path", ""))
        if not first_request:
            return
        name = ask_haiku(project_name(folder), branch, folder, title, first_request)
        if not name:
            return

        # Someone may have renamed the space while Haiku was thinking.
        space_now, _ = find_space(terminal)
        if not space_now or space_now.get("name") != current:
            return
        result = run(["herdr-app", "do", "space.rename", json.dumps({"id": space_id, "name": name})])
        if result.returncode != 0:
            raise RuntimeError(f"space.rename failed: {result.stdout.strip()} {result.stderr.strip()}")
        state = json.loads(STATE_FILE.read_text()) if STATE_FILE.exists() else {}
        state[space_id] = {"name": name, "context": context, "at": int(time.time())}
        STATE_FILE.write_text(json.dumps(state, indent=1))
        log(f"{space_id} {current!r} -> {name!r} ({context})")


def main():
    terminal = os.environ.get("HC_TERMINAL_ID")
    if os.environ.get(GUARD) or not terminal:
        return
    payload = json.load(sys.stdin)
    if os.fork():
        return
    os.setsid()
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    devnull = os.open(os.devnull, os.O_RDWR)
    for stream in (0, 1, 2):
        os.dup2(devnull, stream)
    try:
        name_space(payload, terminal)
    except Exception as error:  # a hook must never break the session; leave a trace instead
        log(f"error: {error!r}")


if __name__ == "__main__":
    main()
