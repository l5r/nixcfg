 { config, pkgs, ... }: {

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
   };
 }
