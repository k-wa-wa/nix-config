{ ... }: {
  programs.zsh = {
    # 意図せず他のツールが使われるのを防ぐため、手動インストールツールはフルパスで指定
    shellAliases = {
      claude   = "~/.local/bin/claude";
      opencode = "~/.opencode/bin/opencode";
    };
  };
}
