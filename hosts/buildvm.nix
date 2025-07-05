{ lib, ... }:
{
  networking.hostName = "buildvm";
  
  services.xserver.videoDrivers = [ "modesetting" ];
  
  services.qemuGuest.enable = true;
  
  # VM-specific user configuration
  users.users.a = {
    password = "buildvm";
    # Enable password-less sudo for VM convenience
    extraGroups = [ "wheel" ];
  };
  
  # Allow wheel group to use sudo without password in VM
  security.sudo.wheelNeedsPassword = false;
}
