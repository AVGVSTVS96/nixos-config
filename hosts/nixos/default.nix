{ variables, ... }:

let
  hostName = variables.hostName.nixos;
in
{
  imports = [
    ../common.nix
  ];

  shells.zsh.enable = true;
  shells.fish.enable = false;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # TODO: This should be in a system specific file
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

  # Enable sound
  # sound.enable = true;

  # hardware.nvidia.modesetting.enable = true;

  # Enable Xbox support
  # hardware.xone.enable = true;


  system.stateVersion = "21.05"; # Don't change this
}
