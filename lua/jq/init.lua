local M = {}

---@param config jq.Config
function M.setup(config)
  local c = require("jq.config").setup(config)

  local log = require("jq.log").setup({ level = c.log_level })

  log.debug("Plugin has been setup: %s", c)
end

return M
