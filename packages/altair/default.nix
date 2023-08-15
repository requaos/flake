{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, pythonOlder
, hatchling
}:

buildPythonPackage rec {
  pname = "altair";
  version = "5.0.1";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "altair-viz";
    repo = "altair";
    rev = "9a6f39ccb42b003c39aae6bab86531c33be8ed26";
    hash = "sha256-0OO0qgG7lxKVrknwz8Oe+9iEj4YTTbWJRNNGrVdGUCQ=";
  };

  pythonImportsCheck = [ "altair" ];

  nativeBuildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    hatchling
  ];

  meta = with lib; {
    description = "Vega-Altair is a declarative statistical visualization library for Python";
    homepage = "https://github.com/altair-viz/altair";
    license = licenses.bsd3;
    maintainers = with maintainers; [ extends ];
  };
}
