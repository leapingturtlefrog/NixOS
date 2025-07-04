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
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, flake-utils, nix-editor, nixos-generators, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; }; };
      nixEditorPkg = nix-editor.packages.${system}.default;
      
      # makeHost { name = "laptop"; label = "nixosroot-01"; }
      makeHost = { name, label }: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./common.nix
          ./hosts/${name}.nix
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
        
        specialArgs = { inherit label; };
      };
    in
    let 
        alexhpSystem = makeHost { name = "alexhp"; label = "nixosroot-01"; };
        buildvmSystem = makeHost { name = "buildvm"; label = "nixosroot-02"; };
        cloudSystem = makeHost { name = "cloud"; label = "nixosroot-03"; };
    in
    {
      nixosConfigurations = {
        alexhp = alexhpSystem;
        buildvm = buildvmSystem;
        cloud = cloudSystem;
      };
      
      packages.buildvm-image = buildvmSystem.config.system.build.qcow;
      
      devShells.default = pkgs.mkShell {
        buildInputs = [ pkgs.git pkgs.btop ];
      };
    });
}
