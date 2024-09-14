local M = {
  _ = {},
}

local config = require("jq.config")
local n = require("nui-components")
local utils = require("jq.utils")

---@class jq.RunOpts
---@field toggle? boolean
---@field commands? jq.ConfigCommand[]
---@field arguments? string
---@field query? string

---@type fun(opts: jq.RunOpts): nil
function M.run(opts)
  opts = opts or {}

  local c = config.read()
  local log = require("jq.log").setup({ level = c.log_level })

  if M._.renderer ~= nil then
    M._.renderer:close()

    return
  end

  local renderer = n.create_renderer(vim.tbl_deep_extend("force", {}, c.ui, {
    position = "50%",
    relative = "editor",
  }))

  renderer:add_mappings({
    {
      mode = { "n" },
      key = "q",
      handler = function()
        renderer:close()
      end,
    },
  })

  renderer:on_mount(function()
    M._.renderer = renderer
  end)

  renderer:on_unmount(function()
    M._.renderer = nil
  end)

  local bufnr = vim.api.nvim_get_current_buf()

  ---@type jq.ConfigCommand[]
  local commands = opts.commands or c.commands

  local signal = n.create_signal({
    commands = vim.tbl_map(function(command)
      return n.node(command)
    end, commands),
    command = n.node(commands[1]),
    arguments = opts.arguments or "",
    query = opts.query or ".",
  })

  if M._.signal == nil then
    M._.signal = signal
  elseif opts.toggle and M._.signal ~= nil then
    signal = M._.signal
  end

  local body = n.rows(
    { flex = 1 },
    n.columns(
      { flex = 0 },
      n.paragraph({
        flex = 1,
        border_label = "File",
        border_style = c.ui.border,
        is_focusable = false,
        lines = utils.get_project_buffer_filepath(bufnr),
      }),
      n.tree({
        flex = 1,
        border_label = "Command",
        border_style = c.ui.border,
        selected = signal.command,
        data = signal.commands,
        on_select = function(node)
          signal.command = node
        end,
        prepare_node = function(node, line, component)
          line:append(node.command)

          return line
        end,
      }),
      n.text_input({
        flex = 6,
        border_label = "Arguments",
        border_style = c.ui.border,
        autofocus = false,
        autoresize = false,
        max_lines = 1,
        value = signal.arguments,
        placeholder = "arguments...",
        on_change = function(value)
          signal.arguments = value
        end,
        on_mount = function(component)
          utils.set_component_value(component)
        end,
      })
    ),
    n.text_input({
      border_label = "Query",
      border_style = c.ui.border,
      autofocus = true,
      autoresize = false,
      size = 1,
      max_lines = 1,
      value = signal.query,
      placeholder = "query...",
      on_change = function(value)
        signal.query = value
      end,
      on_mount = function(component)
        utils.set_component_value(component)
      end,
    }),
    n.buffer({
      id = "results",
      border_label = "Results",
      flex = 1,
      autoscroll = false,
      border_style = c.ui.border,
      buf = utils.create_buffer(false, true),
    }),
    n.text_input({
      id = "save",
      border_label = "Save",
      border_style = c.ui.border,
      autofocus = false,
      autoresize = false,
      size = 1,
      max_lines = 1,
      value = utils.get_buffer_filepath(bufnr),
      placeholder = "save to...",
      on_mount = function(component)
        utils.set_component_value(component)
      end,
    }),
    n.columns(
      {
        flex = 0,
      },
      n.button({
        label = "Yank <C-y>",
        global_press_key = "<C-b>",
        autofocus = false,
        border_style = c.ui.border,
        on_press = function()
          local component = renderer:get_component_by_id("results")

          if component == nil then
            return
          end

          local lines = utils.get_component_buffer_content(component)

          vim.fn.setreg(vim.v.register or "", table.concat(lines, "\n"))

          log.info("Yanked results to register.")
        end,
      }),
      n.gap(1),
      n.button({
        label = "Save <C-s>",
        global_press_key = "<C-s>",
        autofocus = false,
        border_style = c.ui.border,
        on_press = function()
          local component = renderer:get_component_by_id("save")

          if component == nil then
            return
          end

          local filename = component:get_current_value()
          if not filename or filename == "" then
            log.error("No file path provided.")

            return
          end

          local lines = utils.get_component_buffer_content(component)

          local fd, fd_open_err = vim.uv.fs_open(filename, "w", 660)

          if not fd or fd_open_err then
            log.error("Failed to open file: %s", fd_open_err)

            return
          end
          local _, fd_write_err = vim.uv.fs_write(fd, lines, -1)

          if fd_write_err then
            log.error("Failed to write file: %s", fd_write_err)

            return
          end

          log.info("Saved results to file: %s", filename)
        end,
      }),
      n.gap(1),
      n.button({
        label = "Close <C-x>",
        global_press_key = "<C-x>",
        autofocus = false,
        border_style = c.ui.border,
        on_press = function()
          renderer:close()
        end,
      })
    )
  )

  signal:observe(function(prev, next)
    if prev.command == next.command and prev.arguments == next.arguments and prev.query == next.query then
      log.debug("No actual changes to signal.")

      return
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    require("plenary.job")
      :new({
        command = vim.split(signal.command:get_value().command, " ")[1],
        args = vim.list_extend(
          signal.command:get_value().arguments and signal.command:get_value().arguments ~= "" and vim.split(signal.command:get_value().arguments, " ") or {},
          vim.list_extend(signal.arguments:get_value() ~= "" and vim.split(signal.arguments:get_value(), " ") or {}, { signal.query:get_value() })
        ),
        writer = lines,
        enabled_recording = true,
        detached = true,
        on_exit = function(j, code)
          vim.schedule(function()
            local component = renderer:get_component_by_id("results")
            if component == nil then
              return
            end

            vim.api.nvim_set_option_value("filetype", signal.command:get_value().filetype, { buf = component.bufnr })

            utils.set_component_buffer_content(component, code == 0 and j:result() or j:stderr_result())
          end)
        end,
      })
      :start()
  end, c.debounce)

  renderer:render(body)
end

return M
