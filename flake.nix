{
  description = "alexhp NixOS + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nix-editor.url = "github:snowfallorg/nix-editor";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, nix-editor, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = pkgs.lib;
      nixEditorPkg = nix-editor.packages.${system}.default;
    in {
      nixosConfigurations.alexhp = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ ... }: { imports = [ ./common.nix ]; _module.args.label = "nixosroot"; })
          ./hosts/hardware/alexhp-hardware.nix
          ./hosts/alexhp.nix
          
          ({ ... }: {
            environment.systemPackages = with pkgs; [ nixEditorPkg ];
          })

          home-manager.nixosModules.home-manager
          ({ config, pkgs, lib, ... }: {
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.users.a         = import ./home/a.nix;
          })
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.git pkgs.btop ];
      };
    };
}
