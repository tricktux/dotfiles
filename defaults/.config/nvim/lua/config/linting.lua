local utl = require('utils/utils')

-- @brief Sets options and variables for Neomake and Neomake! commands
-- @param filetype expects string: cpp or cs. Uses value to find correct 
-- project name
-- @return Nada
local function set_neomake_msbuild_compiler(filetype)
    vim.validate{filetype = {filetype, 's'}}

    local proj = filetype == 'cpp' and [[*.vcxproj$]] or [[*.csproj$]]
    local proj_file = utl.find_file(vim.fn.getcwd(), proj, [[v:val !~ '^\.\|\~$']])
    if proj_file == nil or proj_file == "" then
        vim.api.nvim_err_writeln("Failed to find " .. filetype .. " project file")
        return
    end

    vim.cmd[[compiler msbuild]]

    local exec = 'msbuild'
    local switches = '/nologo /v:q /maxcpucount /target:Build' .. proj_file
    vim.bo.makeprg = exec .. ' ' .. switches
    vim.bo.errorformat = '%f(%l): %t%*[^ ] C%n: %m [%.%#]'

    vim.b['neomake_' .. filetype .. '_enabled_makers'] = {'msbuild'}
    vim.b['neomake_' .. filetype .. '_msbuild_args'] = {
        '/target:ClCompile',
        '/nologo',
        '/verbosity:quiet',
        '/property:SelectedFiles=%',
        proj_file
    }
end

return {set_neomake_msbuild_compiler = set_neomake_msbuild_compiler}
