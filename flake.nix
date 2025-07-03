{
  description = "alexhp NixOS + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }@inputs:
  let
    system = "x86_64-linux";
    pkgs   = import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    # build/switch with: sudo nixos-rebuild switch --flake .#alexhp
    nixosConfigurations.alexhp = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix

        # Home-Manager as a NixOS module
        home-manager.nixosModules.home-manager
        {
          home-manager.users.a = {
            programs.home-manager.enable = true;
            home.stateVersion = "25.05";   # bump if you upgrade releases later
          };
        }
      ];
    };

    # dev shell: nix develop
    devShells.${system}.default =
      pkgs.mkShell { buildInputs = [ pkgs.git pkgs.btop ]; };
  };
}

