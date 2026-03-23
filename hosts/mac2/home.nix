{ pkgs, ... }: {
  imports = [
    ../../modules/home-manager/essentials/all.nix
  ];

  home.stateVersion = "23.11";
  home.username = "koheiwatanabe";
  home.homeDirectory = "/Users/koheiwatanabe";
}
