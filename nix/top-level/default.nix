self: with self;

let
in {
  inherit (base) lib pkgs worlds;

  inherit (pkgs.host.aarch64.none) this;

  world = worlds.aarch64.default;

  inherit (world) testSystem;

  inherit (testSystem) simulate;

  build = testSystem.links;

  test =
    let
      inherit (pkgs.build) python3 writeScript runtimeShell;
      py = python3.withPackages (pkgs: [
        pkgs.pexpect
      ]);
    in
      writeScript "test" ''
        #!${runtimeShell}
        set -eu

        ${py}/bin/python3 ${../../test.py} ${simulate}
      '';

  inherit (pkgs.build.this) nativeTest;
}
