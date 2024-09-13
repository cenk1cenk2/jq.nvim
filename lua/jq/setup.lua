---@class jq.Config

local M = {}

---@type jq.Config
M.config = {}

---@param config jq.Config
function M.setup(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  return M.config
end

return M
