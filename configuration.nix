# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
let
  rootDev = "/dev/disk/by-uuid/11178f69-99a0-46bb-84e2-f2d579a2c599";
in
{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "alexhp"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.a = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    curl
    google-chrome
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
  
  
  # Added,
  fileSystems."/" = {
    device = rootDev;
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device = rootDev;
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };

  fileSystems."/c" = {
    device = rootDev;
    fsType = "btrfs";
    options = [ "subvol=@c" "compress=zstd" "noatime" ];
  };

  fileSystems."/vms" = {
    device = rootDev;
    fsType = "btrfs";
    options = [ "subvol=@vms" "nodatacow" "compress=no" "noatime" ];
  };

  fileSystems."/experiments" = {
    device = rootDev;
    fsType = "btrfs";
    options = [ "subvol=@experiments" "compress=zstd" "noatime" ];
  };

  fileSystems."/extra0" = {
    device = rootDev;
    fsType = "btrfs";
    options = [ "subvol=@extra0" "compress=zstd" "noatime" ];
  };

  fileSystems."/extra1" = {
    device = rootDev;
    fsType = "btrfs";
    options = [ "subvol=@extra1" "compress=zstd" "noatime" ];
  };

  fileSystems."/extra2" = {
    device = rootDev;
    fsType = "btrfs";
    options = [ "subvol=@extra2" "compress=zstd" "noatime" ];
  };
  
  # Swap device
  swapDevices = [ { device = "/dev/disk/by-uuid/24412e02-60a9-44fc-8d53-0d1ec4cc9db7"; } ];
  
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.graphics = {
    enable            = true;
    extraPackages     = with pkgs; [ vulkan-loader ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
  };
  
  boot.kernelParams = [ "btrfs.enospc_debug" ];
  
  # Firewall: blocks all incoming traffic by default.
  # – Set `enable = true` to turn on the firewall.
  # – `allowedTCPPorts` is a list of TCP ports you want to open (e.g. 22 for SSH, 80 for HTTP, 443 for HTTPS).
  #    To discover which port a service uses, check its documentation or run:
  #      ss -tulpn    # shows all listening TCP/UDP ports and their owning processes
  # – `allowedUDPPorts` is a list of UDP ports to open (e.g. 53 for DNS).
  # – Whenever you add/enable a new network service, add its port number here and run:
  #      sudo nixos-rebuild switch
  networking.firewall.enable        = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ];
  
  services.pipewire.alsa.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

