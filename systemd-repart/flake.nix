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
        name = "sysext";
        python-pkgs = p: with p; [
          jinja2
        ];
        project-python = pkgs.python3.withPackages python-pkgs;
        project-buildInputs = with pkgs; [
          gperf
          libcap
          libgcrypt
          libseccomp
          libxcrypt
          meson
          ninja
          openssl
          pcre2
          pkgconfig
          project-python
          util-linux
        ];
      in {
        devShells.default = pkgs.mkShell {
          NIX_HARDENING_ENABLE = "";
          buildInputs = project-buildInputs;
          shellHook = ''
            source ~/.profile
            export PS1="$(sed 's|\\u@\\h|(nix:${name})|g' <<< $PS1)"
            cd ~/dev/systemd
          '';
        };
        packages.default = pkgs.stdenv.mkDerivation {
          NIX_HARDENING_ENABLE = "";
          name = "systemd-repart";
          src = pkgs.fetchgit {
            url = "https://github.com/systemd/systemd.git";
            rev = "b0f965966b";
            sha256 = "sha256-h1CHrkS6nUkzyIWsMAZiG+Jl+b7Icj3daMrYcsrNScM=";
          };
          configurePhase = ''
            for file in $(find src -name "*.sh"); do patchShebangs --build "$file"; done &&
            for file in $(find src -name "*.py"); do patchShebangs --build "$file"; done &&
            for file in $(find tools -name "*.py"); do patchShebangs --build "$file"; done &&
            meson setup --reconfigure build -Drepart=enabled
          '';
          buildPhase = "ninja -C build systemd-repart";
          installPhase = ''
            mkdir -p $out/bin $out/lib &&
            install -t $out/bin build/systemd-repart &&
            install -t $out/lib build/src/shared/libsystemd-shared-*.so
          '';
          buildInputs = project-buildInputs;
          dontUseCmakeConfigure = true;
          dontUseNinjaBuild = true;
          dontUseNinjaInstall = true;
          dontUseMesonConfigure = true;
        };
        formatter = pkgs.nixfmt;
      });
}
