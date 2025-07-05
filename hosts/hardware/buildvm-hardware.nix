# hosts/hardware/buildvm-hardware.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Virtio drivers
  boot.kernelModules     = [ "virtio_blk" "virtio_pci" "virtio_net" ];
  boot.initrd.kernelModules = [ "virtio_blk" "virtio_pci" "virtio_net" ];

  networking.useDHCP = lib.mkDefault true;
  virtualisation.qemuGuest.enable = lib.mkDefault true;
}
