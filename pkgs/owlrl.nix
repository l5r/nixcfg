{
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "owlrl";
  version = "7.1.4";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;

    hash = "sha256-YL1AZ+NGuREfCikkVlr+l6xllbmLK76VOSi1ETlx2vc=";
  };

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = [
    python3Packages.rdflib
  ];
})
