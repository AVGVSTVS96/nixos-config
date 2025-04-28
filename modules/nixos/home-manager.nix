{ variables, inputs, ... }:

let
  inherit (variables) userName;
in
{
  home-manager = {
    extraSpecialArgs = { inherit variables inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${userName} =
      { pkgs, config, lib, ... }: {
        home = {
          enableNixpkgsReleaseCheck = false;
          username = "${userName}";
          homeDirectory = "/home/${userName}";
          stateVersion = "21.05";
        };

        imports = [
          ./files.nix
          ../shared/programs.nix
        ];

        # Use a dark theme
        gtk = {
          enable = true;
          iconTheme = {
            name = "Adwaita-dark";
            package = pkgs.adwaita-icon-theme;
          };
          theme = {
            name = "Adwaita-dark";
            package = pkgs.adwaita-icon-theme;
          };
        };
      };
  };
}
