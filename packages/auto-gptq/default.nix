{ lib
, buildPythonPackage 
, fetchFromGitHub
, safetensors
, accelerate
, rouge
, transformers
, datasets
, torch
}:

buildPythonPackage rec {
  pname = "autogptq";
  version = "0.1.0";
  format = "setuptools";

  BUILD_CUDA_EXT = "1";

  src = fetchFromGitHub {
    owner = "PanQiWei";
    repo = "AutoGPTQ";
    rev = "b4eda619d0674e9ef009702cbd538836c0861a56";
    hash = "sha256-0OO0qgG7lxKVrknwz8Oe+9iEj4YTTbWJRNNGrVdGUCQ=";
  };

  pythonImportsCheck = [ "auto_gptq" ];

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
