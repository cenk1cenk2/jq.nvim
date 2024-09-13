local M = {}

---@class jq.Config
---@field log_level? number

---@type jq.Config
local defaults = {
  log_level = vim.log.levels.INFO,
}

---@type jq.Config
---@diagnostic disable-next-line: missing-fields
M.options = {}

---@param config jq.Config
---@return jq.Config
function M.setup(config)
  M.options = vim.tbl_deep_extend("force", {}, defaults, config or {})

  return M.options
end

return M
