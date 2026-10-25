{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./zsh.nix
    # tmux (./tmux.nix) は使うホストだけが読み込む。atelier ではセッションを Orca が持つので使わない。

    ./mise.nix
    ./rust.nix
  ];

  programs.home-manager.enable = true; # Home Manager自身を管理

  home.packages = with pkgs; [
    # システム管理・モニタリング
    htop
    fastfetch # システム情報の表示

    # 開発・生産性向上
    git
    git-crypt
    gitleaks
    gh
    ghq
    ripgrep
    fzf
    eza # ls のモダンな代替
    bat # cat のモダンな代替（シンタックスハイライト付）
    jq
    yq
    nixfmt
    tree
    gnumake
    docker

    curl
    wget

    # ネットワーク・システム管理
    lsof
    dnsutils # dig, nslookup 等

    nodejs_24

    nerd-fonts.jetbrains-mono

    python311
    uv
  ];

  fonts.fontconfig.enable = true;
}
