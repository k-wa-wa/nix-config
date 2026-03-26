{ unstablePkgs, ... }: {
  programs.go = {
    enable = true;
    package = unstablePkgs.go_1_25;
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
