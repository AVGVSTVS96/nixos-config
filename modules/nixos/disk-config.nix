_: {
  # USAGE in your configuration.nix.
  # Update devices to match your hardware.
  # {
  #  imports = [ ./disko-config.nix ];
  #  disko.devices.disk.main.device = "/dev/sda";
  # }
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Device is overwritten with argument for disko-install in the install script
        device = "/dev/disk/by-id/some-disk-id";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
