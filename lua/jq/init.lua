local M = {}

local log = require("jq.log")

---@param config jq.Config
function M.setup(config)
  log.setup()
  local c = require("youtrack.setup").setup(config)
  lib.setup(c)
end

return M
