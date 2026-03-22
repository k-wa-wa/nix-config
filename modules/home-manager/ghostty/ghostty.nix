{ pkgs, ... }: {
  home.packages = with pkgs; [
    ghostty-bin
  ];

  xdg.configFile."ghostty/config".source = ./config;
}
