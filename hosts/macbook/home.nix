{ pkgs, ... }: {
  imports = [
    ../../modules/home-manager/essentials/all.nix
    ../../modules/home-manager/private/all.nix

    ../../modules/home-manager/additional/ghostty/ghostty.nix
  ];

  home.stateVersion = "23.11";
  home.username = "watanabekouhei";
  home.homeDirectory = "/Users/watanabekouhei";
}
