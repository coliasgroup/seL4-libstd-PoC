{ lib
, runCommandNoCC
}:

self: super: with self; {

  overrideWorldScope = callPackage ./world {};

  here = {
    rustEnvironment = defaultRustEnvironment.override {
      vendoredSuperLockfile = vendorLockfile { lockfile = ../../Cargo.lock; };
    };

    crates = callPackage ./crates.nix {};
  };

  patchToolchainSrc = toolchain: src:
    let
    in
      runCommandNoCC "${toolchain.name}-patched" {} ''
        mkdir -p $out/bin $out/lib $out/lib/rustlib/src

        for f in $(find ${toolchain}/bin -type f -mindepth 1 -maxdepth 1 -printf '%P\n'); do
          install ${toolchain}/bin/$f $out/bin

          if [ $f != rustfmt ]; then
            continue
          fi

          if isELF $out/bin/$f; then
            patchelf --set-rpath $out/lib $out/bin/$f || true
          fi
        done

        for file in $(find ${toolchain}/lib -name 'librustc_driver-*'); do
          install $file $out/lib
        done

        ln -s ${src} $out/lib/rustlib/src/rust

        for d in . $(find $out -type d -printf '%P\n'); do
          if [ -d ${toolchain}/$d ]; then
            for entry in $(find ${toolchain}/$d -mindepth 1 -maxdepth 1 -printf '%P\n'); do
              if [ ! -e $out/$d/$entry ]; then
                ln -s ${toolchain}/$d/$entry $out/$d
              fi
            done
          fi
        done
      ''
    ;

  patched = rec {
    src = ../../../rust;

    filteredSrc = lib.cleanSourceWith rec {
      inherit src;
      filter = name: type:
        name == "${toString src}/Cargo.toml" || name == "${toString src}/Cargo.lock" || lib.hasPrefix "${toString src}/library" name
      ;
    };

    rustEnvironment = here.rustEnvironment.override (old: {
      rustToolchain = patchToolchainSrc old.rustToolchain filteredSrc;
    });
  };

  sysroot = buildSysroot {
    inherit (patched) rustEnvironment;
    release = false;
  };

  nativeTest = buildCratesInLayers {
    inherit (patched) rustEnvironment;
    rootCrate = here.crates.native-test;
    release = false;
    commonModifications = crateUtils.elaborateModifications {
      modifyConfig = lib.flip lib.recursiveUpdate {
        target.${defaultRustTargetTriple.name}.rustflags = [
          "--sysroot" sysroot
        ];
      };
    };
  };
}
