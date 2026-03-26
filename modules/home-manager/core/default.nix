{ pkgs, unstablePkgs, ... }: {
  imports = [
    ./git.nix
    ./zsh.nix
    ./tmux.nix
    ./neovim.nix

    ./golang.nix
  ];

  programs.home-manager.enable = true; # Home Manager自身を管理

  home.packages = with pkgs; [
    # システム管理・モニタリング
    htop
    fastfetch    # システム情報の表示

    # 開発・生産性向上
    git
    ghq
    ripgrep
    fzf
    eza # ls のモダンな代替
    bat # cat のモダンな代替（シンタックスハイライト付）
    jq
    yq
    tree
    gnumake
    docker

    curl
    wget

    # ネットワーク・システム管理
    lsof
    dnsutils # dig, nslookup 等

    # Nodejs
    unstablePkgs.nodejs_24

    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  fonts.fontconfig.enable = true;
}
