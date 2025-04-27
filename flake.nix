{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";

    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;
    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    ragenix.url = "github:yaxitech/ragenix";
    ragenix.inputs.nixpkgs.follows = "nixpkgs";

    tokyonight.url = "github:mrjones2014/tokyonight.nix";
  };

  outputs =
    {
      self,
      darwin,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      home-manager,
      nixpkgs,
      disko,
      tokyonight,
      ragenix,
    }@inputs:
    let
      variables = {
        # email is encrypted to .config/git/user_email and included in config
        userName = "bassim-nix";
        fullName = "Bassim Shahidy";
        hostName = {
          nixos = "nixos";
          vm = "nixos-vm";
          darwin = "nixos-mac";
        };
      };
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      pkgsForSystem = system: import nixpkgs { inherit system; };

      devShell =
        system:
        let
          pkgs = pkgsForSystem system;
        in
        {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                bashInteractive
                git
              ];
              shellHook = ''
                export EDITOR=nvim
              '';
            };
        };

      mkApp =
        scriptName: system:
        let
          pkgs = pkgsForSystem system;
          scriptContent = builtins.readFile (./. + "/apps/${system}/${scriptName}");
        in
        {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = scriptName;
              runtimeInputs = [ pkgs.git ];
              text = scriptContent;
            }
          }/bin/${scriptName}";
        };

      mkAppsFromDir =
        system:
        let
          inherit (builtins) readDir attrNames listToAttrs;
        in
        listToAttrs (
          map (name: {
            inherit name;
            value = mkApp name system;
          }) (attrNames (readDir ./apps/${system}))
        );
    in
    {
      devShells = forAllSystems devShell;
      apps = forAllSystems mkAppsFromDir;

      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
        system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit variables inputs; };
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            ragenix.darwinModules.default
            ./hosts/darwin
          ];
        }
      );

      nixosConfigurations =
        let
          mkNixos =
            host: system:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit variables inputs; };
              modules = [
                disko.nixosModules.disko
                home-manager.nixosModules.home-manager
                ragenix.nixosModules.default
                ./hosts/${host}
              ];
            };
        in
        {
          "nixos-x86_64" = mkNixos "nixos" "x86_64-linux";
          "nixos-aarch64" = mkNixos "nixos" "aarch64-linux";
          "vm-x86_64" = mkNixos "vm" "x86_64-linux";
          "vm-aarch64" = mkNixos "vm" "aarch64-linux";
          # "wsl-x86_64" = mkNixos "wsl" "x86_64-linux";
          # "wsl-aarch64" = mkNixos "wsl" "aarch64-linux";
        };
    };
}
