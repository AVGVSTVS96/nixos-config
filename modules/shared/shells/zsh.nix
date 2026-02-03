{
  pkgs,
  lib,
  config,
  variables,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkMerge
    optionalAttrs
    ;
  inherit (variables) userName;
  zsh = config.shells.zsh;
in
{
  # Enable zsh with:
  # shells.zsh.enable = true;

  # Set shell per host in:
  # hosts/<host>/default.nix or modules/<host>/home-manager.nix

  # Set shell for all hosts in:
  # modules/shared/default.nix

  options.shells.zsh = {
    enable = mkEnableOption "zsh shell";
  };

  config = mkIf zsh.enable {

    # Programs can conditionally enable shell specific integrations
    # by accessing `shells.activeShell`. For example:
    # `enableZshIntegration = config.shells.activeShell == "zsh";`
    shells.activeShell = "zsh";

    home-manager.users.${userName}.programs.zsh = {
      enable = true;
      dotDir = "${config.users.users.${userName}.home}/.config/zsh";
      autocd = false;
      autosuggestion.enable = true;
      enableCompletion = true;
      shellAliases = {
        # General aliases
        g   = "git";
        exz = "exec zsh";
        cl  = "clear";
        yz  = "yazi";
        lg  = "lazygit";
        # Nix aliases
        ns  = "git add . && nix run .#build-switch";
        nb  = "git add . && nix run .#build";
        # Eza aliases
        ls  = "eza --git --icons=always --color=always --long --no-user --no-permissions --no-filesize --no-time";
        lsa = "eza --git --icons=always --color=always --long --no-user --no-permissions --no-filesize --no-time --all";
        l   = "eza --git --icons=always --color=always --long --no-filesize";
        la  = "eza --git --icons=always --color=always --long --no-filesize -all";
        lt  = "eza --git --icons=always --color=always --long --no-filesize -all --tree --level=2";
        lt2 = "eza --git --icons=always --color=always --long --no-filesize -all --tree --level=3";
        lt3 = "eza --git --icons=always --color=always --long --no-filesize -all --tree --level=4";
        ltg = "eza --git --icons=always --color=always --long --no-filesize --tree --git-ignore";
      };
      plugins = [
        {
          name = "fzf-git-sh";
          src = pkgs.fzf-git-sh;
          file = "share/fzf-git-sh/fzf-git.sh";
        }
        {
          name = "fast-syntax-highlighting";
          src = pkgs.zsh-fast-syntax-highlighting;
          file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        }
      ];
      initContent =
        lib.mkOrder 500
          # bash
          ''
            if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
              . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
              . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
            fi

            # Define variables for directories
            export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
            export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
            export PATH=$HOME/.local/share/bin:$PATH

            # Remove history data we don't want to see
            export HISTIGNORE="pwd:ls:cd"
          ''
        // lib.mkOrder 1000
          # bash
          ''
            # Advanced customization of fzf options via _fzf_comprun function
            _fzf_comprun() {
              local command=$1
              shift

              case "$command" in
                cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
                export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
                ssh)          fzf --preview 'dig {}'                   "$@" ;;
                *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
              esac
            }


            # -- fzf with bat and eza previews --
            show_file_or_dir_preview='if [ -d {} ]; then eza --tree --all --level=3 --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'
            alias lspe="fzf --preview '$show_file_or_dir_preview'"
            alias lsp="fd --max-depth 1 --hidden --follow --exclude .git | fzf --preview '$show_file_or_dir_preview'"
          '';
    };

    # Set nix managed system shell
    environment.shells = [ pkgs.zsh ];
    programs.zsh.enable = true;

    # Make sure nix managed shell is used by default
    users = mkMerge [
      { users.${userName}.shell = pkgs.zsh; }

      (optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        # knownUsers may not be the best way to
        # setup nix managed shell in nix-darwin
        # https://github.com/LnL7/nix-darwin/issues/811#issuecomment-2227568956
        knownUsers = [ userName ];
        users.${userName}.uid = 501;
      })
    ];
  };
}
