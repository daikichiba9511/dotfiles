{
  description = "CLI tools for dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.buildEnv {
          name = "dotfiles-tools";
          paths = with pkgs; [
            jq
            tree-sitter
            starship
            uv
            ripgrep
            lsd
            fd
            bat
            delta
            fzf
            lazygit
            gh
            neovim-unwrapped
            ghq
          ];
        };
      }
    );
}
