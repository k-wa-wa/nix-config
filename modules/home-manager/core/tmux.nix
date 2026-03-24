{ pkgs, ... }: {
  home.packages = [
    # ── IDE launcher ─────────────────────────────────────────────────────
    # ide          →  fzf でディレクトリ選択後に IDE セッションを起動
    # ide <dir>    →  指定ディレクトリで即座に起動
    (pkgs.writeShellScriptBin "ide" ''
      _dir_to_session() {
        echo "$1" | sed "s|^$HOME|~|" | rev | cut -d'/' -f1-3 | rev | tr '/.' '_'
      }

      _attach_or_switch() {
        if [ -z "$TMUX" ]; then
          exec tmux attach -t "=$1"
        else
          tmux switch-client -t "=$1"
        fi
      }

      _launch_ide() {
        local dir="$1"
        local session_name
        session_name="$(_dir_to_session "$dir")-ide"
        [[ "$session_name" == "~" ]] && session_name="home"

        # すでにセッションが存在すればそちらへ
        if tmux has-session -t "=$session_name" 2>/dev/null; then
          _attach_or_switch "$session_name"
          return
        fi

        # 新規セッション作成（デタッチ状態）
        tmux new-session -d -s "$session_name" -c "$dir"
        tmux rename-window -t "$session_name:1" "ide"

        # pane 1 (上 70%): nvim
        tmux send-keys -t "$session_name:1.1" "nvim ." Enter

        # pane 2 (下 30% 左): ターミナル
        tmux split-window -t "$session_name:1.1" -v -p 30 -c "$dir"

        # pane 3 (下 30% 右): ターミナル
        tmux split-window -t "$session_name:1.2" -h -c "$dir"

        # フォーカスを nvim に戻す
        tmux select-pane -t "$session_name:1.1"

        _attach_or_switch "$session_name"
      }

      # 引数でディレクトリを指定した場合は即起動
      if [ -n "$1" ] && [ -d "$1" ]; then
        _launch_ide "$(cd "$1" && pwd)"
        exit 0
      fi

      # fzf で ghq + zoxide からディレクトリを選択
      ghqdirs=$(ghq list --full-path 2>/dev/null | sed 's|^|[ghq] |')
      zdirs=$(zoxide query --list 2>/dev/null | sed 's|^|[z]   |')

      result=$(printf "%s\n%s\n" "$ghqdirs" "$zdirs" \
        | awk '!seen[$0]++' | grep -v '^$' \
        | fzf --height 60% --border --prompt " ide> " --reverse \
              --preview 'dir=$(echo {} | sed "s|^\[.*\] ||"); eza --tree --level 2 --color always "$dir" 2>/dev/null || echo "$dir"' \
              --preview-window right:40%)
      [ $? -ne 0 ] || [ -z "$result" ] && exit 1

      # prefix を除去してディレクトリパスを取り出す
      selected=$(echo "$result" | sed 's|^\[.*\] ||' | sed 's|^[[:space:]]*||')

      [ -d "$selected" ] || exit 1
      _launch_ide "$selected"
    '')

    # ── Session selector ─────────────────────────────────────────────────
    (pkgs.writeShellScriptBin "ts" ''
      _dir_to_session() {
        echo "$1" | sed "s|^$HOME|~|" | rev | cut -d'/' -f1-3 | rev | tr '/.' '_'
      }

      _attach_or_switch() {
        if [ -z "$TMUX" ]; then
          exec tmux attach -t "=$1"
        else
          tmux switch-client -t "=$1"
        fi
      }

      sessions=$(tmux list-sessions -F "[s] #{session_name}" 2>/dev/null)
      ghqdirs=$(ghq list --full-path 2>/dev/null | sed 's|^|[ghq] |')
      zdirs=$(zoxide query --list 2>/dev/null)

      # $PWD を先頭に、zoxide 履歴・既存セッションを続けて表示
      # --print-query: 入力テキストも取得（カスタムセッション名として使う）
      result=$(printf "%s\n%s\n%s\n%s" "$sessions" "$ghqdirs" "$PWD" "$zdirs" \
        | awk '!seen[$0]++' | grep -v '^$' \
        | fzf --height 60% --border --prompt "tmux> " --reverse --print-query)
      fzf_exit=$?

      query=$(printf '%s' "$result" | head -1)
      selected=$(printf '%s' "$result" | sed -n '2p')

      # Escape / Ctrl+C → 通常シェルに落ちる（exit しない）
      [ $fzf_exit -eq 130 ] && exit 1

      # リストにないテキストを入力して Enter → カスタムセッション名で新規作成
      if [ $fzf_exit -eq 1 ] && [ -n "$query" ]; then
        if [ -z "$TMUX" ]; then
          exec tmux new-session -s "$query"
        else
          tmux new-session -ds "$query" -c "$PWD"
          tmux switch-client -t "=$query"
        fi
        exit 0
      fi

      # 既存セッションを選択
      if [[ "$selected" == "[s] "* ]]; then
        _attach_or_switch "''${selected#"[s] "}"
        exit 0
      fi

      # [ghq] prefix を除去
      [[ "$selected" == "[ghq] "* ]] && selected="''${selected#"[ghq] "}"

      # ディレクトリを選択 → セッション名自動生成 + cd
      if [ -d "$selected" ]; then
        session_name=$(_dir_to_session "$selected")
        [[ "$session_name" == "~" ]] && session_name="home"
        if ! tmux has-session -t "=$session_name" 2>/dev/null; then
          tmux new-session -ds "$session_name" -c "$selected"
        fi
        _attach_or_switch "$session_name"
        exit 0
      fi
    '')
  ];

  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set-option -gw mode-keys vi

      # True color
      set -ga terminal-overrides ",*256col*:Tc"

      # 選択時にクリップボードへ自動コピーしない
      set -s set-clipboard off

      # vim でのEsc遅延を防ぐ
      set -sg escape-time 10

      # vim/neovim のフォーカス検知（自動保存・reload に必要）
      set -g focus-events on

      # ウィンドウ番号を1始まりに
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      # スクロールバック行数
      set -g history-limit 50000

      # ステータスバーを上部に表示
      set -g status-position top

      # ステータスバーの色（Mac デフォルト: ダークネイビー系）
      set -g status-style "bg=#1e2030,fg=#c0caf5"
      set -g status-left-style "bg=#3d59a1,fg=#c0caf5,bold"
      set -g status-right-style "bg=#1e2030,fg=#737aa2"

      # ステータスバーにセッション名を表示（左側）
      set -g status-left "[#S] "
      set -g status-left-length 50

      # ステータスバー右側に日時を表示
      set -g status-right "%Y-%m-%d %H:%M"
      set -g status-right-length 30

      # ウィンドウタブ: アクティブを強調
      set -g window-status-current-style "bg=#7aa2f7,fg=#1e2030,bold"
      set -g window-status-style "fg=#737aa2"
      set -g window-status-current-format " #I:#W "
      set -g window-status-format " #I:#W "

      # ペインのボーダー: アクティブ/非アクティブで色を分ける
      set -g pane-border-style "fg=#3d4f7c"
      set -g pane-active-border-style "fg=#89b4fa,bold"

      # ペインのボーダーにインデックスとコマンド名を表示
      set -g pane-border-status top
      set -g pane-border-format " #[bold]#{pane_index}#[nobold] #{pane_current_command} "

      # | で縦分割、- で横分割
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # ペインの移動を Vim 風にする (hjkl)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Ctrl+d をデタッチに（セッションを残したまま抜ける）
      bind -n C-d detach-client

      # prefix + x でペインを確認なしで閉じる
      bind x kill-pane

      # ドラッグ終了時にコピーモードを終了しない
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X noop
      # 選択範囲外をクリックした時に選択を解除する
      bind-key -T copy-mode-vi MouseDown1Pane send-keys -X clear-selection
    '';
  };

  programs.zsh = {
    enable = true;
    initExtra = ''
      # ターミナル起動時の tmux 自動起動（VSCode では起動しない）
      if [ -z "$TMUX" ] && [ -n "$PS1" ] && [ "$TERM_PROGRAM" != "vscode" ]; then
        ts && exit
      fi
    '';
  };
}
