{ pkgs, ... }: {
  imports = [
    ./git.nix

    ./k8s.nix
    ./tofu.nix
  ];

  programs.go = {
    enable = true;
    # pkgs.go の代わりに特定のバージョンを指定
    package = pkgs.go_1_25;
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
