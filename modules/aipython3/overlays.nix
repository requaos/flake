pkgs: {
  fixPackages = final: prev:
    let
      relaxProtobuf = pkg: pkg.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
        pythonRelaxDeps = [ "protobuf" ];
      });
    in
    {
      huggingface-hub =
        let
          inherit (prev.pkgs) fetchFromGitHub;
          version = "0.15.1";
        in
        prev.huggingface-hub.overridePythonAttrs (old: {
          inherit version;
          src = fetchFromGitHub {
            owner = "huggingface";
            repo = "huggingface_hub";
            rev = "refs/tags/v${version}";
            hash = "sha256-+BtXi+O+Ef4p4b+8FJCrZFsxX22ZYOPXylexFtsldnA=";
          };
          propagatedBuildInputs = old.propagatedBuildInputs ++ [ prev.fsspec ];
        });
#      tokenizers =
#        let
#          inherit (prev.pkgs) fetchFromGitHub rustPlatform;
#          pname = "tokenizers";
#          version = "0.13.2";
#          sourceRoot = "source/bindings/python";
#        in
#        prev.tokenizers.overridePythonAttrs (_: rec {
#          src = fetchFromGitHub {
#            owner = "huggingface";
#            repo = pname;
#            rev = "python-v${version}";
#            hash = "sha256-DE0DA9U9CVQH5dp8BWgeXb+RdkXXOH2dZ9NrPGScDsQ=";
#          };
#
#          cargoDeps = rustPlatform.fetchCargoTarball {
#            inherit src sourceRoot;
#            name = "${pname}-${version}";
#            hash = "sha256-G6BQpnGucqmbmADC47xV0Jm9JqYob7416FFHl8rRWh4=";
#          };
#        });

      transformers =
        let
          inherit (prev.pkgs) fetchFromGitHub;
          pname = "transformers";
          #version = "4.28.1";
          revision = "0ebe7ae16076f727ac40c47f8f9167013c4596d8";
        in
        prev.transformers.overridePythonAttrs (_: {
          #inherit version;
          src = fetchFromGitHub {
            owner = "huggingface";
            repo = pname;
            #rev = "refs/tags/v${version}";
            rev = revision;
            hash = "sha256-FmiuWfoFZjZf1/GbE6PmSkeshWWh+6nDj2u2PMSeDk0=";
          };
        });
      typing-extensions =
        let
          inherit (prev.pkgs) fetchPypi;
          version = "4.7.1";
        in
        prev.typing-extensions.overridePythonAttrs (_: {
          src = fetchPypi {
            pname = "typing_extensions";
            inherit version;
            hash = "sha256-t13cJk8LpWFdt7ohfa65lwGtKVNTxF+elZYzN87u/7I=";
          };
        });
      pytorch-lightning = relaxProtobuf prev.pytorch-lightning;
      wandb = relaxProtobuf prev.wandb;
      markdown-it-py = prev.markdown-it-py.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
        pythonRelaxDeps = [ "linkify-it-py" ];
        passthru = old.passthru // {
          optional-dependencies = with final; {
            linkify = [ linkify-it-py ];
            plugins = [ mdit-py-plugins ];
          };
        };
      });
      filterpy = prev.filterpy.overrideAttrs (old: {
        doInstallCheck = false;
      });
      shap = prev.shap.overrideAttrs (old: {
        doInstallCheck = false;
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ final.packaging ];
        pythonImportsCheck = [ "shap" ];

        meta = old.meta // {
          broken = false;
        };
      });
      streamlit =
        let
          streamlit = final.callPackage (pkgs.path + "/pkgs/applications/science/machine-learning/streamlit") {
            protobuf3 = final.protobuf;
          };
        in
        final.toPythonModule (relaxProtobuf streamlit);
    };

  extraDeps = final: prev:
    let
      rm = d: d.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
        pythonRemoveDeps = [ "opencv-python-headless" "opencv-python" "tb-nightly" "clip" ];
      });
      callPackage = final.callPackage;
      rmCallPackage = path: args: rm (callPackage path args);
    in
    {
      scikit-image = final.scikitimage;
      opencv-python-headless = final.opencv-python;
      opencv-python = final.opencv4;

      safetensors = callPackage ../../packages/safetensors { };
      rouge = callPackage ../../packages/rouge { };
      altair = callPackage ../../packages/altair { };
      compel = callPackage ../../packages/compel { };
      apispec-webframeworks = callPackage ../../packages/apispec-webframeworks { };
      pydeprecate = callPackage ../../packages/pydeprecate { };
      taming-transformers-rom1504 =
        callPackage ../../packages/taming-transformers-rom1504 { };
      albumentations = rmCallPackage ../../packages/albumentations { };
      qudida = rmCallPackage ../../packages/qudida { };
      gfpgan = rmCallPackage ../../packages/gfpgan { };
      basicsr = rmCallPackage ../../packages/basicsr { };
      facexlib = rmCallPackage ../../packages/facexlib { };
      realesrgan = rmCallPackage ../../packages/realesrgan { };
      codeformer = callPackage ../../packages/codeformer { };
      clipseg = rmCallPackage ../../packages/clipseg { };
#      kornia = callPackage ../../packages/kornia { };
      lpips = callPackage ../../packages/lpips { };
      ffmpy = callPackage ../../packages/ffmpy { };
      picklescan = callPackage ../../packages/picklescan { };
      diffusers = callPackage ../../packages/diffusers { };
      pypatchmatch = callPackage ../../packages/pypatchmatch { };
      fonts = callPackage ../../packages/fonts { };
      font-roboto = callPackage ../../packages/font-roboto { };
      analytics-python = callPackage ../../packages/analytics-python { };
      gradio = callPackage ../../packages/gradio { };
      gradio-client = callPackage ../../packages/gradio-client { };
      blip = callPackage ../../packages/blip { };
      fairscale = callPackage ../../packages/fairscale { };
      torch-fidelity = callPackage ../../packages/torch-fidelity { };
#      resize-right = callPackage ../../packages/resize-right { };
#      torchdiffeq = callPackage ../../packages/torchdiffeq { };
#      k-diffusion = callPackage ../../packages/k-diffusion { };
#      clip-anytorch = callPackage ../../packages/clip-anytorch { };
#      clean-fid = callPackage ../../packages/clean-fid { };
      getpass-asterisk = callPackage ../../packages/getpass-asterisk { };
      peft = callPackage ../../packages/peft { };
      llama-cpp-python = callPackage ../../packages/llama-cpp-python { };
#      lion-pytorch = callPackage ../../packages/lion-pytorch { };
      flexgen = callPackage ../../packages/flexgen { };
      hf-doc-builder = callPackage ../../packages/hf-doc-builder { };
      rwkv = callPackage ../../packages/rwkv { };
      autogptq = callPackage ../../packages/auto-gptq { };
    };

  torchCuda = final: prev: {
     torch = pkgs.python3Packages.torchWithCuda.override { cudaPackages = pkgs.cudaPackages_11_8; };
#    torch = pkgs.python3Packages.torchWithCuda.overrideAttrs (old: rec {
#       pname = "torch";
#       version = "1.13.1";
#       src = pkgs.fetchFromGitHub {
#         owner = "pytorch";
#         repo = "pytorch";
#         rev = "refs/tags/v${version}";
#         fetchSubmodules = true;
#         hash = "sha256-yQz+xHPw9ODRBkV9hv1th38ZmUr/fXa+K+d+cvmX3Z8=";
#       };
#    });
  };
}
