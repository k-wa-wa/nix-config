{ pkgs, unstablePkgs, ... }: {
  home.packages = [
    unstablePkgs.ghostty-bin
  ];

  xdg.configFile."ghostty/config".source = ./config;
}
