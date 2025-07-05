{ pkgs, lib, config, label, ... }: {
  system.stateVersion = "25.05";
  
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  
  fileSystems = {
    "/" = { device = "/dev/disk/by-label/${label}"; fsType = "btrfs"; options = [ "subvol=@" "compress=zstd" "noatime" "space_cache=v2" ]; };
    "/home" = { device = "/dev/disk/by-label/${label}"; fsType = "btrfs"; options = [ "subvol=@home" "compress=zstd" "noatime" ]; };
    "/c" = { device = "/dev/disk/by-label/${label}"; fsType = "btrfs"; options = [ "subvol=@c" "compress=zstd" "noatime" ]; };
    "/vms" = { device = "/dev/disk/by-label/${label}"; fsType = "btrfs"; options = [ "subvol=@vms" "nodatacow" "compress=no" "noatime" ]; };
    "/experiments" = { device = "/dev/disk/by-label/${label}"; fsType = "btrfs"; options = [ "subvol=@experiments" "compress=zstd" "noatime" ]; };
    "/extra0" = { device = "/dev/disk/by-label/${label}"; fsType = "btrfs"; options = [ "subvol=@extra0" "compress=zstd" "noatime" ]; };
    "/extra1" = { device = "/dev/disk/by-label/${label}"; fsType = "btrfs"; options = [ "subvol=@extra1" "compress=zstd" "noatime" ]; };
    "/extra2" = { device = "/dev/disk/by-label/${label}"; fsType = "btrfs"; options = [ "subvol=@extra2" "compress=zstd" "noatime" ]; };
    "/boot" = { device = "/dev/disk/by-label/${label}-esp"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
  };
  swapDevices = [ { device = "/dev/disk/by-label/${label}-swap"; } ];
  
  users.users.a = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb.layout = "us";
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
  
  networking = {
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
  
  environment.systemPackages = with pkgs; [
    git vim
  ];
  
  nixpkgs.config = { allowUnfree = true; };
}

