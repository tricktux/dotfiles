local log = require('utils.log')

log.info('Setting lua filetypes...')
vim.filetype.add({
  extension = {
    ino = "arduino",
    pde = "arduino",
    csv = "csv",
    bat = "dosbatch",
    scp = "wings_syntax",
    set = "dosini",
    sum = "dosini",
    ini = "dosini",
    bin = "xxd",
    pdf = "xxd",
    hsr = "xxd",
  },
})
