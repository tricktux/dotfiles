local utl = require('utils/utils')
local log = require('utils/log')
local luv = vim.loop

local report = {}

local curr_year = os.date("%Y")
local curr_week = os.date("%U")
report.name_preffix = "WeeklyReport_ReinaldoMolina_"
report.full_path = string.format([[%s\hpd\%s\%s%s.md]], vim.g.wiki_path,
                                        curr_year, report.name_preffix, curr_week)
report.folder = string.format([[%s\hpd\%s]], vim.g.wiki_path, curr_year)
report.file_name = string.format([[%s%s.md]], report.name_preffix, curr_week)

function report:__find_most_recent()
    log.debug("Report folder: ", report.folder)
    if not utl.isdir(self.folder) then
        local msg = string.format("Creating hpd folder: %q", self.folder)
        vim.cmd(string.format([[echohl WarningMsg | echo '%q' | echohl None]], msg))
        luv.fs_mkdir(self.folder, 777)
    end

    -- Find latest report, search from the current year and week backwards
    local folder = vim.g.wiki_path .. [[\hpd]]
    local week = curr_week  -- initally start with the curr_week
    for i=curr_year,2016,-1 do
        search_folder = folder .. '\\' .. i
        log.info(string.format("folder = %q, week = %q", search_folder, week))
        if not utl.isdir(search_folder) then
            log.warn("Folder does not exists: ", search_folder)
            break
        end
        for j=week,1,-1 do
            -- Create file name
            local potential = search_folder .. '\\' .. self.name_preffix .. j .. '.md'
            if utl.isfile(potential) then
                log.info("Found potential report file: " .. potential)
                if j == curr_week then
                    -- No copies necessary since report for current week exists
                    return true
                end
                -- Make a copy of the last report
                luv.fs_copyfile(potential, self.full_path)
                return true
            end
        end
        -- If we did not find the report in the curr_year folder.
        -- Start searching from week 52
        week = 52
    end
    local msg = string.format("Failed to find any previous reports: %q", self.folder)
    vim.cmd(string.format([[echohl ErrorMsg | echo '%q' | echohl None]], msg))
    return false
end

function report:edit_weekly_report()
    if vim.g.wiki_path == nil then
        local msg = "Wiki path not set"
        vim.cmd(string.format([[echohl ErrorMsg | echo '%q' | echohl None]], msg))
        return
    end

    if self:__find_most_recent() == false then
        return
    end

    vim.cmd("edit " .. self.full_path)
end

print("Year: ", curr_year)
print("Week: ", curr_week)
print("full_path: ", report.full_path)
print("file_name: ", report.file_name)
print("folder: ", report.folder)
report:edit_weekly_report()

return { report = report }
