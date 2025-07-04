{ lib, ... }:
{
  networking.hostName = "buildvm";
  
  services.xserver.videoDrivers = [ "modesetting" ];
  
  virtualisation.qemuGuest.enable = true;
}
