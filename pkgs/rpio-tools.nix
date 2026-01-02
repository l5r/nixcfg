{ symlinkJoin,
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
  python3Packages,

  ruby,
  rubocop,
  solargraph,
  ruby-lsp
}: symlinkJoin {
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

    python3Packages.python
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
