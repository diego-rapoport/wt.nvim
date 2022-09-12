local ctx_manager = require'plenary.context_manager'
local with = ctx_manager.with
local open = ctx_manager.open

local M = {}

--[[
  This function gets your config path.

  @returns str The config path of neovim
]]
M.getConfigPath = function ()
  local configPath = vim.split(vim.o.packpath, ',')[1]
  return configPath
end
-- Just for sake of convenience
M.configPath = M.getConfigPath()

--[[
  Get the full path of the git repo

  @returns string|nil The git repo we're on or nil if we're not on git repo
]]
M.getRepoPath = function ()
    local repoPath = io.popen("git rev-parse --show-toplevel"):read()
    return repoPath or nil
end

--[[
  Get's the name of the repo of the file it's been working on

  @returns str The name of the git repo
]]
M.getRepoName = function ()
  if(M.isGitRepo()) then
    -- toplevel has the fullname of .git repository
    local toplevel = M.getRepoPath()
    local repoName = toplevel and vim.split(toplevel, "/") or ''
    return repoName[#repoName] and repoName[#repoName] or error("It was not possible to get repo's name")
  end
  return nil
end

--[[
  Check if the path we're working on is a git repository

  @returns true or nil
]]
M.isGitRepo = function ()
  return io.popen("git rev-parse --is-inside-work-tree 2> /dev/null"):read()
end

--[[
  This function creates an empty listed json file.
]]
M.createProgressFile = function (pathName)
  local data = {}
  local encoded = vim.json.encode(data)
  with(open(pathName, 'a+'), function (file)
    local written = file:read()
    if written == nil then
      return file:write(encoded)
    end
  end)
end

--[[
  Function to get the timestamp it is called.

  @returns datetime
]]
M.getNow = function ()
  return os.time(os.date("!*t"))
end

--[[
  This is the command that starts tracking
  the time when you call it.
  The ex-command is :StartWT
]]
M.startWT = function ()
  M.initiated = M.getNow()
  vim.notify("Beginning to work at " .. os.date("%X") .. " 💻")
end

--[[
  This is the command that stops tracking
  the time you've worked on.
  It saves the progress on default progress
  file and restarts the initiated time.
]]
M.stopWT = function ()
  if M.initiated then
    local stoppedAt = M.getNow()
    vim.notify("Ending work at " .. os.date("%X") .. " ⌛")
    local diff = stoppedAt - M.initiated
    local repoName = M.getRepoName()
    local fullProgressPath = M.getConfigPath() .. '/.wt/progress.json'
    local lastData = with(open(fullProgressPath), function (file)
      return vim.json.decode(file:read("*a"))
    end)
    with(open(fullProgressPath, 'w'), function (file)
      local projectExists = M._progressProjectName(lastData, repoName)
      if projectExists then
        lastData[projectExists][repoName].timeSpent = lastData[projectExists][repoName].timeSpent + diff
      else
        local newProject = {[repoName] = {timeSpent = diff}}
        table.insert(lastData, newProject)
      end
      file:write(vim.json.encode(lastData))
    end)
    -- Reset initiation
    M.initiated = nil
  else
    vim.notify("You haven't initiated to track your progress yet 😅")
  end
end

--[[
  Check if name is inside data
  where data is a lista of named projects

  @param table Data from progress.json
  @param string Name of the project

  @returns int|bool The index of the project
  if it exists or false otherwise
]]
M._progressProjectName = function(data, name)
  for i,v in ipairs(data) do
    if v[name] then
      return i
    end
  end
  return false
end

return M

