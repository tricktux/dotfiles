local fortune = require('plugin.cowsay-fortune')

return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  cond = not vim.g.started_by_firenvim,
  opts = function()
    local headers = {
      {
        '',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣀⣠⣤⣤⣤⣤⣤⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠴⠯⠭⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣶⣿⣿⣶⣶⣶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠿⢯⣭⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢐⣛⣛⣻⣛⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣭⣭⣭⣭⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣒⣒⣒⣲⣒⣒⣒⣻⣿⣿⣿⣟⣉⣭⣭⣭⣭⣭⣭⣭⣿⣿⣿⣟⣋⣭⣭⣭⣭⣽⣧⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣛⣛⣋⣉⡩⣭⣙⠻⣿⣿⣿⣿⢟⣋⡭⢭⣭⣝⢿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣛⠛⢞⣛⣶⣾⣿⣿⣿⣿⣧⡹⣿⣿⣿⣷⣾⢟⣡⣿⣿⡟⣯⠻⣿⣷⣾⡿⢋⣾⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⡟⣩⣤⣤⡌⡏⢸⡿⠋⣠⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠶⠾⠶⠄⢿⣿⣿⣿⣿⣿⣿⣿⣷⣮⣭⣽⣭⣥⣾⣿⣿⣿⡇⣿⣷⣭⣭⣭⣵⣾⣿⣿⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⡟⢰⣿⣿⣿⠇⡅⠈⠀⠾⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣀⣦⠘⣛⣚⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢻⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣧⡈⠛⢛⣡⣼⡇⢸⣿⣶⣌⣻⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡆⢙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡜⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠰⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣷⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠨⣭⡅⣤⡬⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣇⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⣦⠙⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⠿⠟⢛⣛⣛⣛⣟⣛⣻⣻⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣟⣛⣛⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣟⣛⣛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣈⣙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠿⣿⣿⣿⣿⣿⣿⠿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠺⣿⣶⣶⣄⣈⣛⣛⣛⣛⣛⣛⣫⣭⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⢼⢿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣦⣄⡀⢀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⠁⠽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢿⣿⣿⣌⢻⣧⡀⣤⡀⢀⣀⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣐⣚⡓⠂⢻⣃⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣌⠻⣿⣿⣆⠻⠧⠹⠷⢼⣿⣿⣆⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠘⣛⣶⣶⡛⠿⠆⠐⠸⣿⡆⢈⡛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢁⣦⡌⢿⣿⣆⠀⠀⠀⠀⠈⢋⣵⣷⣶⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣬⣭⣭⣤⣬⡍⠉⠁⠀⠀⠀⠀⢻⣷⠘⣿⣶⣬⣍⣛⣛⡛⠛⠛⢛⠋⣩⣴⣿⣿⣿⣌⠻⣿⣆⠀⠀⠀⢀⣼⣿⠟⢋⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣋⣙⠛⠿⣿⣿⣿⣆⠀⠀⠀⠀⣀⣼⠟⠈⣿⣿⣿⣿⣿⣿⠃⢘⠠⡆⣡⡌⣿⣿⣿⡿⢃⣶⣮⣍⣛⣛⣛⣛⣉⣤⣾⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⠀⠀⢠⣭⣭⣵⣤⣤⣍⠹⠿⠷⠶⠒⢚⣉⣭⣦⣶⣌⠻⢿⣿⣿⣿⣄⠸⣶⣶⣿⠃⣿⠛⣡⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠀⢠⠀⣺⣿⣿⣿⣿⣿⣿⣿⣷⡟⢻⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣦⡌⠁⣴⣿⠛⣿⣿⠈⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⢀⡎⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢘⡋⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢀⡘⠿⠿⠛⢋⣴⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⡟⣻⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⠀⠼⠆⠴⠾⠿⠿⢿⣿⣿⣿⣿⣿⣿⠈⢠⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣿⣷⢐⠂⢸⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠘⣰⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⠀⣐⣛⡃⣚⣛⣛⣿⣿⣿⣿⣿⣿⣿⣿⠀⠇⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠈⣿⣿⠈⡃⢸⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣰⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '            ⠀⠀⠀⢐⣚⣒⡂⣒⣓⣶⣶⣿⣿⣿⣿⣿⣿⣏⣀⣐⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣿⣿⠐⠆⢸⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '',
      },
      {
        '',
        '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠋⠀⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠈⠉⠉⠙⠛⠛⠻⢿⣿⡿⠟⠁⠀⣀⣴⣿⣿⣿⣿⣿⠟',
        '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⣉⣡⠀⣠⣴⣶⣶⣦⠄⣀⡀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⡿⢃⣾',
        '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⣾⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⣠⣾⡟⢡⣾⣿⣿⣿⡿⢋⣴⣿⡿⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⢡⣾⣿',
        '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠃⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⣼⣿⡟⣰⣿⣿⣿⣿⠏⣰⣿⣿⠟⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢚⣛⢿',
        '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⠸⣿⠟⢰⣿⣿⣿⣿⠃⣾⣿⣿⠏⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢋⣾',
        '⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠻⠻⠃⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⢉⣴⣿⣿⣿⣿⡇⠘⣿⣿⠋⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡘⣿',
        '⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⣿⣿⣿⣿⠁⢀⣀⠀⢀⣾⣿⣿⣿⣿⣿⣿⠟⠉⠉⠉⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣤⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌',
        '⣿⣿⣿⣿⣿⣿⡿⠁⣀⣤⡀⠀⠈⠻⢿⠀⣼⣿⣷⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
        '⣿⣿⣿⠟⠛⠙⠃⠀⣿⣿⣿⠀⠀⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⡿⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⠁⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿',
        '⣿⠟⠁⢀⣴⣶⣶⣾⣿⣿⣿⣿⣶⡐⢦⣄⠀⠀⠈⠛⢿⣿⣿⣿⣿⡀⠀⠀⠀⠀⢀⣼⡿⢛⣩⣴⣶⣶⣶⣶⣶⣶⣭⣙⠻⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿',
        '⠁⠀⣴⣿⣿⣿⣿⠿⠿⣿⣿⣿⣿⣿⣦⡙⠻⣶⣄⡀⠀⠈⠙⢿⣿⣷⣦⣤⣤⣴⣿⡏⣠⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌⠻⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿',
        '⠀⢸⣿⣿⣿⠋⣠⠔⠀⠀⠻⣿⣿⣿⣿⢉⡳⢦⣉⠛⢷⣤⣀⠀⠈⠙⠿⣿⣿⣿⣿⢸⣿⡄⠻⣿⣿⠟⡈⣿⣿⣿⣿⣿⢉⣿⣧⢹⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿',
        '⠀⢸⣿⣿⡇⠠⡇⠀⠀⠀⠀⣿⣿⣿⣿⢸⣿⣷⣤⣙⠢⢌⡛⠷⣤⣄⠀⠈⠙⠿⣿⣿⣿⣿⣷⣦⣴⣾⣿⣤⣙⣛⣛⣥⣾⣿⣿⡌⣿⣿⣿⣷⣤⣀⣀⣀⣠⣴⣿⣿⣿⣿⣿⣿⣿',
        '⠀⢸⣿⣿⣷⡀⠡⠀⠀⠀⣰⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣦⣌⡓⠤⣙⣿⣦⡄⠀⠈⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢡⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
        '⠀⢸⣿⣿⣿⣿⣶⣤⣴⣾⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⣷⠀⣶⡄⠀⠈⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢃⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
        '⠀⢸⣿⣿⣿⣿⣿⠟⠻⣿⣿⡏⣉⣭⣭⡘⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣿⡇⢸⡇⢠⡀⠈⠙⠋⠉⠉⠉⠉⠛⠫⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
        '⠀⢸⣿⣿⠛⣿⣿⣀⣀⣾⡿⢀⣿⣿⣿⢻⣷⣦⢈⡙⠻⢿⣿⣿⣿⣿⣿⣿⣿⠀⣿⡇⢸⡇⢸⣿⠀⣦⠀⠀⠶⣶⣦⣀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
        '⠀⢸⣿⣿⣦⣈⡛⠿⠟⣋⣤⣾⣿⣿⣿⣸⣿⣿⢸⡇⢰⡆⢈⡙⠻⢿⣿⣿⣿⠀⢿⡇⢸⡇⢸⣿⢠⣿⡇⣿⡆⢈⡙⠻⠧⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
        '⠀⠀⣝⠛⢿⣿⣿⣿⣿⣿⣿⠟⣁⠀⠀⢈⠛⠿⢸⣇⢸⡇⢸⡇⣶⣦⣌⡙⠻⢄⡀⠁⠘⠇⠘⣿⢸⣿⡇⣿⡇⢸⡛⠷⣦⣄⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿',
        '',
      },
      {
        '            :h-                                  Nhy`               ',
        '           -mh.                           h.    `Ndho               ',
        '           hmh+                          oNm.   oNdhh               ',
        '          `Nmhd`                        /NNmd  /NNhhd               ',
        '          -NNhhy                      `hMNmmm`+NNdhhh               ',
        '          .NNmhhs              ```....`..-:/./mNdhhh+               ',
        '           mNNdhhh-     `.-::///+++////++//:--.`-/sd`               ',
        '           oNNNdhhdo..://++//++++++/+++//++///++/-.`                ',
        '      y.   `mNNNmhhhdy+/++++//+/////++//+++///++////-` `/oos:       ',
        ' .    Nmy:  :NNNNmhhhhdy+/++/+++///:.....--:////+++///:.`:s+        ',
        ' h-   dNmNmy oNNNNNdhhhhy:/+/+++/-         ---:/+++//++//.`         ',
        ' hd+` -NNNy`./dNNNNNhhhh+-://///    -+oo:`  ::-:+////++///:`        ',
        ' /Nmhs+oss-:++/dNNNmhho:--::///    /mmmmmo  ../-///++///////.       ',
        '  oNNdhhhhhhhs//osso/:---:::///    /yyyyso  ..o+-//////////:/.      ',
        '   /mNNNmdhhhh/://+///::://////     -:::- ..+sy+:////////::/:/.     ',
        '     /hNNNdhhs--:/+++////++/////.      ..-/yhhs-/////////::/::/`    ',
        '       .ooo+/-::::/+///////++++//-/ossyyhhhhs/:///////:::/::::/:    ',
        '       -///:::::::////++///+++/////:/+ooo+/::///////.::://::---+`   ',
        '       /////+//++++/////+////-..//////////::-:::--`.:///:---:::/:   ',
        '       //+++//++++++////+++///::--                 .::::-------::   ',
        '       :/++++///////////++++//////.                -:/:----::../-   ',
        '       -/++++//++///+//////////////               .::::---:::-.+`   ',
        '       `////////////////////////////:.            --::-----...-/    ',
        '        -///://////////////////////::::-..      :-:-:-..-::.`.+`    ',
        '         :/://///:///::://::://::::::/:::::::-:---::-.-....``/- -   ',
        '           ::::://::://::::::::::::::----------..-:....`.../- -+oo/ ',
        '            -/:::-:::::---://:-::-::::----::---.-.......`-/.      ``',
        '           s-`::--:::------:////----:---.-:::...-.....`./:          ',
        '          yMNy.`::-.--::..-dmmhhhs-..-.-.......`.....-/:`           ',
        '         oMNNNh. `-::--...:NNNdhhh/.--.`..``.......:/-              ',
        '        :dy+:`      .-::-..NNNhhd+``..`...````.-::-`                ',
        '                        .-:mNdhh:.......--::::-`                    ',
        '                           yNh/..------..`                          ',
        '                                                                    ',
        '',
      },
    }

    local dotfiles_path = vim.g.dotfiles

    -- Build shortcuts dynamically
    local shortcuts = {
      {
        desc = ' Obsidian Today',
        group = '@markup.heading.1.markdown',
        action = 'Obsidian today',
        key = 'o',
      },
      {
        desc = '󰊳 Update',
        group = '@markup.heading.2.markdown',
        action = 'Lazy update',
        key = 'u',
      },
      {
        icon = ' ',
        icon_hl = '@variable',
        desc = 'Sessions',
        group = '@markup.heading.3.markdown',
        action = 'TelescopeSessions',
        key = 's',
      },
      {
        desc = ' dotfiles',
        group = '@markup.heading.5.markdown',
        action = 'Telescope find_files cwd=' .. dotfiles_path,
        key = 'd',
      },
    }

    math.randomseed(os.time())

    return {
      theme = 'hyper',
      config = {
        header = headers[math.random(#headers)],
        shortcut = shortcuts,
        footer = fortune.get(),
      },
    }
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
