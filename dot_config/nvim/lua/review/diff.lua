-- Unified diff text → files with numbered rows. A row: { kind = "+" | "-" | "
-- ", number, old?, text }. `number` is the new file's line for "+" and context
-- rows and the old file's for "-" rows; context rows also carry `old`.
local M = {}

local function unquote(path)
    if path:sub(1, 1) ~= '"' then
        return path
    end
    local ok, value = pcall(vim.json.decode, path)
    return ok and value or path:sub(2, -2)
end

local function strip_prefix(path)
    if path == "/dev/null" then
        return nil
    end
    return (unquote(path):gsub("^[ab]/", ""))
end

local function header_paths(line)
    local rest = line:sub(12)
    local old, new = rest:match('^"?a/(.-)"? "?b/(.-)"?$')
    if old then
        return old, new
    end
    return nil, rest
end

--- Parses diff text into files: { path, old_path, status ("A" | "D" | "M"),
--- binary, add, del, rows?, text }. Rows are built only with `with_rows`;
--- `text` is the file's part of the diff.
function M.parse(text, with_rows)
    local files, file = {}, nil
    local old, new = 0, 0
    local lines = vim.split(text, "\n", { plain = true })
    local function finish(at)
        if file then
            file.text = table.concat(lines, "\n", file.first, at - 1)
            file.first = nil
        end
    end
    for index, line in ipairs(lines) do
        local first = line:sub(1, 1)
        if line:sub(1, 11) == "diff --git " then
            finish(index)
            local old_path, path = header_paths(line)
            file = {
                path = path,
                old_path = old_path,
                status = "M",
                binary = false,
                add = 0,
                del = 0,
                rows = with_rows and {} or nil,
                in_hunks = false,
                first = index,
            }
            table.insert(files, file)
        elseif file and not file.in_hunks then
            if line:sub(1, 13) == "new file mode" then
                file.status = "A"
            elseif line:sub(1, 17) == "deleted file mode" then
                file.status = "D"
            elseif line:sub(1, 13) == "Binary files " then
                file.binary = true
            elseif line:sub(1, 4) == "--- " then
                file.old_path = strip_prefix(line:sub(5)) or file.old_path
            elseif line:sub(1, 4) == "+++ " then
                file.path = strip_prefix(line:sub(5)) or file.path
            elseif first == "@" then
                file.in_hunks = true
            end
        end
        if file and file.in_hunks then
            if first == "@" then
                local old_start, new_start =
                    line:match("^@@ %-(%d+),?%d* %+(%d+)")
                if old_start then
                    old, new = tonumber(old_start), tonumber(new_start)
                end
            elseif first == "+" then
                file.add = file.add + 1
                if with_rows then
                    table.insert(
                        file.rows,
                        { kind = "+", number = new, text = line:sub(2) }
                    )
                end
                new = new + 1
            elseif first == "-" then
                file.del = file.del + 1
                if with_rows then
                    table.insert(
                        file.rows,
                        { kind = "-", number = old, text = line:sub(2) }
                    )
                end
                old = old + 1
            elseif first == " " then
                if with_rows then
                    table.insert(file.rows, {
                        kind = " ",
                        number = new,
                        old = old,
                        text = line:sub(2),
                    })
                end
                old, new = old + 1, new + 1
            end
        end
    end
    finish(#lines + 1)
    for _, parsed in ipairs(files) do
        parsed.in_hunks = nil
        parsed.old_path = parsed.old_path or parsed.path
    end
    return files
end

local function same_side(row, anchor)
    if anchor.kind == "-" then
        return row.kind == "-"
    end
    return row.kind ~= "-"
end

--- The row a comment or thread is anchored to, found again: the same kind,
--- number and text; else the same text on the same side nearest the old number
--- (within 200 lines); else nil.
function M.find_row(rows, anchor)
    if not anchor then
        return nil
    end
    local best, distance = nil, math.huge
    for index, row in ipairs(rows) do
        if same_side(row, anchor) and row.text == anchor.text then
            if row.number == anchor.number then
                return index
            end
            local away = math.abs(row.number - anchor.number)
            if away < distance and away <= 200 then
                best, distance = index, away
            end
        end
    end
    return best
end

--- A row as the agent reads it: "   42 + text".
function M.quote_row(row)
    return ("%5d %s %s"):format(row.number, row.kind, row.text)
end

--- A row as stored in a comment: what's needed to find it again and to place it
--- on GitLab.
function M.anchor_of(row)
    return {
        kind = row.kind,
        number = row.number,
        old = row.old,
        text = row.text,
    }
end

return M
