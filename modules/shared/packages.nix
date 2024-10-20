{ pkgs }:

with pkgs; [
]
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
    # age-plugin-yubikey
    # libfido2

    # Media-related packages
    # ffmpeg

    # Fonts
    # emacs-all-the-icons-fonts
    # dejavu_fonts
    font-awesome
    hack-font
    noto-fonts
    noto-fonts-emoji
    meslo-lgs-nf
    jetbrains-mono
    (pkgs.nerdfonts.override { fonts = [ "Monaspace" ]; })

    # Git
    gh

    # Development tools
    nodejs
    nodePackages.npm
    nodePackages.pnpm

    cargo

    # Nix Utils
    nurl
    nil

    # Text and terminal utilities
    jq
    ripgrep
    tmux
    lunarvim
    neovim
