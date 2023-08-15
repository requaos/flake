{ lib
, buildPythonPackage 
, fetchFromGitHub
, safetensors
, accelerate
, setuptools
, rouge
, transformers
, datasets
, torch
}:

buildPythonPackage rec {
  pname = "autogptq";
  version = "0.4.1";
  format = "setuptools";

  BUILD_CUDA_EXT = "1";

  src = fetchFromGitHub {
    owner = "PanQiWei";
    repo = "AutoGPTQ";
    rev = "eea67b7e130b92605f5ace33cc93e8b95e9c12a5";
    hash = "";
  };

  pythonImportsCheck = [ "auto_gptq" ];

  nativeBuildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    safetensors
    accelerate
    rouge
    transformers
    datasets
    torch
  ];

  meta = with lib; {
    description = "An easy-to-use LLMs quantization package with user-friendly apis, based on GPTQ algorithm";
    homepage = "https://github.com/PanQiWei/AutoGPTQ";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
