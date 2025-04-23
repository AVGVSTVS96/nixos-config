{ variables, ... }:

let
  hostName = variables.hostName.nixos;
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

  # hardware.nvidia.modesetting.enable = true;
}
