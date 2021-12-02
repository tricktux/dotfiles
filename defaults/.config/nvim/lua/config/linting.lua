local utl = require('utils.utils')

-- @brief Sets options and variables for Neomake and Neomake! commands
-- @param filetype expects string: cpp or cs. Uses value to find correct 
-- project name
-- @param vs_version expects string: vs2017 or vs2015. Uses value to find 
-- correct msbuild.exe
-- @return Nada
local function set_neomake_msbuild_compiler(filetype, vs_version)
  vim.validate {filetype = {filetype, 's'}}
  vim.validate {vs_version = {vs_version, 's'}}

  -- Find first msbuild.exe
  local msbuild = "msbuild.bat"
  -- if vs_version == "vs2017" then
  -- msbuild = [[C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe]]
  -- else
  -- -- All other options default to vs2015
  -- msbuild = [[C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe]]
  -- end

  if not utl.isfile(msbuild) then return end

  vim.cmd [[compiler msbuild]]
  vim.bo.makeprg = 'msbuild'
  vim.bo.errorformat = [[%f(%l,%c): %t%*[^ ] CS%n: %m]]

  -- vim.b['neomake_' .. filetype .. '_enabled_makers'] = {'msbuild'}
  -- vim.b['neomake_' .. filetype .. '_msbuild_errorformat'] = [[%f(%l,%c): %t%*[^ ] CS%n: %m]]
  -- return

  -- vim.api.nvim_err_writeln("Failed to find msbuild.rsp file. Please create one")
  -- local proj = filetype == 'cpp' and [[*.vcxproj]] or [[*.csproj]]
  -- local proj_file = utl.find_file(vim.fn.getcwd(), proj, [[v:val !~ '^\.\|\~$']])
  -- if proj_file == nil or proj_file == "" then
  -- vim.api.nvim_err_writeln("Failed to find " .. filetype .. " project file")
  -- return
  -- end

  -- vim.cmd[[compiler msbuild]]

  -- local exec = 'msbuild'
  -- local switches = '/nologo /v:q /maxcpucount /target:Build ' .. proj_file
  -- vim.bo.makeprg = exec .. ' ' .. switches
  -- vim.bo.errorformat = '%f(%l): %t%*[^ ] C%n: %m [%.%#]'

  -- vim.b['neomake_' .. filetype .. '_enabled_makers'] = {'msbuild'}
  -- vim.b['neomake_' .. filetype .. '_msbuild_args'] = {
  -- '/target:ClCompile',
  -- '/nologo',
  -- '/verbosity:quiet',
  -- '/property:SelectedFiles=%',
  -- proj_file
  -- }
end

-- Setup neomake anki maker
local function set_neomake_anki_maker()
  local bin = 'md2apkg'
  local maker = ':Neomake'
  if vim.fn.executable(bin) <= 0 then
    vim.api.nvim_err_writeln("linting.lua: '" .. bin .. "' is not found")
    return
  end

  if vim.fn.exists(maker) <= 0 then
    vim.api.nvim_err_writeln("linting.lua: '" .. maker .. "' is not found")
    return
  end

  -- For deck name, use the first heading of the file
  local args = {
    '-i', '%:t', '-o', '%:t:r.apkg'
  }
  vim.b.neomake_anki_maker = {
    exe = bin,
    args = args,
    ['append_file'] = 0,
    cwd = '%:p:h'
  }

  vim.b.neomake_markdown_enabled_makers = {'anki'}
end

return {
  set_neomake_msbuild_compiler = set_neomake_msbuild_compiler,
  set_neomake_anki_maker = set_neomake_anki_maker
}
