local ctx_manager = require'plenary.context_manager'
local with = ctx_manager.with
local open = ctx_manager.open
local path = require'plenary.path'

local M = {}

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

local function checkFileExists(name)
  local file = io.open(name, 'r')
  if file ~=nil then io.close(file) return true else return false
  end
end

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

M.initWT = function ()
  if M.isGitRepo() then
    local repoPath = M.getRepoPath()
    M.repoPath = repoPath
    local p = path:new(repoPath .. '/.wt')
    if not(path.exists(p)) then
      path.mkdir(p)
      local progressFP = p.filename .. '/progress.json'
      M.createProgressFile(progressFP)
      vim.notify('Creating progress file')
      vim.notify("WT path created and you can start it now")
      return
    end
    vim.notify("WT already started inside this git project")
    return
  end
  vim.notify("You're not inside a git project.")
end

M.getNow = function ()
  return os.time(os.date("!*t"))
end

M.startWT = function ()
  if checkFileExists(M.getRepoPath() .. '/.wt/progress.json') then
    M.initiated = M.getNow()
    vim.notify("Beginning to work at " .. os.date("%X") .. " 💻")
  else
    vim.notify('Please start WT first with :InitWT')
  end
end

M.stopWT = function ()
  if M.initiated then
    local stoppedAt = M.getNow()
    vim.notify("Ending work at " .. os.date("%X") .. " ⌛")
    local diff = stoppedAt - M.initiated
    local repoName = M.getRepoName()
    with(open(M.getRepoPath() .. '/.wt/progress.json', 'r+'), function (file)
      local data = vim.json.decode(file:read("*a"))
      file:seek('set')
      local projectExists = M._progressProjectName(data, repoName)
      if projectExists then
        data[repoName].timeSpent = data[repoName].timeSpent + diff
      else
        local newProject = {[repoName] = {timeSpent = diff}}
        table.insert(data, newProject)
      end
      P(data)
      file:write(vim.json.encode(data))
    end)
  else
    vim.notify("You haven't initiated to track your progress yet")
  end
end

--[[
  Check if name is inside data
  where data is a lista of named projects

  @param table Data from progress.json
  @param string Name of the project

  @returns bool True if the name is there,
    false otherwise
]]
M._progressProjectName = function(data, name)
  for _,v in ipairs(data) do
    if v[1] == name then
      return true
    end
  end
  return false
end

return M

