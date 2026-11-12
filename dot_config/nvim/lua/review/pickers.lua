-- Telescope pickers over the review: changed files, notes (comments and GitLab
-- threads) and a grep limited to the changed files. Without telescope, files
-- and notes fall back to vim.ui.select.
local util = require("review.util")

local M = {}

local function telescope()
    local ok = pcall(require, "telescope")
    if not ok then
        return nil
    end
    return {
        pickers = require("telescope.pickers"),
        finders = require("telescope.finders"),
        config = require("telescope.config").values,
        previewers = require("telescope.previewers"),
        preview_utils = require("telescope.previewers.utils"),
        actions = require("telescope.actions"),
        state = require("telescope.actions.state"),
        display = require("telescope.pickers.entry_display"),
    }
end

local function drafts_per_path(current)
    local counts = {}
    for _, comment in ipairs(current:comments()) do
        if comment.state == "draft" then
            counts[comment.path] = (counts[comment.path] or 0) + 1
        end
    end
    return counts
end

--- A one-line summary of the merge request, or nil when there is none.
function M.mr_summary(current)
    local mr = current.mr
    if not mr then
        return nil
    end
    local open = 0
    for _, thread in ipairs(mr.threads) do
        if thread.resolvable and not thread.resolved then
            open = open + 1
        end
    end
    local parts =
        { ("!%d %s%s"):format(mr.iid, mr.draft and "Draft: " or "", mr.title) }
    if mr.pipeline then
        table.insert(parts, "pipeline " .. mr.pipeline)
    end
    table.insert(parts, util.plural(open, "open thread"))
    if #mr.approved_by > 0 then
        local you = current.me and vim.tbl_contains(mr.approved_by, current.me)
        table.insert(
            parts,
            "approved by "
                .. (you and "you" or table.concat(mr.approved_by, ", "))
        )
    end
    return table.concat(parts, " · ")
end

local STATUS_GROUP =
    { A = "ReviewSignAdd", D = "ReviewSignDelete", M = "DiagnosticWarn" }

function M.files(current, on_pick)
    local files = current.files
    if #files == 0 then
        util.notify("Nothing to review: " .. current:scope_words())
        return
    end
    local drafts = drafts_per_path(current)
    local viewed = current.state.viewed
    local add, del = 0, 0
    for _, file in ipairs(files) do
        add, del = add + file.add, del + file.del
    end
    local title = ("%s · %s · +%d −%d"):format(
        current:scope_label(),
        util.plural(#files, "file"),
        add,
        del
    )
    local selected = 1
    local here = require("review.actions").current_path()
    for index, file in ipairs(files) do
        if file.path == here then
            selected = index
        end
    end
    local t = telescope()
    if not t then
        vim.ui.select(files, {
            prompt = title,
            format_item = function(file)
                return ("%s %s +%d −%d"):format(
                    file.status,
                    file.path,
                    file.add,
                    file.del
                )
            end,
        }, function(file)
            if file then
                on_pick(file.path)
            end
        end)
        return
    end
    local displayer = t.display.create({
        separator = " ",
        items = {
            { width = 1 },
            { width = 6 },
            { width = 6 },
            { width = 3 },
            { width = 1 },
            { remaining = true },
        },
    })
    t.pickers
        .new({}, {
            prompt_title = M.mr_summary(current) or "Changed files",
            results_title = title,
            default_selection_index = selected,
            finder = t.finders.new_table({
                results = files,
                entry_maker = function(file)
                    return {
                        value = file,
                        ordinal = file.path,
                        display = function()
                            local count = drafts[file.path]
                            return displayer({
                                { file.status, STATUS_GROUP[file.status] },
                                { "+" .. file.add, "ReviewSignAdd" },
                                { "−" .. file.del, "ReviewSignDelete" },
                                {
                                    count and ("✎" .. count) or "",
                                    "ReviewDraft",
                                },
                                {
                                    viewed[file.path] and "✓" or " ",
                                    "ReviewSent",
                                },
                                {
                                    file.path,
                                    viewed[file.path] and "ReviewSent" or nil,
                                },
                            })
                        end,
                    }
                end,
            }),
            sorter = t.config.generic_sorter({}),
            previewer = t.previewers.new_buffer_previewer({
                title = "Diff",
                define_preview = function(self, entry)
                    local text = entry.value.text
                    vim.api.nvim_buf_set_lines(
                        self.state.bufnr,
                        0,
                        -1,
                        false,
                        vim.split(text, "\n")
                    )
                    t.preview_utils.highlighter(self.state.bufnr, "diff")
                end,
            }),
            attach_mappings = function(prompt, _)
                t.actions.select_default:replace(function()
                    local entry = t.state.get_selected_entry()
                    t.actions.close(prompt)
                    if entry then
                        on_pick(entry.value.path)
                    end
                end)
                return true
            end,
        })
        :find()
end

local function note_entries(current)
    local entries = {}
    for _, comment in ipairs(current:comments()) do
        if comment.state ~= "posted" then
            local range = comment.from.number == comment.to.number
                    and tostring(comment.to.number)
                or ("%d-%d"):format(comment.from.number, comment.to.number)
            table.insert(entries, {
                kind = "comment",
                item = comment,
                mark = comment.state == "draft" and "✎ draft" or "✓ sent",
                group = comment.state == "draft" and "ReviewDraft"
                    or "ReviewSent",
                where = comment.path .. ":" .. range,
                text = comment.text:gsub("\n", " "),
            })
        end
    end
    for _, thread in ipairs(current:threads()) do
        local line = thread.new_line or thread.old_line
        local where = thread.path
                and (thread.path .. (line and (":" .. line) or ""))
            or "general"
        table.insert(entries, {
            kind = "thread",
            item = thread,
            mark = thread.resolved and "✓ resolved"
                or (thread.resolvable and "● open" or "○ comment"),
            group = thread.resolved and "ReviewResolved" or "ReviewThread",
            where = where,
            text = (thread.notes[1].author .. ": " .. thread.notes[1].body):gsub(
                "\n",
                " "
            ),
        })
    end
    return entries
end

local function note_preview(entry)
    local lines = {}
    if entry.kind == "comment" then
        local comment = entry.item
        table.insert(lines, ("%s · %s"):format(entry.mark, entry.where))
        table.insert(lines, "")
        vim.list_extend(lines, comment.quote or {})
        table.insert(lines, "")
        vim.list_extend(lines, vim.split(comment.text, "\n"))
    else
        local thread = entry.item
        table.insert(
            lines,
            ("GitLab · %s · %s%s"):format(
                entry.mark,
                entry.where,
                thread.outdated and " · outdated" or ""
            )
        )
        for _, note in ipairs(thread.notes) do
            table.insert(lines, "")
            table.insert(
                lines,
                ("%s (%s):"):format(note.author, (note.at or ""):sub(1, 10))
            )
            vim.list_extend(lines, vim.split(note.body, "\n"))
        end
    end
    return lines
end

function M.notes(current, on_pick)
    local entries = note_entries(current)
    if #entries == 0 then
        util.notify("No comments or GitLab threads yet")
        return
    end
    local t = telescope()
    if not t then
        vim.ui.select(entries, {
            prompt = "Comments and threads",
            format_item = function(entry)
                return ("%s  %s  %s"):format(
                    entry.mark,
                    entry.where,
                    entry.text
                )
            end,
        }, function(entry)
            if entry then
                on_pick(entry)
            end
        end)
        return
    end
    local width = 0
    for _, entry in ipairs(entries) do
        width = math.max(width, vim.fn.strdisplaywidth(entry.where))
    end
    width = math.min(width, 40)
    local displayer = t.display.create({
        separator = "  ",
        items = { { width = 10 }, { width = width }, { remaining = true } },
    })
    t.pickers
        .new({}, {
            prompt_title = M.mr_summary(current) or "Comments",
            results_title = ("%s · %s"):format(
                util.plural(#entries, "note"),
                current:scope_label()
            ),
            finder = t.finders.new_table({
                results = entries,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        ordinal = entry.where .. " " .. entry.text,
                        display = function()
                            return displayer({
                                { entry.mark, entry.group },
                                {
                                    util.truncate_start(entry.where, width),
                                    "Directory",
                                },
                                entry.text,
                            })
                        end,
                    }
                end,
            }),
            sorter = t.config.generic_sorter({}),
            previewer = t.previewers.new_buffer_previewer({
                title = "Note",
                define_preview = function(self, entry)
                    vim.api.nvim_buf_set_lines(
                        self.state.bufnr,
                        0,
                        -1,
                        false,
                        note_preview(entry.value)
                    )
                    vim.wo[self.state.winid].wrap = true
                end,
            }),
            attach_mappings = function(prompt, _)
                t.actions.select_default:replace(function()
                    local entry = t.state.get_selected_entry()
                    t.actions.close(prompt)
                    if entry then
                        on_pick(entry.value)
                    end
                end)
                return true
            end,
        })
        :find()
end

--- Live grep over the changed files that are in the working tree.
--- `on_pick(path, line)`.
function M.grep(current, on_pick)
    local t = telescope()
    if not t then
        util.error("Grep needs telescope.nvim")
        return
    end
    local paths = {}
    for _, file in ipairs(current.files) do
        if vim.fn.filereadable(current.repo.top .. "/" .. file.path) == 1 then
            table.insert(paths, file.path)
        end
    end
    if #paths == 0 then
        util.notify("No changed files to search")
        return
    end
    require("telescope.builtin").live_grep({
        cwd = current.repo.top,
        search_dirs = paths,
        prompt_title = "Grep " .. util.plural(#paths, "changed file"),
        attach_mappings = function(prompt, _)
            t.actions.select_default:replace(function()
                local entry = t.state.get_selected_entry()
                t.actions.close(prompt)
                if entry then
                    local path = (entry.filename or ""):gsub("^%./", "")
                    local top = current.repo.top .. "/"
                    if path:sub(1, #top) == top then
                        path = path:sub(#top + 1)
                    end
                    on_pick(path, entry.lnum)
                end
            end)
            return true
        end,
    })
end

return M
