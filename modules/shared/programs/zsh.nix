{ config, pkgs, lib, ... }:

{
  oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "tokyonight_storm";
  };

  zsh = {
    enable = true;
    autocd = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    shellAliases = {
      g = "git";
      zrc = "nvim ~/.zshrc";
      szrc = "source ~/.zshrc";
      exz = "exec zsh";
      cl = "clear";
      nixswitch = "git add . && nix run .#build-switch";
      yz = "yazi";
      lg = "lazygit";
      l = "eza --git --icons=always --color=always --long --no-user --no-permissions --no-filesize --no-time";
      la = "eza --git --icons=always --color=always --long --no-user --no-permissions --no-filesize --no-time --all";
      ls = "l";
      lsa = "la";
      lsl = "eza --git --icons=always --color=always --long --no-user";
      ll = "eza --git --icons=always --color=always --long --no-user -all";
      lt = "eza --git --icons=always --color=always --long --no-user -all --tree --level=2" ;
      lt2 = "eza --git --icons=always --color=always --long --no-user -all --tree --level=3";
      lt3 = "eza --git --icons=always --color=always --long --no-user -all --tree --level=4";
      ltg = "eza --git --icons=always --color=always --long --no-user --tree --git-ignore";
      nvim = "lvim";
    };
    initExtra = ''
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
    plugins = [
      {
        name = "fzf-git-sh";
        src = pkgs.fzf-git-sh;
        file = "share/fzf-git-sh/fzf-git.sh";
      }
    ];
    initExtraFirst = ''
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

      export EDITOR=lvim
    '';
  };
}