{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;
    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    tokyonight.url = "github:mrjones2014/tokyonight.nix";
  };

  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, disko, tokyonight } @inputs:
    let
      variables = {
        email = "bassim101@gmail.com";
        userName = "bassim-nix";
        fullName = "Bassim Shahidy";
        hostName = {
          nixos = "nixos";
          vm = "nixos-vm";
          darwin = "nixos-mac";
        };
      };
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git ];
          shellHook = ''
            export EDITOR=vim
          '';
        };
      };
      mkApp = scriptName: system: {
        type = "app";
        program = "${
          (nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
            #!/usr/bin/env bash
            PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
            echo "Running ${scriptName} for ${system}"
            exec ${self}/apps/${system}/${scriptName}
          '')
        }/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
      };
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "rollback" = mkApp "rollback" system;
      };
    in
    {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps
        // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems 
        (system: darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit variables inputs; };
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              # TODO: Move to dedicated homebrew module incl. casks
              nix-homebrew = {
                user = variables.userName;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
        );

      nixosConfigurations = 
        let
          mkNixos = host: system: nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit variables inputs; };
            modules = [
              disko.nixosModules.disko
              home-manager.nixosModules.home-manager 
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
