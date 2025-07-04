{ ... }: {
  networking.hostName = "alexhp";
  
  imports = [
    ./hardware/alexhp-hardware.nix
  ];
  
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware = {
    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    graphics = { extraPackages = with pkgs; [ vulkan-loader ]; };
  };
  
  nixpkgs.config = { nvidia.acceptLicense = true; };
  
  environment.systemPackages = [ ];
}
