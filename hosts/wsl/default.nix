{ variables, ... }:
let
  inherit (variables) userName timeZone;

  hostName = variables.hostName.wsl;

  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/HJtpzR8Ip/ma38TQSj1Uvl/rvvN3ogYsTbD8ERErL user@wsl-desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/ppkYVMKZ+N/BINzfEvO8mWZMtx/UgbrHf5i4wpb77 root@wsl-desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDeABSDuLTLywoc86FINzl/YsUfJ0yqPhPan4DUzT2ME user@wsl-laptop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBZXcr0Kw5hXygTBzIbeh6RkBK+DifY2C8ywiIGC1jdj root@wsl-laptop"
  ];
in
{
  networking = { inherit hostName; };
  time = { inherit timeZone; };
  system.stateVersion = "24.11";

  services.openssh.enable = true;

  shells.fish.enable = true;
  shells.zsh.enable = false;

  environment = {
    pathsToLink = [ "/share/fish" ];
    enableAllTerminfo = true;
  };

  security.sudo.wheelNeedsPassword = false;

  users.users.${userName} = {
    home = "/home/${userName}";
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = keys;
  };

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
    defaultUser = userName;
    startMenuLaunchers = true;
  };
}
