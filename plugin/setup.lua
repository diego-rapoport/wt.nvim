local path = require("plenary.path")
local wt = require('wt')

-- Creates filepath of .wt/progress.json inside config folder
local confPath = path:new(wt.getConfigPath() .. '/.wt')
path.mkdir(confPath)
wt.createProgressFile(confPath.filename .. '/progress.json')

vim.api.nvim_create_user_command('StartWT', wt.startWT, {})
vim.api.nvim_create_user_command('StopWT', wt.stopWT, {})

