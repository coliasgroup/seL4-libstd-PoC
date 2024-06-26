{ lib
}:

self: super: with self; {

  here = {
    defaultRustEnvironment = defaultRustEnvironment.override {
      vendoredSuperLockfile = vendorLockfile { lockfile = ../../Cargo.lock; };
    };

    buildCratesInLayers = buildCratesInLayers.override {
      inherit (here) defaultRustEnvironment;
    };

    crates = callPackage ./crates.nix {};
  };

  overrideWorldScope = callPackage ./world {};

}
