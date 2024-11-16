{ pkgs, lib, variables, inputs, osConfig, ... }:

let
  inherit (variables) userName fullName email;

  # `osConfig` allows us to access nixos's `config` from home-manager
  homeDir = osConfig.users.users.${userName}.home;
  primaryKey = osConfig.age.secrets.primary.path;

  isFish = osConfig.shells.activeShell == "fish";
  isZsh = osConfig.shells.activeShell == "zsh";
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
          [ "--preview 'if test -d {}; eza --tree --all --level=3 --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end'" ]
        else
          [ "--preview 'if [ -d {} ]; then eza --tree --all --level=3 --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'" ];
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
          ratio = [ 1 3 4 ];
        };
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
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        sensible
        yank
        prefix-highlight
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'gold'
          '';
        }
        {
          plugin = resurrect; # Used by tmux-continuum

          # Use XDG data directory
          # https://github.com/tmux-plugins/tmux-resurrect/issues/348
          extraConfig = ''
            set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-pane-contents-area 'visible'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5' # minutes
          '';
        }
      ];
      terminal = "screen-256color";
      prefix = "C-x";
      escapeTime = 10;
      historyLimit = 50000;
      extraConfig = ''
        # Remove Vim mode delays
        set -g focus-events on

        # Enable full mouse support
        set -g mouse on

        # -----------------------------------------------------------------------------
        # Key bindings
        # -----------------------------------------------------------------------------

        # Unbind default keys
        unbind C-b
        unbind '"'
        unbind %

        # Split panes, vertical or horizontal
        bind-key x split-window -v
        bind-key v split-window -h

        # Move around panes with vim-like bindings (h,j,k,l)
        bind-key -n M-k select-pane -U
        bind-key -n M-h select-pane -L
        bind-key -n M-j select-pane -D
        bind-key -n M-l select-pane -R

        # Smart pane switching with awareness of Vim splits.
        # This is copy paste from https://github.com/christoomey/vim-tmux-navigator
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l
      '';
    };

    # -----------------------
    # -- Git configuration --
    # -----------------------
    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = fullName;
      userEmail = email;
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
      extraConfig = ''
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
      extraConfig = ''
        local wezterm = require("wezterm")

        local config = wezterm.config_builder()

        config.font = wezterm.font("MonaspiceKr Nerd Font")
        config.font_size = 13
        config.color_scheme = "Tokyo Night"

        config.default_cursor_style = "SteadyUnderline"
        config.front_end = "WebGpu"

        config.enable_tab_bar = false
        config.window_decorations = "RESIZE | TITLE"
        config.window_background_opacity = 0.9
        config.macos_window_background_blur = 30

        config.command_palette_bg_color = "#1A1B26"
        config.command_palette_fg_color = "#C0CAF5"

        config.max_fps = 120

        return config
      '';
    };
  };
}
