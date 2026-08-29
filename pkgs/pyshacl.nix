{
  python3Packages,
  fetchPypi,
  owlrl,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyshacl";
  version = "0.31.0";
  pyproject=true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;

    hash = "sha256-MnlQh1pbsNGhXCRqiicrLb9rybluKM+o/b+k1zqtwLo=";
  };

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = [
    python3Packages.rdflib
    python3Packages.prettytable
    owlrl
  ];
})
