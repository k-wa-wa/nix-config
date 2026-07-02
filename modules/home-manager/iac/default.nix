{ pkgs, ... }: {
  home.packages = with pkgs; [
    opentofu
    terragrunt
    sops
    age
    ssh-to-age
  ];

  programs.zsh.shellAliases = {
    tf  = "tofu";
    tg  = "terragrunt";
  };
}
