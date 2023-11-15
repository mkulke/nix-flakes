{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        name = "sysext";
        python-pkgs = p: [
          p.jinja2
        ];
        python = pkgs.python3.withPackages python-pkgs;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.cmake
            pkgs.gperf
            pkgs.libcap
            pkgs.meson
            pkgs.ninja
            pkgs.systemd
            python
          ];
          shellHook = ''
            source ~/.profile
            export PS1="$(sed 's|\\u@\\h|(nix:${name})|g' <<< $PS1)"
          '';
        };
        formatter = pkgs.nixfmt;
      });
}
