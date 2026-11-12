if vim.g.loaded_review then
    return
end
vim.g.loaded_review = true

local function action(name, ...)
    local arguments = { ... }
    return function()
        require("review.actions")[name](unpack(arguments))
    end
end

local subcommands = {
    open = action("open"),
    close = action("close"),
    files = action("files"),
    comments = action("notes"),
    grep = action("grep"),
    send = action("send"),
    post = action("post"),
    scope = action("scope"),
    base = action("base"),
    refresh = action("refresh"),
    viewed = action("toggle_viewed"),
    mr = action("mr_summary"),
    approve = action("approve"),
    help = action("help"),
}

vim.api.nvim_create_user_command("Review", function(command)
    local name = command.fargs[1] or "open"
    local run = subcommands[name]
    if not run then
        vim.notify("Review: unknown subcommand " .. name, vim.log.levels.ERROR)
        return
    end
    run()
end, {
    nargs = "?",
    desc = "Review the branch's changes",
    complete = function(lead)
        return vim.tbl_filter(function(name)
            return vim.startswith(name, lead)
        end, vim.tbl_keys(subcommands))
    end,
})

local function map(modes, lhs, fn, desc)
    vim.keymap.set(modes, lhs, fn, { silent = true, desc = "Review: " .. desc })
end

map("n", "<leader>rc", action("comment", false), "comment on this line")
map("x", "<leader>rc", action("comment", true), "comment on these lines")
map("n", "<leader>re", action("edit"), "edit comment")
map("n", "<leader>rd", action("delete"), "delete comment")
map("n", "<leader>ru", action("undo_delete"), "bring the deleted comment back")
map("n", "<leader>rz", action("expand"), "show note whole")
map("n", "<leader>rs", action("send"), "send drafts to the agent")
map("n", "<leader>ra", action("ask", false), "ask the agent about this change")
map("x", "<leader>ra", action("ask", true), "ask the agent about these lines")
map("n", "<leader>rf", action("files"), "changed files")
map("n", "<leader>rl", action("notes"), "comments and threads")
map("n", "<leader>r/", action("grep"), "grep changed files")
map("n", "<leader>rv", action("toggle_viewed"), "toggle file viewed")
map("n", "<leader>rw", action("scope"), "what to review")
map("n", "<leader>rb", action("base"), "base branch")
map("n", "<leader>rr", action("refresh"), "refresh")
map("n", "<leader>rm", action("mr_summary"), "merge request summary")
map("n", "<leader>rt", action("reply"), "reply to thread")
map("n", "<leader>rx", action("resolve"), "resolve or reopen thread")
map("n", "<leader>ri", action("include"), "add thread to next review")
map(
    "n",
    "<leader>rI",
    action("include_all"),
    "add unresolved threads to next review"
)
map("n", "<leader>rp", action("post"), "post drafts to GitLab")
map("n", "<leader>rA", action("approve"), "approve merge request")
map("n", "<leader>ro", action("open_mr"), "open merge request in browser")
map("n", "<leader>rq", action("close"), "close review")
map("n", "<leader>r?", action("help"), "keys")
