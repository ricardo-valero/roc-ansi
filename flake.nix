{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    roc.url = "github:roc-lang/roc";
  };
  outputs = {
    nixpkgs,
    roc,
    ...
  }: let
    systems = nixpkgs.lib.systems.flakeExposed;
  in {
    devShells = nixpkgs.lib.genAttrs systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      roc-pkgs = roc.packages.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = builtins.attrValues {
          inherit (pkgs) nixd alejandra;
          inherit (pkgs) claude-code;
          inherit (roc-pkgs) full;
        };
      };
    });
  };
}
