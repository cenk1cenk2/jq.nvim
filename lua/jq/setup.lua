---@class jq.Config
---@field log_level number

local M = {}

---@type jq.Config
M.config = {
  log_level = vim.log.levels.INFO,
}

---@param config jq.Config
---@return jq.Config
function M.setup(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  return M.config
end

return M
