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
          std = true;
          src = here.rustSrc;
        });
      };
    };
  };

  sh = shell.overrideAttrs (attrs: {
    __CARGO_TESTS_ONLY_SRC_ROOT = toString ../../../../rust;
    shellHook = attrs.shellHook + ''
      hs='${
        lib.concatStringsSep " " [
            "-Z" "build-std=core,alloc,unwind,std,compiler_builtins"
            "-Z" "build-std-features=compiler-builtins-mem"
          ]
      }'
    '';
  });
}
