# jq.nvim

Run `jq` and variants like `yq` or `gojq` in an interactive window in Neovim and process the current buffer.

## Features

- Run `jq` in an interactive window in Neovim.
- Ability to run variants of `jq` like `yq` or `gojq`.
- Copy the output of the process.
- Ability to write the output of `jq` back to a file.

![demo](./media/swappy-20240914_193809.png)

![demo](./media/swappy-20240914_193824.png)

## Installation

### `lazy.nvim`

```lua
{
  "cenk1cenk2/jq.nvim",
  dependencies = {
    -- https://github.com/nvim-lua/plenary.nvim
    "nvim-lua/plenary.nvim",
    -- https://github.com/MunifTanjim/nui.nvim
    "MunifTanjim/nui.nvim",
    -- https://github.com/grapp-dev/nui-components.nvim
    "grapp-dev/nui-components.nvim",
  },
}
```

## Configuration

### Setup

Plugin requires no setup by default. However if you want to change the default settings for good, then you can call it.

```lua
require("jq").setup()
```

You can find the default configuration file and available options [here](https://github.com/cenk1cenk2/jq.nvim/blob/main/lua/jq/config.lua).

## Usage

This plugin only exposes one interface that toggles to UI.

All the following options are **optional**.

```lua
require("jq").run({
  --- you can pass additional options to configure the current instance
  -- if you want to toggle from the memory
  toggle = true,
  -- commands for the instance else it will use the default
  -- the default command would be the first one in the table
  commands = {
    {
      -- command to be run
      command = "jq",
      -- filetype of the output
      filetype = "json",
      -- hidden arguments that will not be shown in the ui
      arguments = "-r"
    },
  },
  -- arguments to start with in the ui
  arguments = "",
  -- query to start with, if not provided it will use the default
  query = ".",
})
```

## References

The UI is only possible due to beautiful work done on [MunifTanjim/nui.nvim](https://github.com/MunifTanjim/nui.nvim) and [grapp-dev/nui-components.nvim](https://github.com/grapp-dev/nui-components.nvim).
