local utl = require('utils/utils')
local log = require('utils/log')
local luv = vim.loop

local report = {}

local curr_year = os.date("%Y")
local curr_week = os.date("%U")
report.base_folder = string.format([[%s\hpd]], vim.g.wiki_path)
report.name_preffix = "WeeklyReport_ReinaldoMolina_"
report.current = string.format([[%s\%s\%s%s.md]], report.base_folder,
                                curr_year, report.name_preffix, curr_week)

function report:__find_most_recent()
  -- Find latest report, search from the current year and week backwards
  local week = curr_week  -- initally start with the curr_week
  for i=curr_year,2016,-1 do
    local search_folder = self.base_folder .. '\\' .. i
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
        return potential
      end
    end
    -- If we did not find the report in the curr_year folder.
    -- Start searching from week 52
    week = 52
  end
  return nil
end

function report:edit_weekly_report()
  if vim.g.wiki_path == nil then
    local msg = "Wiki path not set"
    vim.cmd(string.format([[echohl ErrorMsg | echo '%q' | echohl None]], msg))
    return
  end

  -- Return right away if weekly was already created
  if utl.isfile(self.current) then
    vim.cmd("edit " .. self.current)
    return
  end

  -- Ensure a folder for this year exists
  local cfolder = self.base_folder .. '\\' .. curr_year
  log.debug("Report folder: ", cfolder)
  if not utl.isdir(cfolder) then
    local msg = string.format("Creating hpd folder: %q", cfolder)
    vim.cmd(string.format([[echohl WarningMsg | echo '%q' | echohl None]], msg))
    luv.fs_mkdir(cfolder, 777)
  end

  local recent = self:__find_most_recent()
  if recent == nil then
    local msg = string.format("Failed to find any previous reports: %q", self.base_folder)
    vim.cmd(string.format([[echohl ErrorMsg | echo '%q' | echohl None]], msg))
    return
  end

  -- Make a copy of the last report
  luv.fs_copyfile(recent, self.current)
  vim.cmd("edit " .. self.current)
end

return report
