local M = {
  run = require("jq.api").run,
}

---@param config jq.Config
function M.setup(config)
  require("jq.config").setup(config)
end

return M
