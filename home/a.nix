{ config, pkgs, ... }:
{
  home = {
    username = "a";
    homeDirectory = "/home/a";
    stateVersion = "25.05";
    packages = with pkgs; [
      neovim htop fzf bat tree wget curl
      google-chrome gh
    ];
    sessionPath = [ "/etc/nixos/home/scripts" ];
  };
  
  programs = {
    bash.enable = true;
    zsh.enable = true;
    firefox.enable = true;
  };
  
  xdg.enable = true;
}

