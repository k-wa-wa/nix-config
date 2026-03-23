{ ... }: {
  programs.git = {
    enable = true;
    settings = {
      ghq = {
        root = "~/ghq";
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
