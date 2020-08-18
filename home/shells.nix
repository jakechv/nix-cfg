{ pkgs, ... }:

{
  programs.bash = { enable = true; };
  programs.zsh = {
    enable = true;
    autocd = true;
    shellAliases = {
      mkdir = "mkdir -p";
      ga = "git add .";
      weather = "curl wttr.in";
    };

    # like shell aliases, but substituted anywhere on a line
    shellGlobalAliases = { mkdir = "mkdir -p"; };
    enableCompletion = true;
    enableAutosuggestions = true;

    history = {
      extended = true;
      ignoreSpace = true;
      share = true;
    };

    # same format as aliases
    # env variables for zsh sessions
    sessionVariables = { };

    plugins = [
      {
        name = "zsh-nix-shell";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.1.0";
          sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
        };
      }

      {
        name = "nix-zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "spwhitt";
          repo = "nix-zsh-completions";
          rev = "v0.4.4";
          sha256 = "1n9whlys95k4wc57cnz3n07p7zpkv796qkmn68a50ygkx6h3afqf";
        };
      }

    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "extract" "git" "magic-enter" ];
      theme = "evan";
      extraConfig = ''
        # Use a special colour for Nix shells.
        # https://github.com/ejpcmac/config/blob/bc9ee4e7363e4e0ca97f4addbdd9370b83048d3c/zsh/themes/bazik.zsh-theme#L39-L53
        prompt_color() {
            if [ -n "$IN_NIX_SHELL" ]; then
                echo "$fg_bold[blue]"
            else
                echo "$fg_bold[green]"
            fi
        }
        MAGIC_ENTER_GIT_COMMAND='git status -u .'
        MAGIC_ENTER_OTHER_COMMAND='ls -lh .'
        eval "$(direnv hook zsh)"
      '';
    };
  };

  # allows completion for system packages
  # environment.pathsToLink = [ "/share/zsh" ];
}
