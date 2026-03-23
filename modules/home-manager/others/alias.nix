{ ... }: {
  programs.zsh = {
    shellAliases = {
      claude   = "~/.local/bin/claude";
      opencode = "~/.opencode/bin/opencode";
      agy      = "~/.antigravity/antigravity/bin/agy";
    };
  };
}
