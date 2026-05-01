{ ... }:

let
  vscodeConfigDir = "Library/Application Support/Code/User";
in
{
  home.file = {
    "${vscodeConfigDir}/settings.json".source = ./settings.json;
    "${vscodeConfigDir}/keybindings.json".source = ./keybindings.json;
  };
}
