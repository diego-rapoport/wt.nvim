local wt = require('wt')

vim.api.nvim_create_user_command('InitWT', wt.initWT, {})
vim.api.nvim_create_user_command('StartWT', wt.startWT, {})
vim.api.nvim_create_user_command('StopWT', wt.stopWT, {})
