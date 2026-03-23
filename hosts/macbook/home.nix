{ pkgs, ... }: {
  imports = [
    ../../modules/home-manager/core
    ../../modules/home-manager/k8s
    ../../modules/home-manager/iac
    ../../modules/home-manager/ghostty
  ];

  home.stateVersion = "23.11";
  home.username = "watanabekouhei";
  home.homeDirectory = "/Users/watanabekouhei";

  programs.git.settings.user = {
    name = "Kohei Watanabe";
    email = "sek.ohei.w0822@icloud.com";
  };
}
