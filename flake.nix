{
  description = "alexhp NixOS fleet + Home Manager";

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
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        nixEditorPkg = nix-editor.packages.${system}.default;
        diskLabel = "DISK_LABEL_TO_DO";
        
        commonModules = [
          ./common.nix
          
          ({ ... }: {
            environment.systemPackages = with pkgs; [ nixEditorPkg ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.users.a         = import ./home/a.nix;
          }
        ];
      in
      {
        devShells.${system}.default = pkgs.mkShell {
          buildInputs = [ pkgs.git pkgs.btop ];
        };
        
        nixosConfigurations = {
          alexhp = pkgs.lib.nixosSystem {
            inherit system;
            modules = commonModules ++ [ ./hosts/alexhp.nix ];
            specialArgs = { label = diskLabel; };
          };
          
          buildvm = pkgs.lib.nixosSystem {
            inherit system;
            modules = commonModules ++ [ ./hosts/buildvm.nix ];
            specialArgs = { label = diskLabel; };
          };
        };
      }
    );
}
