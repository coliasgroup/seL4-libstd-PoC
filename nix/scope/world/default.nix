{ lib
, buildSysroot
, here
, patched
}:

self: super: with self;

{
  testSystem = callPlatform {
    system = mkSystem {
      rootTask = mkTask {
        inherit (patched) rustEnvironment;
        rootCrate = here.crates.test;
        release = false;
        # replaceSysroot = args: buildSysroot args;
      };
    };
  };
}
