local utils = require('utils.utils')
local fn = vim.fn
local fmt = string.format

local M = {}

M.runner = {}
M.runner.runners = {
  python = 'python3',
  sh = 'bash',
  bash = 'bash',
  lua = 'lua',
  javascript = 'node',
  typescript = 'npx ts-node',
  ruby = 'ruby',
  perl = 'perl',
  c = function(file)
    local out = fn.tempname()
    return fmt('gcc %s -o %s && %s', file, out, out)
  end,
  cpp = function(file)
    local out = fn.tempname()
    return fmt('g++ %s -o %s && %s', file, out, out)
  end,
}

---Run the current file using a configured runner
---@param opts? { float?: boolean, layout?: { width: number, height: number } }
M.runner.run = function(opts)
  local ft = vim.bo.filetype
  local file = fn.expand('%:p')
  local runner = M.runner.runners[ft]

  if not runner then
    vim.notify('No runner for filetype: ' .. ft, vim.log.levels.WARN)
    return
  end

  local shell_cmd = type(runner) == 'function' and runner(file)
    or (runner .. ' ' .. fn.shellescape(file))

  if opts and opts.float then
    utils.term.float.exec('terminal ' .. shell_cmd, {
      startinsert = true,
      closeterm = false,
      layout = opts.layout or utils.term.float.opts.layout,
    })
    return
  end

  local bufnr = utils.term.last.bufnr
  local term_valid = utils.term.is_valid(utils.term.last.job_id, bufnr)

  if term_valid then
    local win = utils.buf.is_in_current_tab(bufnr)
    if win then
      -- Terminal already visible: focus and send
      vim.api.nvim_set_current_win(win)
    else
      -- Terminal exists but not visible: pull into bottom split
      vim.cmd('botright 15split')
      vim.api.nvim_win_set_buf(0, bufnr)
    end
    utils.term.send_cmd(shell_cmd)
    vim.cmd('startinsert')
    return
  end

  -- No valid terminal: open a fresh one running the command directly
  vim.cmd('botright 15split')
  vim.api.nvim_set_option_value('buflisted', false, { buf = 0 })
  fn.jobstart(shell_cmd, {
    term = true,
    on_exit = function(_, code)
      local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      vim.notify(fmt('Exited with code %d', code), level)
    end,
  })
  vim.cmd('startinsert')
end

return M
