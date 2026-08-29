{
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage (finalAttrs: {
  pname = "pyshacl";
  version = "0.40.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;

    hash = "";
  };
})
