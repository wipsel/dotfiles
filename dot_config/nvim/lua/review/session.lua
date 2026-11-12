-- One review at a time: the repo read for a scope, its changed files, the
-- branch's stored drafts and the merge request. Review buffers and decorations
-- read from here.
local diff = require("review.diff")
local drafts = require("review.drafts")
local git = require("review.git")
local gitlab = require("review.gitlab")
local util = require("review.util")

local M = {}

---@type table?
M.current = nil

-- GitLab usernames per host, asked once per Neovim.
local usernames = {}

local Session = {}
Session.__index = Session

local function new(cwd)
    return setmetatable({
        cwd = cwd,
        scope = "branch",
        repo = nil,
        files = {},
        by_path = {},
        order = {},
        details = {},
        buffers = {},
        store = nil,
        state = nil,
        mr = nil,
        mr_error = nil,
        mr_loading = false,
        loading = false,
        loaded_at = 0,
        waiting = {},
    }, Session)
end

--- The session, started for `cwd` when there is none or it's for another
--- checkout. Calls `on_ready(session)` once the repo has been read, or reports
--- why it couldn't be.
function M.ensure(cwd, on_ready)
    local session = M.current
    if
        session
        and session.repo
        and vim.startswith(cwd .. "/", session.repo.top .. "/")
    then
        on_ready(session)
        return
    end
    session = new(cwd)
    session:refresh(function(ok)
        if ok then
            if M.current and M.current ~= session then
                M.current:dispose()
            end
            M.current = session
            on_ready(session)
        end
    end)
end

function Session:dispose()
    for _, buf in pairs(self.buffers) do
        if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end
    self.buffers = {}
end

--- The base branch the scope "branch" compares against: the chosen one, else
--- the merge request's target, else nil (automatic: origin/HEAD, develop, main
--- or master).
function Session:base()
    if self.state and self.state.base then
        return self.state.base
    end
    if self.mr and self.mr.target then
        return "origin/" .. self.mr.target
    end
    return nil
end

function Session:where()
    return self.repo and self.repo.top or self.cwd
end

function Session:scope_words()
    local repo = self.repo or {}
    if self.scope == "work" then
        return "uncommitted changes"
    end
    if self.scope == "since" then
        return repo.snapshot and "what changed since the last review was sent"
            or "uncommitted changes (nothing sent yet)"
    end
    if self.scope:sub(1, 7) == "commit:" then
        local sha = self.scope:sub(8)
        for _, commit in ipairs(repo.commits or {}) do
            if commit.sha == sha then
                return ("commit %s %s"):format(commit.short, commit.subject)
            end
        end
        return "commit " .. sha:sub(1, 8)
    end
    if repo.merge_base then
        return ("branch %s against %s"):format(repo.branch or "HEAD", repo.base)
    end
    return "uncommitted changes (no base branch found)"
end

--- A short name for the scope, for titles.
function Session:scope_label()
    if self.scope == "work" then
        return "uncommitted"
    end
    if self.scope == "since" then
        return self.repo and self.repo.snapshot and "since last send"
            or "since last send (none)"
    end
    if self.scope:sub(1, 7) == "commit:" then
        return "commit " .. self.scope:sub(8, 15)
    end
    return "branch vs "
        .. (self.repo and self.repo.merge_base and self.repo.base or "?")
end

--- Reads the repo again. Calls `on_done(ok)`; refreshes asked for while one
--- runs share its result.
function Session:refresh(on_done)
    if on_done then
        table.insert(self.waiting, on_done)
    end
    if self.loading then
        self.again = true
        return
    end
    self.loading = true
    local previous = self.repo
    git.read(self.cwd, self.scope, self:base(), function(repo, err)
        self.loading = false
        if not repo then
            util.error(err)
            self:finish_refresh(false)
            return
        end
        local moved = not previous
            or previous.top ~= repo.top
            or previous.branch ~= repo.branch
        self.repo = repo
        if moved then
            self.store = drafts.load(repo.gitdir)
            self.state = self.store:of(repo.branch)
            self.mr, self.mr_error = nil, nil
            if self:base() ~= repo.base and self.state.base then
                -- The stored base wasn't known when this read started.
                self.again = true
            end
        end
        if repo.truncated then
            util.warn(
                "The diff is too large to read whole; the last files are left out"
            )
        end
        self:set_files(diff.parse(repo.diff, false))
        repo.diff = nil
        self.loaded_at = vim.uv.now()
        if self.again then
            self.again = false
            self:refresh()
            return
        end
        self:finish_refresh(true)
        if moved then
            self:load_mr()
        end
    end)
end

function Session:finish_refresh(ok)
    local waiting = self.waiting
    self.waiting = {}
    for _, callback in ipairs(waiting) do
        callback(ok)
    end
    if ok then
        vim.api.nvim_exec_autocmds("User", { pattern = "ReviewRefreshed" })
    end
end

function Session:set_files(files)
    self.files = files
    self.by_path, self.order = {}, {}
    for index, file in ipairs(files) do
        self.by_path[file.path] = file
        self.order[file.path] = index
    end
end

-- What a file's whole-file diff depends on besides its own changes.
function Session:endpoints_key()
    local repo = self.repo
    return table.concat({
        self.scope,
        repo.merge_base or "",
        repo.head or "",
        repo.snapshot or "",
        repo.tree or "",
    }, ":")
end

--- A changed file's rows with the whole file as context: { rows, binary, status
--- }, or nil when `path` isn't changed in this scope. Read when first asked for
--- and again when the diff changed.
function Session:detail(path)
    local file = self.by_path[path]
    if not file then
        return nil
    end
    local key = self:endpoints_key() .. "\0" .. file.text
    local cached = self.details[path]
    if cached and cached.key == key then
        return cached
    end
    local text = file.binary and ""
        or git.file_diff_wait(self.repo, self.scope, path)
    local parsed = text and diff.parse(text, true)[1]
    local detail = {
        key = key,
        rows = parsed and parsed.rows or {},
        binary = file.binary,
        status = file.status,
        failed = text == nil,
    }
    self.details[path] = detail
    return detail
end

function Session:comments()
    return self.state and self.state.comments or {}
end

function Session:save()
    if self.store then
        self.store:save()
    end
end

function Session:find_comment(id)
    for index, comment in ipairs(self:comments()) do
        if comment.id == id then
            return comment, index
        end
    end
end

function Session:threads()
    return self.mr and self.mr.threads or {}
end

function Session:find_thread(id)
    for _, thread in ipairs(self:threads()) do
        if thread.id == id then
            return thread
        end
    end
end

function Session:included(id)
    return vim.tbl_contains(self.state and self.state.included or {}, id)
end

function Session:project()
    return self.repo and gitlab.project_of(self.repo.origin)
end

--- Loads the branch's merge request in the background, then lets the views
--- redraw.
function Session:load_mr(on_done)
    local project, branch = self:project(), self.repo and self.repo.branch
    if not project or not branch or self.mr_loading then
        if on_done then
            on_done()
        end
        return
    end
    if vim.fn.executable("glab") == 0 then
        self.mr_error = "glab is not installed here"
        if on_done then
            on_done()
        end
        return
    end
    self.mr_loading = true
    util.async(function()
        if usernames[project.host] == nil then
            usernames[project.host] = gitlab.username(project.host) or false
        end
        self.me = usernames[project.host] or nil
        local mr, err = gitlab.load_merge_request(project, branch)
        self.mr_loading = false
        if not self.repo or self.repo.branch ~= branch then
            return
        end
        if mr == nil then
            self.mr, self.mr_error = nil, err
        else
            self.mr, self.mr_error = mr or nil, nil
        end
        local retarget = self.mr
            and not self.state.base
            and self:base() ~= self.repo.base
        vim.api.nvim_exec_autocmds("User", { pattern = "ReviewMergeRequest" })
        if retarget then
            self:refresh()
        end
        if on_done then
            on_done()
        end
    end)
end

return M
