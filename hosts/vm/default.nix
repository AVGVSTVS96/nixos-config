{ pkgs, variables, ... }:

let
  inherit (variables) userName;
  hostName = variables.hostName.vm;
in
{
  imports = [
    ../../modules/nixos/home-manager.nix
    ../../modules/nixos/disk-config.nix
    ../../modules/shared/cachix
    ../../modules/shared
  ];

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
    ];
    shell = pkgs.zsh;
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

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    inherit hostName;
    useDHCP = false;
    interfaces."%INTERFACE%".useDHCP = true;
  };

  # Manages keys and such
  programs = {
    zsh.enable = true;
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;
  };

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    xserver = {
      enable = true;
      videoDrivers = [ "qxl" ];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb.layout = "us";
      # xkbOptions = "ctrl:nocaps";
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

  hardware.graphics.enable = true;
  # hardware.pulseaudio.enable = true;
  # hardware.nvidia.modesetting.enable = true;

  # Enable Xbox support
  # hardware.xone.enable = true;
  

  # Add docker daemon
  # virtualisation = {
  #   docker = {
  #     enable = true;
  #     logDriver = "json-file";
  #   };
  # };
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
    spice-vdagent
    gnome-tweaks
  ];

  system.stateVersion = "21.05"; # Don't change this
}
