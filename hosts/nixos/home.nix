{ lib, pkgs, ... }: {
  imports = [ ../../modules/home-manager/common.nix ];

  home.stateVersion = "24.11";
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  # NixOSであることが一目でわかるよう、ディレクトリの色をパープルに変更
  programs.starship.settings.directory.style = lib.mkForce "#BD93F9";
}
