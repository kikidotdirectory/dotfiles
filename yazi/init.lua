require("git"):setup()

require("bunny"):setup({
  hops = {
    { key = "~",          path = "~",                         desc = "Home"         },
		-- dot-files configuration
    { key = { "c", "c" }, path = "~/dotfiles",                desc = ".config/"     },
    { key = { "c", "n" }, path = "~/dotfiles/nvim",           desc = "nvim"         },
    { key = { "c", "y" }, path = "~/dotfiles/yazi",           desc = "yazi"         },

		-- desktop-related locations
    { key = { "d", "d" }, path = "~/Documents",               desc = "Documents"    },
    { key = { "d", "D" }, path = "~/Downloads",               desc = "Downloads"    },
    { key = { "d", "w" }, path = "~/Documents/Writings",      desc = "Writings"     },
    { key = { "d", "W" }, path = "~/Documents/Websites",      desc = "Websites"     },
    { key = { "d", "p" }, path = "~/Projects",                desc = "Projects"     },
    { key = { "d", "n" }, path = "~/Documents/Newsletter",    desc = "Newsletter"   },
    { key = { "d", "z" }, path = "~/Documents/zmk-workspace", desc = "ZMK config"   },
    { key = { "l", "s" }, path = "~/.local/share", desc = "Local share"  },
    { key = { "l", "b" }, path = "~/.local/bin",   desc = "Local bin"    },
    { key = { "l", "t" }, path = "~/.local/state", desc = "Local state"  },
  },
  desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
  ephemeral = true, -- Enable ephemeral hops, default is true
  tabs = true, -- Enable tab hops, default is true
  notify = false, -- Notify after hopping, default is false
  fuzzy_cmd = "fzf", -- Fuzzy searching command, default is "fzf"
})
