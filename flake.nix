{
  nixConfig = {
    extra-substituters = [ "https://ai.cachix.org" ];
    extra-trusted-public-keys = [ "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=" ];
  };

  description = "A Nix Flake that makes AI reproducible and easy to run";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/master";
    };
    invokeai-src = {
      url = "github:invoke-ai/InvokeAI/v2.3.1.post2";
      flake = false;
    };
    koboldai-src = {
      url = "github:koboldai/koboldai-client/1.19.2";
      flake = false;
    };
    textgen-src = {
      # main moves pretty quick, let's pin this to a sha until we catchup
      url = "github:oobabooga/text-generation-webui/a95e6f02cbcc88756777c2affa8b621c7fbbb525";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { flake-parts, invokeai-src, hercules-ci-effects, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs { config.allowUnfree = true; inherit system; };
      };
      systems = [
        "x86_64-linux"
      ];
      imports = [
        hercules-ci-effects.flakeModule
        ./modules/dependency-sets
        ./modules/aipython3
        ./projects/invokeai
        ./projects/koboldai
        ./projects/textgen
        ./website
      ];
    };
}
