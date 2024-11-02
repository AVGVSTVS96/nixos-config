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
        user = "bassim-nix";
        email = "bassim101@gmail.com";
        fullName = "Bassim Shahidy";
        hostName.nixos = "nixos";
        hostName.vm = "nixos-vm";
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
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName}
        '')}/bin/${scriptName}";
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
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems 
        (system: darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs // { inherit variables; };
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = variables.user;
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

      # nixosConfigurations = {
      #   nixos = nixpkgs.lib.nixosSystem {
      #     system = "x86_64-linux";
      #     specialArgs = inputs // { inherit variables; };
      #     modules = [
      #       disko.nixosModules.disko
      #       home-manager.nixosModules.home-manager {
      #         home-manager = {
      #           extraSpecialArgs = { inherit variables; };
      #           useGlobalPkgs = true;
      #           useUserPackages = true;
      #           users.${variables.user} = import ./modules/nixos/home-manager.nix;
      #         };
      #       }
      #       ./hosts/nixos
      #     ];
      #   };
      #
      #   vm = nixpkgs.lib.nixosSystem {
      #     system = "x86_64-linux";
      #     specialArgs = inputs // { inherit variables; };
      #     modules = [
      #       disko.nixosModules.disko
      #       home-manager.nixosModules.home-manager {
      #         home-manager = {
      #           extraSpecialArgs = { inherit variables; };
      #           useGlobalPkgs = true;
      #           useUserPackages = true;
      #           users.${variables.user} = import ./modules/nixos/home-manager.nix;
      #         };
      #       }
      #       ./hosts/vm
      #     ];
      #   };
      # };

    #   nixosConfigurations = {
    #   nixos = nixpkgs.lib.genAttrs linuxSystems (system: nixpkgs.lib.nixosSystem {
    #     inherit system;
    #     specialArgs = inputs // { inherit variables; };
    #     modules = [
    #       disko.nixosModules.disko
    #       home-manager.nixosModules.home-manager {
    #         home-manager = {
    #           extraSpecialArgs = { inherit variables; };
    #           useGlobalPkgs = true;
    #           useUserPackages = true;
    #           users.${variables.user} = import ./modules/nixos/home-manager.nix;
    #         };
    #       }
    #       ./hosts/nixos
    #     ];
    #   });
    #
    #   vm = nixpkgs.lib.genAttrs linuxSystems (system: nixpkgs.lib.nixosSystem {
    #     inherit system;
    #     specialArgs = inputs // { inherit variables; };
    #     modules = [
    #       disko.nixosModules.disko
    #       home-manager.nixosModules.home-manager {
    #         home-manager = {
    #           extraSpecialArgs = { inherit variables; };
    #           useGlobalPkgs = true;
    #           useUserPackages = true;
    #           users.${variables.user} = import ./modules/nixos/home-manager.nix;
    #         };
    #       }
    #       ./hosts/vm
    #     ];
    #   });
    # };
      
    nixosConfigurations = 
      let
        mkHost = host: system: nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs // { inherit variables; };
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager {
              home-manager = {
                extraSpecialArgs = { inherit variables; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${variables.user} = import ./modules/nixos/home-manager.nix;
              };
            }
            ./hosts/${host}
          ];
        };
      in
      {
        "nixos-x86_64" = mkHost "nixos" "x86_64-linux";
        "nixos-aarch64" = mkHost "nixos" "aarch64-linux";
        "vm-x86_64" = mkHost "vm" "x86_64-linux";
        "vm-aarch64" = mkHost "vm" "aarch64-linux";
      };

    };
}
