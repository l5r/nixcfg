{ config, pkgs, ... }:
let
  lazyBin = pkg: bin: pkgs.writeShellScript "lazy-${bin}" (
    builtins.unsafeDiscardOutputDependency ''
      nix shell --derivation ${pkg.drvPath} -c ${bin} $@
    ''
  );
in
{
  programs.neovim.coc = {
    enable = true;

    # FIXME: https://github.com/nix-community/home-manager/issues/2966
    package = pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "coc.nvim";
      version = "2022-05-21";
      src = pkgs.fetchFromGitHub {
        owner = "neoclide";
        repo = "coc.nvim";
        rev = "791c9f673b882768486450e73d8bda10e391401d";
        sha256 = "sha256-MobgwhFQ1Ld7pFknsurSFAsN5v+vGbEFojTAYD/kI9c=";
      };
      meta.homepage = "https://github.com/neoclide/coc.nvim/";
    };

    settings = {
      "coc.preferences.formatOnSaveFiletypes" = [
        "nix"
        "java"
        "scala"
        "py"
        "python"
        "json"
        "js"
        "javascript"
        "css"
        "scss"
        "rs"
        "rust"
      ];
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
        # python-language-server = let
        #   python = pkgs.python38.withPackages (
        #     ps: with ps; [
        #       python-language-server
        #       pyls-black
        #     ]
        #   );
        # in
        #   {
        #     command = lazyBin python "pyls";
        #     filetypes = [ "python" "py" ];
        #   };
      };
      rust-client.disableRustup = true;
    };
  };
}
