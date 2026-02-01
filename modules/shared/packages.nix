{ pkgs, variables, ... }:
let
  inherit (variables) userName;
in
{
  fonts.packages = [
    pkgs.nerd-fonts.monaspace
  ];

  home-manager.users.${userName} = {
    home.packages = with pkgs; [
      # General packages for development and system management
      alacritty
      bash-completion
      coreutils
      fastfetch
      openssh
      wget

      # Encryption and security tools
      age
      gnupg

      # Media-related packages
      # ffmpeg

      # Fonts
      font-awesome
      hack-font
      noto-fonts
      noto-fonts-emoji
      meslo-lgs-nf
      jetbrains-mono

      # Git
      gh
      graphite-cli

      # Development tools
      nodejs
      nodePackages.npm
      nodePackages.pnpm

      cargo

      # Nix Utils
      nurl
      nil
      nixfmt-rfc-style
      statix

      # Text and terminal utilities
      jq
      ripgrep
      lunarvim
      neovim
      tmux # Config managed via traditional tmux.conf + TPM
    ];
  };
}
