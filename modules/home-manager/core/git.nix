{ ... }: {
  programs.git = {
    enable = true;
    settings = {
      ghq = {
        root = "~/ghq";
      };
      alias = {
        b = "branch";
        s = "switch";
        c = "commit";
        f = "fetch";
        p = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
        pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
        co = "checkout";
      };
    };
  };

  programs.zsh = {
    shellAliases = {
      sd = "peco-cd";
    };
    initContent = ''
      function peco-cd {
        local dir=$(ghq list --full-path | peco)
        if [ -n "$dir" ]; then
          cd "$dir"
        fi
      }
    '';
  };
}
