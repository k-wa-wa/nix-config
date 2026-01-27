{ pkgs, ... }: {
  imports = [ ../../modules/home-manager/common.nix ];

  home.stateVersion = "23.11";
  home.username = "watanabekouhei";
  home.homeDirectory = "/Users/watanabekouhei";

  # Macでのみ使いたいパッケージがあれば追加
  home.packages = with pkgs; [
  ];
}
