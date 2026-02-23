local Git = require("worktree.git")
local State = require("worktree.state")
--- @class _Worktree
local _Worktree = {}

local state = State.get()

function _Worktree.setup(_)
  if not Git.is_inside_worktree() then
    if not state.path then
      state.path = Git.absolute_git_dir()
      vim.notify(state.path)
    end
    vim.api.nvim_create_user_command(
      "SwitchWorktree",
      function(opts)
        state.worktree = opts.args
        Git.switch_worktree(state.path, opts.args)
        vim.cmd("e .")
        State.set(state)
      end,
      {
        nargs = 1,
        desc = "",
        complete = function(arg_lead, _, _)
          local worktrees = Git.get_worktrees(state.worktree)
          return vim.tbl_filter(function(trees)
            return vim.startswith(trees, arg_lead)
          end, worktrees)
        end,
      }
    )
    --vim.api.nvim_create_user_command(
    --  "AddWorktree",
    --  function(opts)
    --    state.worktree = opts.args
    --    Git.add_worktree(state.path, opts.args)
    --    Git.switch_worktree(state.path, opts.args)
    --    Git.git_set_origin(opts.args)
    --    vim.cmd("e .")
    --    State.set(state)
    --  end,
    --  {
    --    nargs = 1,
    --    desc = ""
    --  }
    --)
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if state.worktree then
          Git.switch_worktree(state.path, state.worktree)
        end
      end
    })
  end
end

function _Worktree.snacks()
  -- Transform strings into {text = string} format
  local items = vim.tbl_map(function(s)
    return { text = s }
  end, Git.get_worktrees(state.worktree))

  Snacks.picker({
    items = items,
    layout = {
      preset = "vscode"
    },
    format = "text",
    confirm = function(picker, item)
      picker:close()
      state.worktree = item.text
      Git.switch_worktree(state.path, item.text)
      vim.cmd("e .")
      State.set(state)
    end,
  })
end

return _Worktree
