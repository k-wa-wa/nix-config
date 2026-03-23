{ pkgs, ... }: {
  imports = [
    ../../modules/home-manager/core
  ];

  home.stateVersion = "23.11";
  home.username = "koheiwatanabe";
  home.homeDirectory = "/Users/koheiwatanabe";
}
