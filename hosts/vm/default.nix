{ pkgs, variables, ... }:

let
  hostName = variables.hostName.vm;
in
{
  imports = [
    ../nixos-common.nix
  ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    inherit hostName;
    useDHCP = false;
    interfaces."%INTERFACE%".useDHCP = true;
  };

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    xserver = {
      videoDrivers = [ "qxl" ];
      # xkbOptions = "ctrl:nocaps";
    };
  };

  environment.systemPackages = with pkgs; [
    spice-vdagent
  ];
}
