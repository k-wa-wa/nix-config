{ pkgs, ... }:

{
  home.file.".gemini/GEMINI.md".source = ./GEMINI.md;
  home.file.".claude/CLAUDE.md".source = ./AGENTS.md;
}
