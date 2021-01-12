# modules/themes/alucard/default.nix --- a regal dracula-inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.theme;
  colorscheme = {
    nord0 = "2E3440";
    nord1 = "3B4252";
    nord2 = "434C5E";
    nord3 = "4C566A";
    nord4 = "D8DEE9";
    nord5 = "E5E9F0";
    nord6 = "ECEFF4";
    nord7 = "8FBCBB";
    nord8 = "88C0D0";
    nord9 = "81A1C1";
    nord10 = "5E81AC";
    nord11 = "BF616A";
    nord12 = "D08770";
    nord13 = "EBCB8B";
    nord14 = "A3BE8C";
    nord15 = "B48EAD";
  };
in {
  config = mkIf (cfg.active == "nordic") (mkMerge [
    # Desktop-agnostic configuration
    {
      modules = {
        theme = {
          gtk = {
            theme = "Nordic";
            iconTheme = "Zafiro-icons";
            cursorTheme = "Zafiro-icons";
          };
          color = with colorscheme; {
            foreground = nord4;
            background = nord0;
            fadeColor = nord3;
            color0 = nord1;
            color1 = nord11;
            color2 = nord14;
            color3 = nord13;
            color4 = nord9;
            color5 = nord15;
            color6 = nord8;
            color7 = nord5;
            color8 = nord3;
            color9 = nord11;
            color10 = nord14;
            color11 = nord13;
            color12 = nord9;
            color13 = nord15;
            color14 = nord7;
            color15 = nord6;
          };
        };

        shell.zsh.rcFiles = [ ./config/zsh/prompt.zsh ];
        shell.tmux.rcFiles = [ ./config/tmux.conf ];
        desktop.browsers = {
          firefox.userChrome = concatMapStringsSep "\n" readFile
            [ ./config/firefox/userChrome.css ];
        };
      };
    }

    # Desktop theming
    {
      user.packages = with pkgs; [ nordic zafiro-icons ];
      fonts = {
        fonts = with pkgs; [
          fira-code
          fira-code-symbols
          jetbrains-mono
          siji
          font-awesome-ttf
        ];
        fontconfig.defaultFonts = {
          sansSerif = [ "Fira Sans" ];
          monospace = [ "Fira Code" ];
        };
      };

      home.configFile = with config.modules;
        mkMerge [
          (mkIf desktop.media.graphics.vector.enable {
            "inkscape/templates/default.svg".source =
              ./config/inkscape/default-template.svg;
          })
        ];
    }
  ]);
}
