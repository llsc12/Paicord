{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib stdenv makeWrapper;

        swiftly =
          let
            arch = stdenv.hostPlatform.parsed.cpu.name;
            pname = "swiftly";
            version = "1.1.1";

            platformConfig =
              if stdenv.isLinux then
                {
                  url = "https://download.swift.org/swiftly/linux/swiftly-${version}-${arch}.tar.gz";
                  sha256 = "sha256-3F+UMIszRVUw9BULQSUnWWozyFJafVmwJbWYUg6S0SE=";
                  unpack = "tar zxf $src";
                  install = "cp swiftly $out/bin/swiftly";
                  extraNativeBuildInputs = [ ];
                }
              else if stdenv.isDarwin then
                {
                  url = "https://download.swift.org/swiftly/darwin/swiftly-${version}.pkg";
                  sha256 = "sha256-k5MvTejZ8zgWjwHidtMRQhukpTjmU2JdnrOKdqIWz2c=";
                  unpack = ''
                    xar -xf $src
                    cat Payload | gunzip | cpio -id
                  '';
                  install = "cp .swiftly/bin/swiftly $out/bin/swiftly";
                  extraNativeBuildInputs = [ pkgs.xar ];
                }
              else
                throw "swiftly: unsupported system ${stdenv.hostPlatform.system}";
          in
          stdenv.mkDerivation {
            inherit pname version;

            src = pkgs.fetchurl {
              inherit (platformConfig) url sha256;
            };

            nativeBuildInputs = [ makeWrapper ] ++ platformConfig.extraNativeBuildInputs;

            unpackPhase = platformConfig.unpack;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              ${platformConfig.install}
              chmod +x $out/bin/swiftly
              runHook postInstall
            '';

            meta = with lib; {
              description = "A Swift toolchain installer and manager, written in Swift.";
              homepage = "https://github.com/swiftlang/swiftly";
              license = licenses.asl20;
              platforms = platforms.all;
            };
          };
      in
      {
        packages = {
          inherit swiftly;
        };

        devShells.default =
          with pkgs;
          mkShell rec {
            nativeBuildInputs = with pkgs; [
              just
              # swift
              # swiftpm
              swiftly
              rustup

              clang
              # binutils
              gcc
              perl
              curl
              git
              cacert
              gnupg
              fontconfig
              pkg-config
            ];

            buildInputs = with pkgs; [
              dbus
              ncurses
              sqlite
              libxml2_13
              swiftPackages.Dispatch
            ];

            shellHook = ''
              SWIFTLY_HOME="''${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}"
              SWIFT_TOOLCHAIN=$(ls -1 "$SWIFTLY_HOME/toolchains" 2>/dev/null | sort -V | tail -1)
              export SWIFT_LIBRARY_PATH="$SWIFTLY_HOME/toolchains/$SWIFT_TOOLCHAIN/usr/lib/swift_static/linux"
            '';

            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
            SLINT_ENABLE_EXPERIMENTAL_FEATURES = 1;
          };
      }
    );
}
