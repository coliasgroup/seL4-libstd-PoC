{ lib
, buildSysroot
, here
}:

self: super: with self;

{
  testSystem = callPlatform {
    system = mkSystem {
      rootTask = mkTask {
        inherit (here) rustEnvironment;
        rootCrate = here.crates.test;
        release = false;
        replaceSysroot = args: buildSysroot (args // {
          src = here.rustSrc;
        });
      };
    };
  };

  sh = shell.overrideAttrs (attrs: {
    __CARGO_TESTS_ONLY_SRC_ROOT = here.rustSrc;
  });
}
