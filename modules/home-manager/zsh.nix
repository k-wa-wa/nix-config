{ ... }: {
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

  # スターシップ（モダンなプロンプト）
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
