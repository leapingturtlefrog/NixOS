# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
let
  rootDev = "/dev/disk/by-uuid/11178f69-99a0-46bb-84e2-f2d579a2c599";
in
{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  
  system.stateVersion = "25.05";
  
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  
  networking = {
    hostName = "alexhp";
    networkmanager.enable = true;
    # Firewall: blocks all incoming traffic by default.
    # – Set `enable = true` to turn on the firewall.
    # – `allowedTCPPorts` is a list of TCP ports you want to open (e.g. 22 for SSH, 80 for HTTP, 443 for HTTPS).
    #    To discover which port a service uses, check its documentation or run:
    #      ss -tulpn    # shows all listening TCP/UDP ports and their owning processes
    # – `allowedUDPPorts` is a list of UDP ports to open (e.g. 53 for DNS).
    # – Whenever you add/enable a new network service, add its port number here and run:
    #      sudo nixos-rebuild switch
    # networking.firewall.allowedUDPPorts = [ ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };
  
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb.layout = "us";
      videoDrivers = [ "nvidia" ];
    };
    printing.enable = true;
    libinput.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    openssh.enable = true;
  };
  
  users.users.a = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };
  
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
  };
  
  fileSystems."/" = { device = rootDev; fsType = "btrfs"; options = [ "subvol=@" "compress=zstd" "noatime" "space_cache=v2" ]; };
  fileSystems."/home" = { device = rootDev; fsType = "btrfs"; options = [ "subvol=@home" "compress=zstd" "noatime" ]; };
  fileSystems."/c" = { device = rootDev; fsType = "btrfs"; options = [ "subvol=@c" "compress=zstd" "noatime" ]; };
  fileSystems."/vms" = { device = rootDev; fsType = "btrfs"; options = [ "subvol=@vms" "nodatacow" "compress=no" "noatime" ]; };
  fileSystems."/experiments" = { device = rootDev; fsType = "btrfs"; options = [ "subvol=@experiments" "compress=zstd" "noatime" ]; };
  fileSystems."/extra0" = { device = rootDev; fsType = "btrfs"; options = [ "subvol=@extra0" "compress=zstd" "noatime" ]; };
  fileSystems."/extra1" = { device = rootDev; fsType = "btrfs"; options = [ "subvol=@extra1" "compress=zstd" "noatime" ]; };
  fileSystems."/extra2" = { device = rootDev; fsType = "btrfs"; options = [ "subvol=@extra2" "compress=zstd" "noatime" ]; };

  swapDevices = [ { device = "/dev/disk/by-uuid/24412e02-60a9-44fc-8d53-0d1ec4cc9db7"; } ];
  
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };
  
  hardware.graphics.extraPackages = with pkgs; [ vulkan-loader ];
}

