{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, six
}:

buildPythonPackage rec {
  pname = "rouge";
  version = "1.0.1";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "pltrdy";
    repo = "rouge";
    rev = "657d4d2f61892fb6c5aaf8796e93ebd3ed88e857";
    hash = "sha256-QlVi+LMtXOioe48W/jFGYw7hxdjQ6QR4JHMqDd7RSAA=";
  };

  pythonImportsCheck = [ "rouge" ];

  nativeBuildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [ six ];

  doCheck = false;

  meta = with lib; {
    description = "A full Python Implementation of the ROUGE Metric (not a wrapper)";
    homepage = "https://github.com/pltrdy/rouge";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
