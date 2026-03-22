{ pkgs, ... }: {
  imports = [
    ./git.nix
    ./zsh.nix
    ./k8s.nix
    ./tofu.nix
  ];

  programs.home-manager.enable = true; # Home Manager自身を管理

  home.packages = with pkgs; [
    # システム管理・モニタリング
    htop
    fastfetch    # システム情報の表示

    # 開発・生産性向上
    git
    gh          # GitHub CLI
    ripgrep     # 超高速 grep
    fzf         # 曖昧検索
    eza         # ls のモダンな代替
    bat         # cat のモダンな代替（シンタックスハイライト付）
    jq          # JSON加工
    tree
    gnumake
    docker

    wget

    # Nodejs
    nodejs_24
  ];

  programs.go = {
    enable = true;
    # pkgs.go の代わりに特定のバージョンを指定
    package = pkgs.go_1_25;
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
