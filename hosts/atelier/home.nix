# atelier (nuage-cluster の Orca サーバー) の nixos ユーザーの環境。
#
# nuage-cluster が home-manager の NixOS モジュールとして読み込む (homeModules.atelier)。
# ユーザー名・ホームディレクトリ・nixpkgs は NixOS 側から渡される。
# システム (nix-ld・Orca の常駐・autopilot5・エージェント用のツール) は nuage-cluster が持つ。
{ lib, ... }:
{
  imports = [
    ../../modules/home-manager/core
    ../../modules/home-manager/k8s
    ../../modules/home-manager/iac
  ];

  home.stateVersion = "26.05";

  # git の名前とメールは置かない。atelier の commit は bot として行う (nuage-cluster の setup.sh が設定する)。
  # ai-agent モジュールも読み込まない。~/.claude/CLAUDE.md などは autopilot5 が置く。

  # Mac と見分けられるよう、プロンプトのディレクトリと tmux のステータスバーをパープルにする。
  programs.starship.settings.directory.style = lib.mkForce "#BD93F9";
  programs.tmux.extraConfig = lib.mkAfter ''
    set -g status-style "bg=#1a1b2e,fg=#cdd6f4"
    set -g status-left-style "bg=#BD93F9,fg=#1a1b2e,bold"
    set -g status-right-style "bg=#1a1b2e,fg=#6c7086"
  '';
}
