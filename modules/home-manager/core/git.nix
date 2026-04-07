{ ... }: {
  programs.git = {
    enable = true;
    extraConfig = {
      ghq = {
        root = "~/ghq";
      };
      alias = {
        b = "branch";
        s = "switch";
        c = "!git commit -m";
        f = "fetch";

        ad = "add";
        ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
        pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
        co = "checkout";
      };
    };
  };

  programs.zsh = {
    shellAliases = {
      g  = "git";
      sd = "ghq-cd";
    };
    initExtra = ''
      function __ghq_fzf_pick() {
        ghq list --full-path | fzf --height 40% --border --preview 'eza --tree --level=2 --icons --color=always {}'
      }

      function ghq-cd {
        local dir=$(__ghq_fzf_pick)
        if [[ -n "$dir" ]]; then
          cd "$dir"
        fi
      }

      function code {
        if [[ $# -gt 0 ]]; then
          command code "$@"
        else
          local dir=$(__ghq_fzf_pick)
          if [[ -n "$dir" ]]; then
            command code "$dir"
          fi
        fi
      }

      function agy {
        local agy_path="$HOME/.antigravity/antigravity/bin/agy"
        if [[ $# -gt 0 ]]; then
          "$agy_path" "$@"
        else
          local dir=$(__ghq_fzf_pick)
          if [[ -n "$dir" ]]; then
            "$agy_path" "$dir"
          fi
        fi
      }
    '';
  };
}
