{ pkgs }:

with pkgs; [
  # General packages for development and system management
  alacritty
  bash-completion
  # btop
  coreutils
  fastfetch
  openssh
  # sqlite
  wget
  nurl
  nil
  alejandra
  # zip
  neovim
  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2

  gh
  # Cloud-related tools and SDKs
  # docker
  # docker-compose

  # Media-related packages
  # emacs-all-the-icons-fonts
  # dejavu_fonts
  # ffmpeg
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji
  meslo-lgs-nf
  (pkgs.nerdfonts.override { fonts = [ "Monaspace"]; })

  # Node.js development tools
  nodePackages.npm # globally install npm
  nodePackages.prettier
  nodejs

  # Text and terminal utilities
  jetbrains-mono
  jq
  ripgrep
  tmux
  lunarvim
  # unrar
  # unzip
]
