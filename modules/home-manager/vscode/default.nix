{ config, lib, ... }:

with lib;
let
  cfg = config.vscodeConfig;
  vscodeConfigDir = "Library/Application Support/Code/User";
  
  # settings.json を読み込んで base 設定とする
  baseSettings = builtins.fromJSON (builtins.readFile ./settings.json);
  
  # ベースの設定とホスト固有のオーバーライドをマージ
  finalSettings = lib.recursiveUpdate baseSettings cfg.overrides;
in
{
  options.vscodeConfig = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VS Code configuration";
    };
    overrides = mkOption {
      type = types.attrs;
      default = {};
      description = "Override settings for specific hosts";
    };
  };

  config = mkIf cfg.enable {
    home.file = {
      "${vscodeConfigDir}/settings.json".text = builtins.toJSON finalSettings;
      "${vscodeConfigDir}/keybindings.json".source = ./keybindings.json;
    };
  };
}
