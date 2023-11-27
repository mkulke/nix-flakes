{
  description = "systemd-repart custom build";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        working-directory = "~/dev/azure-cvm-tooling/az-cvm-vtpm";
        name = "tpm2";
        project-buildInputs = with pkgs; [
          openssl
          tpm2-tss
          pkg-config
        ];
      in {
        devShells.default = pkgs.mkShell {
          NIX_HARDENING_ENABLE = "";
          buildInputs = project-buildInputs;
          shellHook = ''
            source ~/.profile
            export PS1="$(sed 's|\\u@\\h|(nix:${name})|g' <<< $PS1)"
            cd ${working-directory}
          '';
        };
        formatter = pkgs.nixfmt;
      });
}
