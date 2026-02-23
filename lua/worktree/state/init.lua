--- @class State
--- @field worktree string

--- @class _State
local _State = {}

local state_path = vim.fs.joinpath(
  vim.fn.stdpath("data"),
  "worktrees",
  vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
)

function _State.get()
  if vim.fn.isdirectory(state_path) and vim.fn.filereadable(vim.fs.joinpath(state_path, "config.json")) == 1 then
    local lines = vim.fn.readfile(vim.fs.joinpath(state_path, "config.json"))
    local content = table.concat(lines, "\n")
    return vim.json.decode(content)
  else
    return { path = nil, worktree = nil }
  end
end

--- @param state State
function _State.set(state)
  local json_str = vim.json.encode(state)
  local config_path = vim.fs.joinpath(state_path, "config.json")
  local lines = vim.split(json_str, "\n")
  vim.notify(state_path)
  vim.fn.mkdir(state_path, "p")
  vim.fn.writefile(lines, config_path)
end

return _State
