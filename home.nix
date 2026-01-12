{ pkgs, username, ... }: {
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin
                       then "/Users/${username}"
                       else "/home/${username}";

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # システム管理・モニタリング
    htop
    bottom      # モダンなリソースモニター
    neofetch    # システム情報表示

    # 開発・生産性向上
    git
    ripgrep     # 超高速 grep
    fzf         # 曖昧検索
    eza         # ls のモダンな代替
    bat         # cat のモダンな代替（シンタックスハイライト付）
    jq          # JSON加工
    tree

    # Kubernetes関連
    kubectl
    kubernetes-helm
    k9s              # TUIでKubernetesを操作できる便利ツール
    kubectx          # コンテキスト切り替えを楽にするツール
  ];

  # ---------------------------------------------------------------------------
  # 2. Zsh の詳細設定
  # ---------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true; # 入力補完の提案
    syntaxHighlighting.enable = true; # コマンドの色付け

    initContent = ''
      # Nix のパスを PATH の最優先（先頭）に配置する
      export PATH="$HOME/.nix-profile/bin:$PATH"
    '';

    shellAliases = {
      k = "kubectl";
      ls = "eza";
      ll = "eza -l";
      cat = "bat";
      g = "git";
      hm-build = "nix run github:nix-community/home-manager -- build --flake .#watanabekouhei@macbook";
      hm-switch = "nix run github:nix-community/home-manager -- switch --flake .#watanabekouhei@macbook";
    };

    history = {
      size = 100000;        # メモリ上に保持する行数
      save = 100000;        # ファイルに保存する行数
      path = "$HOME/.zsh_history";
      ignoreDups = true;    # 直前と同じコマンドなら記録しない
      share = false;         # 複数の端末間で履歴をリアルタイム共有しない
      expireDuplicatesFirst = true; # 上限に達した際、重複している古いものから消す
    };
  };

  # ---------------------------------------------------------------------------
  # 3. スターシップ（モダンなプロンプト）
  # ---------------------------------------------------------------------------
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # ---------------------------------------------------------------------------
  # 4. Git の設定
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Kohei Watanabe";
        email = "sek.ohei.w0822@icloud.com";
      };
    };
  };

  # Home Manager 自体の管理を有効化
  programs.home-manager.enable = true;
}