local M = {
  run = require("jq.api").run,
  run_visual = require("jq.api").run_visual,
}

---@param config jq.Config
function M.setup(config)
  require("jq.config").setup(config)
end

return M
