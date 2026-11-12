-- A repo is read in one bash run per refresh. The reads never write under .git
-- (no index refresh, lock or fsmonitor), so reviewing doesn't disturb the
-- editor, git tools or agents working in the same checkout.
local util = require("review.util")

local M = {}

local GIT =
    "git --no-optional-locks -c core.fsmonitor=false -c diff.autoRefreshIndex=false -c core.quotePath=false"
local GIT_ARGS = {
    "git",
    "--no-optional-locks",
    "-c",
    "core.fsmonitor=false",
    "-c",
    "diff.autoRefreshIndex=false",
    "-c",
    "core.quotePath=false",
}
local DIFF = "--no-color --no-ext-diff --no-renames"
M.EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
local MAX_DIFF = 6000000
local MAX_UNTRACKED_BYTES = 1500000
-- Enough context lines that a file's diff is the whole file.
local WHOLE_FILE = 10000000

-- The working tree as a tree object, untracked files included (large ones left
-- out), built in a throwaway index so the real one is never touched. Prints the
-- tree's hash.
local WORKTREE_TREE = ([[
worktree_tree() {
  tmp=$(mktemp) || return 1
  cp "$gitdir/index" "$tmp" 2>/dev/null || rm -f "$tmp"
  (
    export GIT_INDEX_FILE="$tmp"
    $G add -u >/dev/null 2>&1
    $G ls-files -o --exclude-standard -z | while IFS= read -r -d '' f; do
      [ -f "$f" ] && [ "$(wc -c < "$f")" -le @MAX_UNTRACKED@ ] && printf '%s\0' "$f"
    done | $G add --pathspec-from-file=- --pathspec-file-nul >/dev/null 2>&1
    $G write-tree
  )
  status=$?
  rm -f "$tmp"
  return $status
}]]):gsub("@MAX_UNTRACKED@", tostring(MAX_UNTRACKED_BYTES))

local READ_SCRIPT = ([[
G="@GIT@"
scope="$1"; base="$2"; commit="$3"
top=$($G rev-parse --show-toplevel 2>/dev/null) || { printf '@@REVIEW error\nNot a git repository\n'; exit 0; }
cd "$top" || exit 1
gitdir=$($G rev-parse --absolute-git-dir)
branch=$($G symbolic-ref --short -q HEAD || true)
head=$($G rev-parse -q --verify HEAD || true)
origin=$($G remote get-url origin 2>/dev/null || true)
if [ -n "$base" ] && ! $G rev-parse -q --verify "$base^{commit}" >/dev/null; then base=""; fi
if [ -z "$base" ]; then
  for ref in $($G symbolic-ref -q --short refs/remotes/origin/HEAD) origin/develop develop origin/main main origin/master master; do
    if $G rev-parse -q --verify "$ref^{commit}" >/dev/null; then base=$ref; break; fi
  done
fi
mergebase=""
[ -n "$base" ] && [ -n "$head" ] && mergebase=$($G merge-base "$base" HEAD 2>/dev/null || true)
refname=$branch; [ -z "$refname" ] && refname=detached
snapshot=$($G rev-parse -q --verify "refs/review/sent/$refname" 2>/dev/null || true)
@WORKTREE_TREE@
tree=""
[ "$scope" = since ] && tree=$(worktree_tree)
printf '@@REVIEW meta\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' "$top" "$gitdir" "$branch" "$head" "$origin" "$base" "$mergebase" "$snapshot" "$tree"
printf '@@REVIEW dirty\n'
$G status --porcelain=v1 -z --no-renames --untracked-files=all | tr '\0' '\n' | cut -c4-
printf '@@REVIEW untracked\n'
$G ls-files -o --exclude-standard
printf '@@REVIEW commits\n'
if [ -n "$mergebase" ] && [ "$mergebase" != "$head" ]; then range="$mergebase..HEAD"; else range="-n 30 HEAD"; fi
[ -n "$head" ] && $G log --format='%H%x1f%h%x1f%cr%x1f%s' -n 200 $range 2>/dev/null
printf '@@REVIEW branches\n'
$G for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null | grep -v '/HEAD$' | head -n 200
printf '@@REVIEW diff\n'
case "$scope" in
  commit)
    if $G rev-parse -q --verify "$commit^" >/dev/null; then $G diff @DIFF@ "$commit^" "$commit"
    else $G diff @DIFF@ @EMPTY@ "$commit"; fi ;;
  since)
    from=$snapshot; [ -z "$from" ] && from=$head; [ -z "$from" ] && from=@EMPTY@
    [ -n "$tree" ] && $G diff @DIFF@ "$from" "$tree" ;;
  *)
    if [ "$scope" = branch ] && [ -n "$mergebase" ]; then from=$mergebase; else from=$head; fi
    [ -z "$from" ] && from=@EMPTY@
    $G diff @DIFF@ "$from"
    $G ls-files -o --exclude-standard -z | head -z -n 300 | while IFS= read -r -d '' f; do
      [ -f "$f" ] && [ "$(wc -c < "$f")" -le @MAX_UNTRACKED@ ] && $G diff @DIFF@ --no-index -- /dev/null "$f"
    done ;;
esac | head -c @MAX_DIFF@
]])
    :gsub("@WORKTREE_TREE@", function()
        return WORKTREE_TREE
    end)
    :gsub("@GIT@", GIT)
    :gsub("@DIFF@", DIFF)
    :gsub("@EMPTY@", M.EMPTY_TREE)
    :gsub("@MAX_UNTRACKED@", tostring(MAX_UNTRACKED_BYTES))
    :gsub("@MAX_DIFF@", tostring(MAX_DIFF))

local function lines_of(text)
    return vim.split(text or "", "\n", { trimempty = true })
end

local function parse_sections(text)
    local sections, found = {}, {}
    local position = 1
    while true do
        local start, finish, name = text:find("@@REVIEW (%w+)\n", position)
        if not start then
            break
        end
        if start == 1 or text:sub(start - 1, start - 1) == "\n" then
            table.insert(found, { name = name, at = start, body = finish + 1 })
            if name == "diff" then
                break
            end
        end
        position = finish + 1
    end
    for index, section in ipairs(found) do
        local next_section = found[index + 1]
        sections[section.name] = text:sub(
            section.body,
            next_section and next_section.at - 1 or #text
        )
    end
    if sections.error then
        return { error = vim.trim(sections.error) }
    end
    local meta = vim.split(sections.meta or "", "\n", { plain = true })
    local function set_of(section)
        local set = {}
        for _, path in ipairs(lines_of(section)) do
            set[path] = true
        end
        return set
    end
    local commits = {}
    for _, line in ipairs(lines_of(sections.commits)) do
        local sha, short, ago, subject =
            unpack(vim.split(line, "\31", { plain = true }))
        table.insert(
            commits,
            { sha = sha, short = short, ago = ago, subject = subject }
        )
    end
    local function value(index)
        return meta[index] ~= "" and meta[index] or nil
    end
    local diff = sections.diff or ""
    return {
        top = meta[1],
        gitdir = meta[2],
        branch = value(3),
        head = value(4),
        origin = value(5),
        base = value(6),
        merge_base = value(7),
        snapshot = value(8),
        tree = value(9),
        dirty = set_of(sections.dirty),
        untracked = set_of(sections.untracked),
        commits = commits,
        branches = lines_of(sections.branches),
        diff = diff,
        truncated = #diff >= MAX_DIFF,
    }
end

--- Reads the repo at `cwd` for `scope` ("branch" | "work" | "since" |
--- "commit:<sha>") against `base` (nil: automatic). Calls `on_done(repo)` or
--- `on_done(nil, error)`.
function M.read(cwd, scope, base, on_done)
    local kind, commit = scope, ""
    if scope:sub(1, 7) == "commit:" then
        kind, commit = "commit", scope:sub(8)
    end
    util.run(
        { "bash", "-c", READ_SCRIPT, "review", kind, base or "", commit },
        { cwd = cwd, timeout = 120000 },
        function(result)
            if
                result.code ~= 0
                and not result.stdout:find("@@REVIEW diff", 1, true)
            then
                on_done(nil, util.failure(result, "git failed"))
                return
            end
            local repo = parse_sections(result.stdout)
            if repo.error then
                on_done(nil, repo.error)
            else
                on_done(repo)
            end
        end
    )
end

--- The revisions a scope compares: `from`, and `to` (nil: the working tree).
function M.endpoints(repo, scope)
    if scope:sub(1, 7) == "commit:" then
        local commit = scope:sub(8)
        local parent = util.run_wait(
            { "git", "rev-parse", "-q", "--verify", commit .. "^" },
            { cwd = repo.top }
        )
        return parent.code == 0 and vim.trim(parent.stdout) or M.EMPTY_TREE,
            commit
    end
    if scope == "since" then
        return repo.snapshot or repo.head or M.EMPTY_TREE, repo.tree
    end
    if scope == "branch" and repo.merge_base then
        return repo.merge_base, nil
    end
    return repo.head or M.EMPTY_TREE, nil
end

local function file_diff_command(repo, scope, path)
    local command = vim.list_extend({}, GIT_ARGS)
    local untracked = repo.untracked[path]
        and (scope == "branch" or scope == "work")
    vim.list_extend(command, {
        "diff",
        "--no-color",
        "--no-ext-diff",
        "--no-renames",
        "-U" .. WHOLE_FILE,
    })
    if untracked then
        vim.list_extend(command, { "--no-index", "--", "/dev/null", path })
        return command
    end
    local from, to = M.endpoints(repo, scope)
    table.insert(command, from)
    if to then
        table.insert(command, to)
    end
    vim.list_extend(command, { "--", path })
    return command
end

-- `git diff --no-index` exits 1 when the files differ.
local function diff_ok(result)
    return result.code == 0 or (result.code == 1 and result.stdout ~= "")
end

--- One file's diff with the whole file as context. Calls `on_done(text)` or
--- `on_done(nil, error)`.
function M.file_diff(repo, scope, path, on_done)
    util.run(
        file_diff_command(repo, scope, path),
        { cwd = repo.top },
        function(result)
            if diff_ok(result) then
                on_done(result.stdout)
            else
                on_done(nil, util.failure(result, "git diff failed"))
            end
        end
    )
end

function M.file_diff_wait(repo, scope, path)
    local result =
        util.run_wait(file_diff_command(repo, scope, path), { cwd = repo.top })
    return diff_ok(result) and result.stdout or nil
end

--- Records the working tree as it is now under refs/review/sent/<branch>, for
--- "since last send". Calls `on_done(commit)` or `on_done(nil, error)`.
function M.snapshot(repo, on_done)
    local script = ([[
G="@GIT@"
gitdir=$($G rev-parse --absolute-git-dir) || exit 1
@WORKTREE_TREE@
tree=$(worktree_tree) || exit 1
head=$($G rev-parse -q --verify HEAD || true)
parent=""; [ -n "$head" ] && parent="-p $head"
commit=$($G commit-tree "$tree" $parent -m "review: sent to the agent") || exit 1
$G update-ref "refs/review/sent/$1" "$commit" && echo "$commit"]])
        :gsub("@WORKTREE_TREE@", function()
            return WORKTREE_TREE
        end)
        :gsub("@GIT@", GIT)
    util.run(
        { "bash", "-c", script, "review", repo.branch or "detached" },
        { cwd = repo.top },
        function(result)
            if result.code == 0 then
                on_done(vim.trim(result.stdout))
            else
                on_done(nil, util.failure(result, "snapshot failed"))
            end
        end
    )
end

return M
