{ variables, pkgs, lib, ... }:
let
  inherit (variables) userName;
in
{
  imports = [
    ../modules/nixos/home-manager.nix
    ../modules/nixos/disk-config.nix
    ../modules/shared/cachix
    ../modules/shared
  ];

  shells.zsh.enable = true;
  shells.fish.enable = false;

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
    ];
    # openssh.authorizedKeys.keys = keys;
  };

  programs = {
    zsh.enable = true;
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;
  };

  # users.users.root = {
  #   openssh.authorizedKeys.keys = keys;
  # };

  time.timeZone = "America/New_York";

  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb.layout = "us";
      # xkbOptions = "ctrl:nocaps";

      # Uncomment these for AMD or Nvidia GPU
      # boot.initrd.kernelModules = [ "amdgpu" ];
      # videoDrivers = [ "amdgpu" ];
      # videoDrivers = [ "nvidia" ];

      # Uncomment for Nvidia GPU
      # This helps fix tearing of windows for Nvidia cards
      # screenSection = ''
      #   Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #   Option       "AllowIndirectGLXProtocol" "off"
      #   Option       "TripleBuffer" "on"
      # '';
    };

    # Better support for general peripherals
    libinput.enable = true;

    # Let's be able to SSH into this machine
    openssh.enable = true;

    # Enable CUPS to print documents
    # printing.enable = true;
    # printing.drivers = [ pkgs.brlaser ]; # Brother printer driver

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
  };

  # Sound working in utm vm without this
  # sound.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    # Uncomment for AMD GPU
    # initrd.kernelModules = [ "amdgpu" ];
    # kernelModules = [ "uinput" ];
  };

  # The global useDHCP flag is deprecated, set per network interface per system
  networking.useDHCP = lib.mkDefault true;

  # Video support
  hardware.graphics.enable = true;
  # hardware.pulseaudio.enable = true;
  # hardware.nvidia.modesetting.enable = true;

  # Enable Xbox support
  # hardware.xone.enable = true;

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

  # Add docker daemon
  # virtualisation = {
  #   docker = {
  #     enable = true;
  #     logDriver = "json-file";
  #   };
  # };

  fonts.packages = with pkgs; [
    dejavu_fonts
    emacs-all-the-icons-fonts
    feather-font # from overlay
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-emoji
  ];

  environment.systemPackages = with pkgs; [
    gitAndTools.gitFull
    inetutils
    gnome-tweaks
  ];

  system.stateVersion = "21.05"; # Don't change this
}
