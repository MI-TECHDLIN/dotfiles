{ config, lib, pkgs, user, no-mistakes, treehouse, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  system = pkgs.stdenv.hostPlatform.system;
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    gh        # GitHub CLI
    nodejs    # npx skills, lavish-axi, gnhf and other npm CLIs
    # agent tooling (firstmate uses both)
    no-mistakes.packages.${system}.default
    treehouse.packages.${system}.default
    # Installed and exposed to macOS through Home Manager.
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  home.sessionPath = [
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"
    "$HOME/development/flutter/bin"
  ];
  # Global npm installs go to a writable prefix, not the read-only nix store.
  home.file.".npmrc".text = "prefix=${config.home.homeDirectory}/.npm-global\n";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      ll = "ls -lah";
      la = "ls -A";
      c = "clear";
      v = "nvim";
      gs = "git status";
      gl = "git log --oneline --decorate --graph";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      add = "git add .";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
      dcu = "docker compose up";
      dcd = "docker compose down";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      directory = {
        truncation_length = 3;
        truncate_to_repo = false;
        style = "bold blue";
      };
      git_branch = {
        format = " [$branch]($style)";
        style = "bold cyan";
      };
      git_status = {
        format = " [$all_status$ahead_behind]($style)";
        style = "yellow";
        conflicted = "!";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        untracked = "?$count";
        stashed = "\\$$count";
        modified = "!$count";
        staged = "+$count";
        renamed = "»$count";
        deleted = "✘$count";
      };
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration = {
        min_time = 2000;
        format = " [$duration]($style)";
        style = "dimmed white";
      };
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.activation.installHackNerdFont = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    font_dir="$HOME/Library/Fonts"
    font_source="${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/Hack"
    mkdir -p "$font_dir"
    for font in HackNerdFont-Regular.ttf HackNerdFont-Bold.ttf HackNerdFont-Italic.ttf HackNerdFont-BoldItalic.ttf; do
      rm -f "$font_dir/$font"
      cp "$font_source/$font" "$font_dir/$font"
    done
  '';
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
