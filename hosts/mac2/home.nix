{ pkgs, ... }: {
  imports = [
    ../../modules/home-manager/core
    ../../modules/home-manager/iterm2
    ../../modules/home-manager/vscode
  ];

  home.stateVersion = "23.11";
  home.username = "koheiwatanabe";
  home.homeDirectory = "/Users/koheiwatanabe";

  # mac2 固有の VSCode設定
  vscodeConfig.overrides = {
    "extensions.autoUpdate" = false;
  };
}
