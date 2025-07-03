{ config, pkgs, ... }:
{
  home.username = "a";
  home.homeDirectory = "/home/a";
  home.stateVersion = "25.05";

  programs.zsh.enable = true;
  
  programs.git = {
    enable = true;
    userName  = "leapingturtlefrog";
    userEmail = "alexanderaridgides@gmail.com";
  };
  
  programs.firefox.enable = true;

  home.packages = with pkgs; [
    neovim htop fzf bat tree wget curl
    google-chrome gh
  ];
  
  xdg.enable = true;
}

