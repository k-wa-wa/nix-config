{ lib, pkgs, ... }: {
  imports = [
    ../../modules/home-manager/core
    ../../modules/home-manager/k8s
    ../../modules/home-manager/iac
  ];

  home.stateVersion = "24.11";
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  # NixOSであることが一目でわかるよう、ディレクトリの色をパープルに変更
  programs.starship.settings.directory.style = lib.mkForce "#BD93F9";

  # tmux ステータスバーの色を NixOS 用パープル系に上書き
  programs.tmux.extraConfig = lib.mkAfter ''
    set -g status-style "bg=#1a1b2e,fg=#cdd6f4"
    set -g status-left-style "bg=#BD93F9,fg=#1a1b2e,bold"
    set -g status-right-style "bg=#1a1b2e,fg=#6c7086"
  '';

  programs.git.settings.user = {
    name = "Kohei Watanabe";
    email = "sek.ohei.w0822@icloud.com";
  };
}
