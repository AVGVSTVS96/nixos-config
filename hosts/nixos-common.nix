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
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
    ];
    # openssh.authorizedKeys.keys = keys;
  };

  # users.users.root = {
  #   openssh.authorizedKeys.keys = keys;
  # };

  time.timeZone = "America/New_York";

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
  

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [{
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }];
      groups = [ "wheel" ];
    }];
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
}
