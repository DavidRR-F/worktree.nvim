--- @class Git
local _Git = {}

--- @return string[]
function _Git.get_worktrees(current)
  local output = vim.fn.systemlist("git worktree list")

  if not output or #output == 0 then
    return {}
  end

  local branches = {}
  for _, line in ipairs(output) do
    local branch_name = line:match("%[([^%]]+)%]")
    if branch_name and branch_name ~= current then
      branch_name = branch_name:gsub("\n", "")
      table.insert(branches, branch_name)
    end
  end

  return branches
end

--- @param name string
function _Git.add_worktree(path, name)
  vim.fn.system({ "git", "worktree", "add", path .. "/" .. name })
end

function _Git.switch_worktree(path, tree)
  local worktree_dir = path .. "/" .. tree
  worktree_dir = worktree_dir:gsub("\n", ""):gsub("\r", "")
  vim.cmd("cd " .. worktree_dir)
  vim.notify("Switch to Worktree: " .. tree, vim.log.levels.INFO)
end

--- @param name string
function _Git.git_set_origin(name)
  return vim.fn.systemlist({ "git", "branch", "--set-upstream=origin/" .. name })
end

function _Git.is_inside_worktree()
  local output = vim.fn.systemlist({ "git", "rev-parse", "--is-inside-work-tree" })
  return output[1] and output[1]:match("^true$") == "true"
end

function _Git.absolute_git_dir()
  local path = vim.fn.system({ "git", "rev-parse", "--absolute-git-dir" })
  path = path:gsub("\n", "")
  return path
end

function _Git.is_git_repo()
  return vim.fn.isdirectory(".git") == 1
end

return _Git
