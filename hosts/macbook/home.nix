{ pkgs, ... }:
{
  imports = [
    ../../modules/home-manager/core
    ../../modules/home-manager/core/tmux.nix
    ../../modules/home-manager/k8s
    ../../modules/home-manager/iac
    ../../modules/home-manager/iterm2
    ../../modules/home-manager/others/alias.nix
    ../../modules/home-manager/vscode
    ../../modules/home-manager/ai-agent
  ];

  home.stateVersion = "23.11";
  home.username = "koheiwatanabe";
  home.homeDirectory = "/Users/koheiwatanabe";

  programs.git.settings.user = {
    name = "Kohei Watanabe";
    email = "sek.ohei.w0822@icloud.com";
  };
}
