{ aipython3
, lib
, src
, wsl ? false
, fetchFromGitHub
, writeShellScriptBin
, runCommand
, tmpDir ? "/tmp/nix-textgen"
, stateDir ? "$HOME/.textgen/state"
, libdrm
, cudaPackages
}:
let
  patchedSrc = runCommand "textgen-patchedSrc" { } ''
    cp -r --no-preserve=mode ${src} ./src
    cd src
    rm -rf models loras cache
    mv ./prompts ./_prompts
    mv ./characters ./_characters
    cd -
    substituteInPlace ./src/server.py \
      --replace "Path('presets" "Path('$out/presets" \
      --replace "Path('prompts" "Path('$out/prompts" \
      --replace "Path(f'prompts" "Path(f'$out/prompts" \
      --replace "Path('extensions" "Path('$out/extensions" \
      --replace "Path(f'presets" "Path(f'$out/presets" \
      --replace "Path('softprompts" "Path('$out/softprompts" \
      --replace "Path(f'softprompts" "Path(f'$out/softprompts" \
      --replace "Path('characters" "Path('$out/characters" \
      --replace "Path('cache" "Path('$out/cache"
    substituteInPlace ./src/download-model.py \
      --replace "=args.output" "='$out/models/'" \
      --replace "base_folder=None" "base_folder='$out/models/'"
    substituteInPlace ./src/modules/html_generator.py \
      --replace "../css" "$out/css" \
      --replace 'Path(__file__).resolve().parent / ' "" \
      --replace "Path(f'css" "Path(f'$out/css"
    substituteInPlace ./src/modules/utils.py \
      --replace "Path('css" "Path('$out/css" \
      --replace "Path('characters" "Path('$out/characters" \
      --replace "characters/" "$out/characters/"
    substituteInPlace ./src/modules/chat.py \
      --replace "folder = 'characters'" "folder = '$out/characters'" \
      --replace "Path('characters" "Path('$out/characters" \
      --replace "characters/" "$out/characters/"
    mv ./src $out
    ln -s ${tmpDir}/models/ $out/models
    ln -s ${tmpDir}/loras/ $out/loras
    ln -s ${tmpDir}/cache/ $out/cache
    ln -s ${tmpDir}/prompts/ $out/prompts
    ln -s ${tmpDir}/characters/ $out/characters
  '';
  textgenPython = aipython3.python.withPackages (_: with aipython3; [
    accelerate
    (bitsandbytes.overrideAttrs (old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ (with aipython3; [ scipy ]);
      src = fetchFromGitHub {
        owner = "TimDettmers";
        repo = "bitsandbytes";
        rev = "18e827d666fa2b70a12d539ccedc17aa51b2c97c";
        hash = "sha256-PO2QQH05hC5kNc2zqmaKYAoVFwQcAn6ws4jzWKC9h6c=";
      };
    }))
    colorama
    datasets
    flexgen
    gradio
    llama-cpp-python
    markdown
    numpy
    pandas
    peft
    pillow
    pyyaml
    requests
    rouge
    rwkv
    safetensors
    sentencepiece
    tqdm
    transformers
    autogptq
    torch
  ]);
in
(writeShellScriptBin "textgen" ''
  if [ -d "/usr/lib/wsl/lib" ]
  then
    echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH"
    set -x
    export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
    set +x
  fi
  rm -rf ${tmpDir}
  mkdir -p ${tmpDir}
  mkdir -p ${stateDir}/models ${stateDir}/cache ${stateDir}/loras ${stateDir}/prompts ${stateDir}/characters
  cp -r --no-preserve=mode ${patchedSrc}/_prompts/* ${stateDir}/prompts/
  cp -r --no-preserve=mode ${patchedSrc}/_characters/* ${stateDir}/characters
  ln -s ${stateDir}/models/ ${tmpDir}/models
  ln -s ${stateDir}/loras/ ${tmpDir}/loras
  ln -s ${stateDir}/cache/ ${tmpDir}/cache
  ln -s ${stateDir}/prompts/ ${tmpDir}/prompts
  ln -s ${stateDir}/characters/ ${tmpDir}/characters
  export LD_LIBRARY_PATH=/run/opengl-driver/lib:${cudaPackages.cudatoolkit}/lib
  ${textgenPython}/bin/python ${patchedSrc}/server.py $@ \
    --model-dir ${stateDir}/models/ \
    --lora-dir ${stateDir}/loras/ \

'').overrideAttrs
  (_: {
    meta = {
      maintainers = [ lib.maintainers.jpetrucciani ];
      license = lib.licenses.agpl3;
      description = "";
      homepage = "https://github.com/oobabooga/text-generation-webui";
      mainProgram = "textgen";
    };
  })
