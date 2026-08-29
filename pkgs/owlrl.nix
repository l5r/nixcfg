{
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname="owlrl";
  version="7.6.2";
  src = fetchPypi {
    inherit (finalAttrs) pname version;

    hash = "";
  };

})
