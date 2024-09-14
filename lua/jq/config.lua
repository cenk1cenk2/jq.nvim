local M = {}

---@class jq.Config
---@field log_level? number
---@field commands? jq.ConfigCommand[]
---@field ui? jq.ConfigUi
---@field debounce? number

---@class jq.ConfigCommand
---@field command string Command to run.
---@field filetype string Filetype for the result.
---@field arguments? string Hidden arguments for the command that would not be shown in the prompt.

---@class jq.ConfigUi: jq.ConfigUiSize
---@field border? 'double' | 'none' | 'rounded' | 'shadow' | 'single' | 'solid'
---@field keymap? jq.ConfigUIKeymap

---@class jq.ConfigUiSize
---@field width? number
---@field height? number

---@class jq.ConfigUIKeymap
---@field close? string
---@field focus_next? string
---@field focus_prev? string
---@field focus_left? string
---@field focus_right? string
---@field focus_up? string
---@field focus_down? string

---@type jq.Config
local defaults = {
  log_level = vim.log.levels.INFO,
  debounce = 25,
  commands = {
    { command = "jq", filetype = "json" },
    { command = "yq", filetype = "json" },
  },
  ui = {
    border = "single",
    width = 120,
    height = 36,
    keymap = {
      close = "<Esc>",
      focus_next = "<Tab>",
      focus_prev = "<S-Tab>",
      focus_left = "<Left>",
      focus_right = "<Right>",
      focus_up = "<Up>",
      focus_down = "<Down>",
    },
  },
}

---@type jq.Config
---@diagnostic disable-next-line: missing-fields
M.options = nil

---@return jq.Config
function M.read()
  return M.options or defaults
end

---@param config jq.Config
---@return jq.Config
function M.setup(config)
  M.options = vim.tbl_deep_extend("force", {}, defaults, config or {})

  return M.options
end

return M
