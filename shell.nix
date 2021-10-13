{ pkgs ? import <nixpkgs> {} }:
with pkgs;
mkShell {
  packages = [
    # FIXME: Workaround for https://github.com/tree-sitter/tree-sitter/issues/1392
    (tree-sitter.overrideAttrs (old: rec {
      version = "master";
      src = pkgs.fetchFromGitHub {
        owner = "tree-sitter";
        repo = "tree-sitter";
        rev = "ddb12dc0c65cc16f9ea65b375cf0c24f5fbef6d6";
        hash = "sha256-/wRVcfgezF1xd3PSE5ZipoHBYbLi671kMN5J9Osf0bQ=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
        name = "tree-sitter-master";
        inherit src;
        hash = "sha256-gh12ltTr6w5DdisKobgLyM6tvVx8/zDNuMIHX+hqJC8=";
      };
    }))
  ];
}
