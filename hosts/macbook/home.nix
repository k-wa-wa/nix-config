{ pkgs, ... }: {
  imports = [
    ../../modules/home-manager/common.nix
    ../../modules/home-manager/ghostty/ghostty.nix
  ];

  home.stateVersion = "23.11";
  home.username = "watanabekouhei";
  home.homeDirectory = "/Users/watanabekouhei";
}
