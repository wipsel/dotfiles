# CLAUDE.md — user-level house rules

Global defaults for how Claude works across all of the user's repos. Repo-specific rules
live in each project's own CLAUDE.md and take precedence.
Fuller rationale and more preferences live in memory (see MEMORY.md).

## How to work

- **Plan first.** Gather context and propose a plan or findings before changing code; build
  once the user gives the go-ahead. Approval for one step is not a standing license.
- **Defend choices.** Justify design decisions, name the alternatives and trade-offs, and
  flag code smells. Be a thinking partner, not an autocomplete — disagreeing is welcome.
- **Stay in scope.** One branch = one concern. Small boy-scout cleanups in code you're
  already touching are fine; don't let them creep into unrelated files or broader refactors.

## Code

- **Sparse comments.** Prefer self-explanatory code; comment only when something unexpected
  is done, and explain _why_, not _how_. Never let conversation context or self-corrections
  leak into comments, commit messages, or issue descriptions ("prompt leaking").
- **Reuse before building.** Extend existing components/patterns/props/styles rather than
  adding parallel ones; introduce something new only when nothing fits, and say why.
- **Name for meaning.** Full words, no shorthands; reuse the codebase's established Dutch
  domain vocabulary.
- **Prefer latest stable** dependency and tool versions; don't silently downgrade or pin old.
- **Python:** don't default to `_`-prefixing; reserve it for specific class internals.

## Environment / tooling

- **Forge: `glab`, not `gh`**, authed as `wisse` on
  `gitlab.advancedclimate.nl`. Trackers: `-R climatics/tracker`, `-R smartbase/tracker`.
  Run `glab api` from inside the relevant repo — it picks the host from the remote.
- **pyright** is a global binary via `~/.claude/bin` (ordered ahead of the pyenv shims).
  Do NOT reinstall it into a pyenv env or otherwise reintroduce the shim — that breaks it in
  repos whose `.python-version` pyenv can't resolve (e.g. climatics' 3.14).
- Use each repo's own task runner (make targets, etc.) for build/test/lint rather than
  invoking the underlying tools directly.
