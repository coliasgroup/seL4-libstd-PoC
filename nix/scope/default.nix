{ lib
, symlinkJoin
}:

self: super: with self; {

  overrideWorldScope = callPackage ./world {};

  here = {
    rustEnvironment = defaultRustEnvironment.override {
      vendoredSuperLockfile = vendorLockfile { lockfile = ../../Cargo.lock; };
    };

    crates = callPackage ./crates.nix {};
  };

  patched = rec {
    src = ../../../rust;

    filteredSrc = lib.cleanSourceWith rec {
      inherit src;
      filter = name: type:
        name == "${toString src}/Cargo.toml" || name == "${toString src}/Cargo.lock" || lib.hasPrefix "${toString src}/library" name
      ;
    };

    rustEnvironment = here.rustEnvironment.override (old: {
      rustToolchain = symlinkJoin {
        name = "patched-toolchain";
        paths = [ old.rustToolchain ];
        postBuild =
          let
            d = "lib/rustlib/src/rust";
          in ''
            for file in $(find $out/bin -xtype f -maxdepth 1); do
              install -m755 $(realpath "$file") $out/bin

              if [[ $file =~ /rustfmt$ ]]; then
                continue
              fi

              if isELF "$file"; then
                patchelf --set-rpath $out/lib "$file" || true
              fi
            done

            for file in $(find $out/lib -name "librustc_driver-*"); do
              install $(realpath "$file") "$file"
            done

            cd $out
            rm -r ${d}
            ln -s ${filteredSrc} ${d}
          '';
      };
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
