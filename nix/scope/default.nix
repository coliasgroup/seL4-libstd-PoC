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

    rustSrcRaw =
      let
        # useLocal = true;
        useLocal = false;
        rev = "b8eab835a6030ca12a2e846f3706391bf6a8be0d";
      in
        if useLocal
        then ../../../rust
        else builtins.fetchGit {
          url = "https://github.com/coliasgroup/rust.git";
          ref = sources.mkKeepRef rev;
          inherit rev;
          submodules = true;
        };

    rustSrc = lib.cleanSourceWith rec {
      src = rustSrcRaw;
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
