{ mk, localCrates }:

mk {
  package.name = "test";
  dependencies = {
    inherit (localCrates)
      sel4
      sel4-root-task
    ;
  };
}
