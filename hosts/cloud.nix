{ lib, ... }:
{
  networking.hostName = "cloud";
  
  services.xserver.videoDrivers = [ "modesetting" ];
  services.cloud-init.enable = true;
  
  networking.useDHCP = lib.mkDefault true;
}
