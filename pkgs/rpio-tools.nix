{
  symlinkJoin,
  mu-cli,

  docker-compose,
  docker-compose-language-service,

  beamPackages,

  ember-cli,
  ember-language-server,
  nodejs,
  typescript-language-server,
  vscode-langservers-extracted,

  ruff,
  ty,
  pyshacl,
  python3,
  python3Packages,

  ruby,
  rubocop,
  solargraph,
  ruby-lsp,
}:
let
  python = python3.withPackages (ps: [
    ps.rdflib
    pyshacl
  ]);
in
symlinkJoin {
  name = "rpio-tools";
  paths = [
    mu-cli

    docker-compose
    docker-compose-language-service

    beamPackages.elixir-ls

    ember-cli
    ember-language-server
    nodejs
    typescript-language-server
    vscode-langservers-extracted

    python
    ruff
    ty
    python3Packages.python-lsp-server
    python3Packages.jedi-language-server

    ruby
    rubocop
    solargraph
    ruby-lsp
  ];
}
