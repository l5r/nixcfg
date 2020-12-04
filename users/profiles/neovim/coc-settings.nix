{ config, pkgs, ... }:
{
  xdg.configFile."nvim/coc-settings.json".text = builtins.toJSON
    {
      "coc.preferences.formatOnSaveFiletypes" = [ "nix" "scala" ];
      "diagnostic-languageserver.filetypes" = {
        markdown = "languagetool";
        pandoc = "languagetool";
      };
      "diagnostic-languageserver.linters" = {
        languagetool = {
          args = [ "-adl" "%filepath" ];
          command = "languagetool";
          debounce = 200;
          formatLines = 2;
          formatPattern = [
            ''
              ^\d+?\.\)\s+Line\s+(\d+),\s+column\s+(\d+),\s+([^\n]+)
              Message:\s+(.*)(\r|\n)*$
            ''
            {
              column = 2;
              line = 1;
              message = [ 4 3 ];
            }
          ];
          offsetColumn = 0;
          offsetLine = 0;
          sourceName = "languagetool";
        };
      };
      languageserver = {
        rnix-lsp = {
          command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
          filetypes = [ "nix" ];
        };
        ccls = {
          command = "ccls";
          filetypes = [ "c" "cpp" "objc" "objcpp" ];
          initializationOptions = { cache = { directory = "/tmp/ccls"; }; };
          rootPatterns = [ ".ccls" "compile_commands.json" ".vim/" ".git/" ".hg/" ];
        };
        racket-langserver = {
          args = [ "-l" "racket-langserver" ];
          command = "racket";
          filetypes = [ "rkt" "scm" "racket" "scribble" "scrbbl" ];
        };
      };
    };
}
