{
  description = "CLI tools for dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, hunk }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hunk-pkg = hunk.packages.${system}.default;
        tools = [
          hunk-pkg
        ] ++ (with pkgs; [
          zsh
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
          # markdown LSP/lint CLIs (consumed by nvim efm-langserver / nvim-lint)
          markdownlint-cli2
          textlint
        ]);
      in
      {
        packages.default = pkgs.buildEnv {
          name = "dotfiles-tools";
          paths = tools;
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = tools;
          shellHook = ''
            exec ${pkgs.zsh}/bin/zsh
          '';
        };
      }
    );
}
