# Surface.nvim

Surface is a lightweight Neovim plugin for managing floating terminal windows.
It lets you easily open and move terminal sessions around your editor with customizable key mappings.

## Features

- Open commands in a floating terminal window.
- Move terminal windows between top, bottom, left, right, and center.
- Quickly hide terminals with a keypress.
- Simple API and setup.

## Installation

Using lazy.nvim:

```lua
{
  "carldaws/surface.nvim",
  config = function()
    require("surface").setup {
      mappings = {
        { keymap = "<leader>lg", command = "lazygit" },
        { keymap = "<leader>sh", command = os.getenv("SHELL") },
      }
    }
  end
}
```

## Usage

Press your configured keymap to open a command in a floating terminal.

Inside the terminal, you can:

- Press `<Esc><Esc>` to hide the terminal
- Press `<Esc><Left>` to move the terminal to the left
- Press `<Esc><Right>` to move the terminal to the right
- Press `<Esc><Up>` to move the terminal to the top
- Press `<Esc><Down>` to move the terminal to the bottom
- Press `<Esc>c` to recenter the terminal

The terminal window will remain open until you hide it

## Next Up

- Allow the default position for all windows to be something other than center
- Allow the default position to be set per mapping
