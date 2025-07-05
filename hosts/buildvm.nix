{ lib, ... }:
{
  networking.hostName = "buildvm";
  
  services.xserver.videoDrivers = [ "modesetting" ];
  
  services.qemuGuest.enable = true;
}
