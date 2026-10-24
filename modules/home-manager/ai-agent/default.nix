{ pkgs, ... }:

let
  sync-ai-logs = pkgs.writeScriptBin "sync-ai-logs" (
    builtins.replaceStrings [ "#!/usr/bin/env python3" ] [ "#!${pkgs.python3}/bin/python3" ] (
      builtins.readFile ./sync-ai-logs.py
    )
  );
in
{
  home.packages = [ sync-ai-logs ];

  home.file.".gemini/GEMINI.md".source = ./GEMINI.md;
  home.file.".claude/CLAUDE.md".source = ./AGENTS.md;

  launchd.agents.sync-ai-logs = {
    enable = true;
    config = {
      ProgramArguments = [ "${sync-ai-logs}/bin/sync-ai-logs" ];
      StartInterval = 600;
      RunAtLoad = true;
      StandardOutPath = "/tmp/sync-ai-logs.stdout.log";
      StandardErrorPath = "/tmp/sync-ai-logs.stderr.log";
    };
  };
}
