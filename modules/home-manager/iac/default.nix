{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    opentofu
    terragrunt
    sops
    age
    ssh-to-age
  ];

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  programs.zsh.shellAliases = {
    tf  = "tofu";
    tg  = "terragrunt";
  };
}
