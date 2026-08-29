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
          inlay-hints-length-limit = 10;
        };
      };
    };

    languages = {
      language = let
        withPrettierFormatter = name: {
          inherit name;
          formatter = {
            command = "prettier";
            args = ["--parser" name];
          };
        };
      in [
        (withPrettierFormatter "html")
        (withPrettierFormatter "css")
        (withPrettierFormatter "scss")
        (withPrettierFormatter "typescript")
        {
          name = "javascript";
          formatter = {
            command = "prettier";
            args = ["--parser" "typescript"];
          };
        }
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
