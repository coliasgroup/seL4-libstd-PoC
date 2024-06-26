{ lib
, here
}:

self: super: with self;

{
  mkTaskHere = mkTask.override {
    inherit (here) defaultRustEnvironment buildCratesInLayers;
  };

  testSystem = callPlatform {
    system = mkSystem {
      rootTask = mkTaskHere {
        rootCrate = here.crates.test;
        release = false;
      };
    };
  };
}
