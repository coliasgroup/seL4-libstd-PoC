{ lib
, runCommandNoCC
, symlinkJoin
, lndir
}:

self: super: with self; {

  overrideWorldScope = callPackage ./world {};

  here = rec {
    rustEnvironment = defaultRustEnvironment.override {
      vendoredSuperLockfile = vendorLockfile { lockfile = ../../Cargo.lock; };
    };

    crates = callPackage ./crates.nix {};

    rustSrc =
      let
        unfiltered = ../../../rust;
      in
        lib.cleanSourceWith rec {
          src = unfiltered;
          filter = name: type:
            lib.hasPrefix "${toString src}/library" name
            || name == "${toString src}/Cargo.toml"
            || name == "${toString src}/Cargo.lock"
          ;
        };

    sysroot = buildSysroot {
      inherit (here) rustEnvironment;
      release = false;
      std = true;
      src = rustSrc;
    };

    nativeTest = buildCratesInLayers {
      inherit (here) rustEnvironment;
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
  };
}
