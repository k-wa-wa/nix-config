{ pkgs, ... }: {
  imports = [ ../../modules/home-manager/common.nix ];

  home.stateVersion = "23.11";
  home.username = "watanabekouhei";
  home.homeDirectory = "/home/watanabekouhei";
}
