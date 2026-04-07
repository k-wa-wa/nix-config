{ unstablePkgs, ... }: {
  home.packages = with unstablePkgs; [
    rustc
    cargo
    rustfmt
    clippy
  ];
}
