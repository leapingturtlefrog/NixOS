{
  description = "alexhp NixOS fleet + Home-Manager";

  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url     = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url      = "github:numtide/flake-utils";
    nix-editor.url       = "github:snowfallorg/nix-editor";
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  #####################################################################
  # Shared helpers
  #####################################################################
  outputs = inputs@{ self, nixpkgs, home-manager, flake-utils
                   , nix-editor, nixos-generators, ... }:

  let
    # dummy XML formatter so Labwc evaluates
    xmlOverlay = final: prev: {
      formats = prev.formats // { xml = prev.formats.yaml; };
    };

    # Build one host
    makeHost = { system, name, label }:
      let
        pkgs         = import nixpkgs {
                         inherit system;
                         overlays = [ xmlOverlay ];
                         config   = { allowUnfree = true; };
                       };
        nixEditorPkg = nix-editor.packages.${system}.default;
      in
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          # expose the overlayed pkgs set to every downstream module
          ({ ... }: {
            nixpkgs.pkgs     = pkgs;
            nixpkgs.overlays = [ xmlOverlay ];
          })

          ./common.nix
          ./hosts/${name}.nix
          ({ ... }: { environment.systemPackages = with pkgs; [ nixEditorPkg ]; })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.users.a         = import ./home/a.nix;
          }
        ];

        specialArgs = { inherit label; };   # pkgs no longer passed here
      };

  #####################################################################
  # Top-level nixosConfigurations
  #####################################################################
  in {
    nixosConfigurations = {
      alexhp  = makeHost { system = "x86_64-linux"; name = "alexhp";  label = "nixosroot-01"; };
      buildvm = makeHost { system = "x86_64-linux"; name = "buildvm"; label = "nixosroot-02"; };
      cloud   = makeHost { system = "x86_64-linux"; name = "cloud";   label = "nixosroot-03"; };
    };
  }
  #####################################################################
  # Per-system outputs
  #####################################################################
  // flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
  let
    # same pkgs used for dev-shell and QCOW generator
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ xmlOverlay ];
      config   = { allowUnfree = true; };
    };
    nixEditorPkg = nix-editor.packages.${system}.default;
  in
  {
    ##############################################################
    # QCOW image identical to buildvm configuration
    ##############################################################
    packages.buildvm-image =
      nixos-generators.nixosGenerate {
        inherit system;
        format = "qcow";

        modules = [
          # make qcow.nix use the XML overlay and our pkgs
          ({ ... }: {
            nixpkgs.pkgs     = pkgs;
            nixpkgs.overlays = [ xmlOverlay ];
          })

          ./common.nix
          ./hosts/buildvm.nix
          ({ ... }: { environment.systemPackages = with pkgs; [ nixEditorPkg ]; })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.users.a         = import ./home/a.nix;
          }

          # override qcow.nix’s ext4 root
          ({ lib, label, ... }: {
            fileSystems."/".device = lib.mkForce "/dev/disk/by-label/${label}";
            fileSystems."/".fsType = lib.mkForce "btrfs";
          })
        ];

        specialArgs = { label = "nixosroot-02"; };
      };

    ##############################################################
    # Dev shell
    ##############################################################
    devShells.default = pkgs.mkShell {
      buildInputs = [ pkgs.git pkgs.btop ];
    };
  });
}

