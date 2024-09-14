local M = {}

---
---@param scratch boolean
---@param modifiable boolean
---@return integer
function M.create_buffer(scratch, modifiable)
  local bufnr = vim.api.nvim_create_buf(false, scratch)

  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", modifiable, { buf = bufnr })

  return bufnr
end

---
---@param component any
---@param value? any
---@return any
function M.set_component_value(component, value)
  vim.schedule(function()
    if not value then
      value = component:get_current_value()
    end

    component:set_current_value(value)
    if type(component.get_lines) == "function" then
      local lines = component:get_lines()
      vim.api.nvim_buf_set_lines(component.bufnr, 0, -1, true, lines)
    end
    component:redraw()
  end)

  return component
end

---@param bufnr integer
---@return string[] | nil
function M.get_buffer_content(bufnr)
  local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  if #content == 0 or (#content == 1 and content[1] == "") then
    return nil
  end

  return content
end

---@param component any
---@return string[] | nil
function M.get_component_buffer_content(component)
  return M.get_buffer_content(component.bufnr)
end

---
---@param component any
---@param content string | string[]
---@return any
function M.set_component_buffer_content(component, content)
  if component.bufnr == nil then
    return component
  end

  ---@type string[]
  local c
  if type(content) == "string" then
    c = vim.fn.split(content, "\n")
  elseif type(content) == "table" then
    c = content
  else
    c = { "" }
  end

  local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = component.bufnr })
  if not modifiable then
    vim.api.nvim_set_option_value("modifiable", true, { buf = component.bufnr })
  end

  vim.api.nvim_buf_set_lines(component.bufnr, 0, -1, false, c)
  vim.api.nvim_set_option_value("modified", false, { buf = component.bufnr })
  vim.api.nvim_set_option_value("modifiable", modifiable, { buf = component.bufnr })

  return component
end

--- Returns the buffer absolute file path.
---@param bufnr? number
---@return string
function M.get_buffer_filepath(bufnr)
  return require("plenary.path").new(vim.api.nvim_buf_get_name(bufnr or 0)):absolute()
end

--- Returns the buffer relative file path in the project.
---@param bufnr? number
---@return string
function M.get_project_buffer_filepath(bufnr)
  return require("plenary.path").new(vim.api.nvim_buf_get_name(bufnr or 0)):make_relative()
end

---@param renderer any
function M.attach_autoclose(renderer)
  local popups = renderer._private.flatten_tree
  for _, popup in pairs(popups) do
    popup:on("BufLeave", function()
      vim.schedule(function()
        local bufnr = vim.api.nvim_get_current_buf()
        for _, p in pairs(popups) do
          if p.bufnr == bufnr then
            return
          end
        end
        renderer:close()
      end)
    end)
  end
end

---Attaches resize event to the renderer.
---@param renderer any
---@param size jq.ConfigUiSize
---@return number
function M.attach_resize(renderer, size)
  local id = vim.api.nvim_create_autocmd({ "VimResized" }, {
    desc = "Resizes to UI on resizing the window.",
    callback = function()
      renderer:set_size(M.renderer_calculate_size(size))
    end,
  })

  return id
end

---Calculate the size of the UI.
---@param size jq.ConfigUiSize
---@return jq.ConfigUiSize
function M.renderer_calculate_size(size)
  ---@type jq.ConfigUiSize
  local result = {}

  if type(size.width) == "number" and size.width <= 1 and size.width > 0 then
    result.width = math.floor(vim.o.columns * size.width)
  elseif type(size.width) == "function" then
    result.width = size.width(vim.o.columns)
    if type(result.width) == "number" and result.width <= 1 and result.width > 0 then
      result.width = M.renderer_calculate_size(result).width
    end
  end

  if type(size.height) == "number" and size.height <= 1 and size.height > 0 then
    result.height = math.floor(vim.o.lines * size.height)
  elseif type(size.height) == "function" then
    result.height = size.height(vim.o.lines)
    if type(result.height) == "number" and result.height <= 1 and result.height > 0 then
      result.height = M.renderer_calculate_size(result).height
    end
  end

  return result
end

return M
