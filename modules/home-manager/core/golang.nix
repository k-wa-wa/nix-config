{ pkgs, ... }: {
  programs.go = {
    enable = true;
    package = pkgs.go_1_25;
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
