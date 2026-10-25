# エージェント CLI がホーム全体で読むルールを置く (Mac 用)。
#
# - rules.md: どのホストでも効く個人の共通ルール。atelier には nuage-cluster が autopilot5 経由で配る (flake の lib.agentRules)。
# - mac.md: 手元で人間が git を扱うためのルール。atelier では bot が PR を作るので配らない。
{ ... }:

let
  rules = builtins.readFile ./mac.md + "\n" + builtins.readFile ./rules.md;
in
{
  home.file.".claude/CLAUDE.md".text = rules;
  home.file.".gemini/GEMINI.md".text = rules;
}
