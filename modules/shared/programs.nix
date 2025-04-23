{
  pkgs,
  lib,
  variables,
  inputs,
  osConfig,
  ...
}:

let
  inherit (variables) userName fullName;

  # `osConfig` allows us to access nixos's `config` from home-manager
  homeDir = osConfig.users.users.${userName}.home;
  primaryKey = osConfig.age.secrets.primary.path;

  isFish = osConfig.shells.activeShell == "fish";
  isZsh = osConfig.shells.activeShell == "zsh";

  checkShell = if isFish then "fish" else "zsh";
  shell = "/run/current-system/sw/bin/${checkShell}";
in
{
  imports = [
    inputs.tokyonight.homeManagerModules.default
  ];

  tokyonight.enable = true;
  tokyonight.style = "night";

  programs = {
    oh-my-posh = {
      enable = true;
      enableZshIntegration = isZsh;
      enableFishIntegration = isFish;
      useTheme = "tokyonight_storm";
    };

    # ---------------------
    # -- Shell utilities --
    # ---------------------
    fd.enable = true;
    bat.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = isZsh;
      enableFishIntegration = isFish;
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
      fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      fileWidgetOptions =
        if isFish then
          [
            "--preview 'if test -d {}; eza --tree --all --level=3 --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end'"
          ]
        else
          [
            "--preview 'if [ -d {} ]; then eza --tree --all --level=3 --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
          ];
      changeDirWidgetCommand = "fd --type d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidgetOptions = [ "--preview 'eza --tree --color=always {} | head -200'" ];
    };

    zoxide = {
      enable = true;
      enableZshIntegration = isZsh;
      enableFishIntegration = isFish;
      options = [
        "--cmd cd"
      ];
    };

    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    yazi = {
      enable = true;
      enableZshIntegration = isZsh;
      enableFishIntegration = isFish;
      settings = {
        manager = {
          show_hidden = true;
          ratio = [
            1
            3
            4
          ];
        };
      };
      keymap = {
        manager.prepend_keymap = [
          {
            on = "<PageUp>";
            run = "seek -1";
            desc = "Scroll up in preview";
          }
          {
            on = "<PageDown>";
            run = "seek 1";
            desc = "Scroll down in preview";
          }
        ];
      };
    };

    ssh = {
      enable = true;
      includes = [ "${homeDir}/.ssh/config_external" ];
      matchBlocks = {
        "github.com" = {
          identitiesOnly = true;
          identityFile = [ primaryKey ];
        };
      };
      addKeysToAgent = "yes";
    };

    tmux = {
      enable = true;
      sensibleOnTop = false;
      shell = shell;
      plugins = [ pkgs.tmuxPlugins.catppuccin ];
      extraConfig = # bash
        ''
          set -g default-terminal "$TERM"
          set -ag terminal-overrides ",$TERM:Tc"

          set -g mouse on
          set -g history-limit 10000

          # Make TMUX work with yazi
          set -g allow-passthrough on
          set -ga update-environment TERM
          set -ga update-environment TERM_PROGRAM

          # Avoid ESC delay
          set -s escape-time 0

          # Vim style pane selection
          bind h select-pane -L
          bind j select-pane -D 
          bind k select-pane -U
          bind l select-pane -R

          # Start windows and panes at 1, not 0
          set -g base-index 1
          set -g pane-base-index 1
          set-window-option -g pane-base-index 1
          set-option -g renumber-windows on

          # Use Alt-arrow keys without prefix key to switch panes
          bind -n M-Left select-pane -L
          bind -n M-Right select-pane -R
          bind -n M-Up select-pane -U
          bind -n M-Down select-pane -D

          # Shift arrow to switch windows
          bind -n S-Left  previous-window
          bind -n S-Right next-window

          # Shift Alt vim keys to switch windows
          bind -n M-H previous-window
          bind -n M-L next-window
        '';
    };

    # -----------------------
    # -- Git configuration --
    # -----------------------
    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = fullName;
      includes = [
        { path = "./user_email"; }
      ];
      signing = {
        key = primaryKey;
        signByDefault = true;
      };
      lfs.enable = true;
      # setting `delta.enable = true;` sets
      #   `core.pager = "delta"` and
      #   `interactive.diffFilter = "delta --color-only";`
      # by default, so they don't need to be set manually
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      extraConfig = {
        gpg.format = "ssh";
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
        pull.rebase = true;
        rebase.autoStash = true;
        rerere.enabled = true;
        merge.conflictsyle = "diff3";
        diff.colorMoved = "default";
      };
      aliases = {
        a = "add .";
        c = "commit";
        ca = "commit -a";
        cam = "commit -a --amend --no-edit";
        f = "fetch";
        pl = "pull";
        p = "push";
        pf = "push --force-with-lease origin";
        update-last-commit = "!git commit -a --amend --no-edit && git push --force-with-lease origin";
      };
    };

    lazygit = {
      enable = true;
      settings = {
        os.editPreset = "nvim";
        git.paging.pager = "delta --dark --paging=never";
      };
    };

    # --------------------------
    # -- Editor configuration --
    # --------------------------

    helix = {
      enable = true;
      settings = {
        theme = "tokyonight";
        editor = {
          mouse = true;
          line-number = "absolute";
          cursorline = true;
          auto-completion = true;
          auto-format = true;
          auto-info = true;
          color-modes = true;
          auto-pairs = true;
          gutters = [
            "diff"
            "diagnostics"
            "line-numbers"
            "spacer"
          ];
          middle-click-paste = true;

          statusline = {
            left = [
              "mode"
              "spinner"
            ];
            center = [ "file-name" ];
            right = [
              "diagnostics"
              "selections"
              "position"
              "file-encoding"
              "file-line-ending"
              "file-type"
              "version-control"
            ];
            separator = "│";
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
          };

          lsp = {
            enable = true;
            display-messages = true;
            auto-signature-help = true;
            display-inlay-hints = true;
            display-signature-help-docs = true;
            snippets = true;
          };

          whitespace = {
            render = "all";
            characters = {
              space = "·";
              nbsp = "⍽";
              tab = "→";
              newline = "⏎";
              tabpad = "·";
            };
          };
        };
      };
    };

    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-airline
        vim-airline-themes
        vim-startify
        vim-tmux-navigator
      ];
      settings = {
        ignorecase = true;
      };
      extraConfig = # vim
        ''
          "" General
          set number
          set history=1000
          set nocompatible
          set modelines=0
          set encoding=utf-8
          set scrolloff=3
          set showmode
          set showcmd
          set hidden
          set wildmenu
          set wildmode=list:longest
          set cursorline
          set ttyfast
          set nowrap
          set ruler
          set backspace=indent,eol,start
          set laststatus=2
          set clipboard=autoselect

          " Dir stuff
          set nobackup
          set nowritebackup
          set noswapfile
          set backupdir=~/.config/vim/backups
          set directory=~/.config/vim/swap

          " Relative line numbers for easy movement
          set relativenumber
          set rnu

          "" Whitespace rules
          set tabstop=8
          set shiftwidth=2
          set softtabstop=2
          set expandtab

          "" Searching
          set incsearch
          set gdefault

          "" Statusbar
          set nocompatible " Disable vi-compatibility
          set laststatus=2 " Always show the statusline
          let g:airline_theme='bubblegum'
          let g:airline_powerline_fonts = 1

          "" Local keys and such
          let mapleader=","
          let maplocalleader=" "

          "" Change cursor on mode
          :autocmd InsertEnter * set cul
          :autocmd InsertLeave * set nocul

          "" File-type highlighting and configuration
          syntax on
          filetype on
          filetype plugin on
          filetype indent on

          "" Paste from clipboard
          nnoremap <Leader>, "+gP

          "" Copy from clipboard
          xnoremap <Leader>. "+y

          "" Move cursor by display lines when wrapping
          nnoremap j gj
          nnoremap k gk

          "" Map leader-q to quit out of window
          nnoremap <leader>q :q<cr>

          "" Move around split
          nnoremap <C-h> <C-w>h
          nnoremap <C-j> <C-w>j
          nnoremap <C-k> <C-w>k
          nnoremap <C-l> <C-w>l

          "" Easier to yank entire line
          nnoremap Y y$

          "" Move buffers
          nnoremap <tab> :bnext<cr>
          nnoremap <S-tab> :bprev<cr>

          "" Like a boss, sudo AFTER opening the file to write
          cmap w!! w !sudo tee % >/dev/null

          let g:startify_lists = [
            \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
            \ { 'type': 'sessions',  'header': ['   Sessions']       },
            \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      }
            \ ]

          let g:startify_bookmarks = [
            \ '~/.local/share/src',
            \ ]

          let g:airline_theme='bubblegum'
          let g:airline_powerline_fonts = 1
        '';
    };

    # ----------------------------
    # -- Terminal configuration --
    # ----------------------------
    alacritty = {
      enable = true;
      settings = {
        cursor = {
          style = "Underline";
        };

        window = {
          opacity = 0.5;
          blur = true;
          padding = {
            x = 8;
            y = 8;
          };
          dynamic_padding = true;
          title = "Terminal";
          class = {
            instance = "Alacritty";
            general = "Alacritty";
          };
        };

        font = {
          normal = {
            family = "MonaspiceKr Nerd Font Mono";
            style = "Regular";
          };
          size = lib.mkMerge [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 10)
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 14)
          ];
        };

        colors = {
          primary = {
            background = "0x1f2528";
            foreground = "0xc0c5ce";
          };

          normal = {
            black = "0x1f2528";
            red = "0xec5f67";
            green = "0x99c794";
            yellow = "0xfac863";
            blue = "0x6699cc";
            magenta = "0xc594c5";
            cyan = "0x5fb3b3";
            white = "0xc0c5ce";
          };

          bright = {
            black = "0x65737e";
            red = "0xec5f67";
            green = "0x99c794";
            yellow = "0xfac863";
            blue = "0x6699cc";
            magenta = "0xc594c5";
            cyan = "0x5fb3b3";
            white = "0xd8dee9";
          };
        };
      };
    };

    wezterm = {
      enable = true;
      enableZshIntegration = isZsh;
      extraConfig = # lua
        ''
          local wezterm = require("wezterm")

          local config = wezterm.config_builder()
          local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

          -- config.font = wezterm.font("MonaspiceKr Nerd Font")
          config.font = wezterm.font_with_fallback({ "MonaspiceKr Nerd Font", "Monaspace Krypton" })

          config.font_size = 13
          config.color_scheme = "Tokyo Night"

          config.default_cursor_style = "SteadyUnderline"

          -- Window
          config.window_decorations = "RESIZE"
          -- config.window_decorations = "RESIZE | TITLE"
          config.window_background_opacity = 0.9
          config.macos_window_background_blur = 30

          config.command_palette_bg_color = "#1A1B26"
          config.command_palette_fg_color = "#C0CAF5"

          -- Tab bar
          --
          -- This errors out, apply tab defaults manually
          -- tabline.apply_to_config(config)
          config.enable_tab_bar = true
          config.use_fancy_tab_bar = false
          config.show_tab_index_in_tab_bar = false
          config.switch_to_last_active_tab_when_closing_tab = true

          tabline.setup({
            options = {
              icons_enabled = true,
              theme = "tokyonight_moon",
              section_separators = {
                left = "",
                right = "", -- Removed all separators to reduce padding
              },
              component_separators = {
                left = "",
                right = "", -- Removed internal separators
              },
              tab_separators = {
                left = "",
                right = "", -- Made tab separators invisible to reduce spacing
              },
            },
            sections = {
              tabline_a = { "hostname", padding = 1 },
              tabline_b = { "" },
              tabline_c = { "" },
              tab_active = {
                { "index", padding = 1 },
                -- { "parent", padding =
                { "/", padding = 1 },
                { "cwd", padding = 1 },
                { "zoomed", padding = 1 },
              },
              tab_inactive = {
                { "index", padding = 1 },
                { "process", padding = 1 },
              },
              tabline_x = {
                { "ram", padding = 1 },
                { "cpu", padding = 1 },
              },
              tabline_y = {
                { "datetime", padding = 1 },
                { "battery", padding = 1 },
              },
              tabline_z = { "" },
            },
            extensions = {},
          })

          config.max_fps = 120

          -- Needed for Nix
          config.front_end = "WebGpu"

          return config
        '';
    };
  };
}
