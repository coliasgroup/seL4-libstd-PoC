{ lib, localCrates }:

{
  workspace = {
    resolver = "2";
    default-members = [];
    members = lib.naturalSort (lib.mapAttrsToList (_: v: v.path) localCrates);
  };

  # HACK
  patch.crates-io = {
    ring = localCrates.ring or  {
      git = "https://github.com/coliasgroup/ring.git";
      rev = "c5880ee6ae56bb684f5bb2499f1c05cef8943745"; # branch sel4
    };
  };
}
