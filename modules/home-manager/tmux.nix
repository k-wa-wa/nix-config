{ pkgs, ... }: {
  # Sessionizer スクリプト
  # - 既存セッション と ~ 配下のディレクトリを fzf で表示
  # - 選択 → セッション作成 or アタッチ
  # - Escape → 新しい無名セッションを作成（とにかく tmux に入れる）
  home.packages = [
    (pkgs.writeShellScriptBin "tmux-sessionizer" ''
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
      zdirs=$(zoxide query --list 2>/dev/null)

      # $PWD を先頭に、zoxide 履歴・既存セッションを続けて表示
      # --print-query: 入力テキストも取得（カスタムセッション名として使う）
      result=$(printf "%s\n%s\n%s" "$sessions" "$PWD" "$zdirs" \
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
      # True color
      set -ga terminal-overrides ",*256col*:Tc"

      # 選択時にクリップボードへ自動コピーしない
      set -s set-clipboard off

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

      # | で縦分割、- で横分割（直感的！）
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

      # prefix + f で Sessionizer を起動（フローティングウィンドウ）
      bind f display-popup -E -w 80% -h 60% -d "#{pane_current_path}" tmux-sessionizer
    '';
  };

  programs.zsh = {
    enable = true;
    initExtra = ''
      # ターミナル起動時の tmux 自動起動
      if [ -z "$TMUX" ] && [ -n "$PS1" ]; then
        if [ "$TERM_PROGRAM" = "vscode" ]; then
          # VSCode: ワークスペースパスからセッション名を自動生成してアタッチ/作成
          _session=$(echo "$PWD" | sed "s|^$HOME|~|" | rev | cut -d'/' -f1-3 | rev | tr '/.' '_')
          [[ "$_session" == "~" ]] && _session="home"
          tmux new-session -As "$_session" 2>/dev/null && exit
          unset _session
        else
          # iTerm / Ghostty: sessionizer を起動
          tmux-sessionizer && exit
        fi
      fi
    '';
  };
}
