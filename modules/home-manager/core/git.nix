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
      function ghq-cd {
        local dir=$(ghq list --full-path | fzf --height 40% --border --preview 'eza --tree --level=2 --icons --color=always {}')
        if [ -n "$dir" ]; then
          cd "$dir"
        fi
      }
    '';
  };
}
