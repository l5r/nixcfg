{ config, pkgs, ... }:
{

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      editor = {
        trim-trailing-whitespace = true;
        lsp = {
          display-inlay-hints = true;
        };
      };
    };

    languages = {
      language = [
        {
          name = "turtle";
          scope = "source.turtle";
          language-id = "turtle";
          injection-regex = "tu?r?tle?";
          grammar = "turtle";
          file-types = [ "ttl" ];
          comment-tokens = [ "#" ];
        }
      ];

      grammar = [
        {
          name = "turtle";
          source = {
            git = "https://github.com/GordianDziwis/tree-sitter-turtle.git";
            rev = "7f789ea7ef765080f71a298fc96b7c957fa24422";
          };
        }
      ];
    };
  };

  xdg.configFile."helix/runtime/queries/turtle/highlights.scm".text = ''
    (rdf_literal (string) @string)
    (iri_reference) @string.special.url
    (namespace) @namespace
    (lang_tag) @label
    (comment) @comment.line

    "a" @keyword.operator
    [
      "@base"
      "@prefix"
    ] @keyword.directive

    [
      ";"
      ","
      "."
    ] @punctuation.delimiter
    [
      "<"
      ">"
      "["
      "]"
    ] @punctuation.bracket
  '';
}
