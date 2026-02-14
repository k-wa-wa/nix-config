{ ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true; # 入力補完の提案
    historySubstringSearch.enable = true; # 入力中の文字列から始まる履歴だけを検索
    syntaxHighlighting.enable = true; # コマンドの色付け

    initContent = ''
      # Nix のパスを PATH の最優先（先頭）に配置する
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # zx: zoxideでヒットしなくても、fd + fzf で現在の配下を探して移動
      zx() {
        local dir
        # fdでディレクトリを抽出 -> fzfで選択（プレビュー付き）
        dir=$(fd --type d --hidden --exclude .git . ''${1:-.} | fzf \
          --height 40% \
          --layout reverse \
          --border \
          --preview 'eza --tree --level=2 --icons --color=always {} | head -200')

        if [[ -n "$dir" ]]; then
          cd "$dir"
        fi
      }

      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d "" cwd < "$tmp"
        [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
      }

      # nix コマンド有効化
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';

    shellAliases = {
      k = "kubectl";
      ls = "eza";
      ll = "eza -l";
      less = "bat";
      g = "git";
    };

    history = {
      size = 100000;        # メモリ上に保持する行数
      save = 100000;        # ファイルに保存する行数
      path = "$HOME/.zsh_history";
      ignoreDups = true;    # 直前と同じコマンドなら記録しない
      share = true;         # 複数の端末間で履歴をリアルタイム共有する
      expireDuplicatesFirst = true; # 上限に達した際、重複している古いものから消す
    };
  };

  # スターシップ（モダンなプロンプト）
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = ''$directory$git_branch$git_status$fill$username$hostname  
$status$fill$cmd_duration$memory_usage$time
$character
'';

      directory = {
        truncation_length = 5;
        truncation_symbol = ".../";
        truncate_to_repo = false;
        style = "#57C7FF";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "​"; # ゼロ幅スペース
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      fill = {
        symbol = " ";
      };

      username = {
        show_always = true;
        style_root = "bright-black";
        style_user = "bright-black";
        format = "[$user]($style)";
        disabled = false;
      };
      hostname = {
        ssh_only = false;
        style = "bright-black";
        format = "[@$hostname]($style) ";
        disabled = false;
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };

      cmd_duration = {
        min_time = 1;
        format = " [$duration]($style) ";
      };

      memory_usage = {
        disabled = false;
        threshold = -1;
        style = "bold dimmed blue";
        format = "[RAM \${ram_pct}( | SWAP \${swap_pct})]($style) ";
      };

      time = {
        disabled = false;
        style = "fg:#73daca";
        time_format = "%T";
        format = " [$time]($style) ";
      };

      status = {
        disabled = false;
        format = "[$symbol $common_meaning$signal_name$maybe_int]($style) ";
        symbol = "✘";
        style = "bold red";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # zshでのCtrl+rなどを有効化

    # ezaやfdを使っているなら、プレビュー機能も付けられます
    defaultOptions = [
      "--height 40%"
      "--border"
    ];

    # CTRL-T (ファイル検索) を fd にする
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
  };
  programs.fd = {
    enable = true;
  };

  # zi でディレクトリ移動を強化する。zx コマンドも zsh 設定で追加している
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Ctrl + R で履歴検索を強化する。導入時は atuin import zsh で既存履歴をインポートする
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true; # シェルとの連携を有効化

    # Yazi自体の設定
    settings = {
      manager = {
        show_hidden = true; # 隠しファイルを表示
        sort_by = "alphabetical";
        sort_sensitive = false;
        sort_dir_first = true;
      };
    };
  };

  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        # 既にお持ちの設定
        avg_cpu = true;
        temperature_type = "c";

        # 追加のおすすめ
        current_usage = true;       # CPUの現在値を数値で表示
        unnormalized_cpu = true;    # 100%を超えるCPU使用率を表示（マルチコアで便利）
        group_processes = true;     # プロセスをグループ化（同じアプリの乱立を防ぐ）
        case_sensitive = false;     # 検索時に大文字小文字を区別しない
        enable_cache_memory = true; # キャッシュメモリも表示に含める
      };

      # 見た目のカスタマイズ
      colors = {
        # Starshipの青 (#57C7FF) に合わせるなら、アクセントに青系を
        table_header_color = "#57C7FF";
        rx_color = "light cyan";
        tx_color = "light magenta";
      };
    };
  };
}
