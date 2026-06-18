{ ... }: {
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        go   = "1.26.4";
        # node = "24.14.0";
        bun  = "1.3.14";
      };
    };
  };
}
