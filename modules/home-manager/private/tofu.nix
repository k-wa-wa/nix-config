{ pkgs, ... }: {
  home.packages = with pkgs; [
    opentofu
    terragrunt
  ];

  programs.zsh.shellAliases = {
    tf  = "tofu";
    tg  = "terragrunt";
  };
}
