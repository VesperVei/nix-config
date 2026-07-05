{lib, ...} @ args: let
  data = [
    (import ./src/ctf-pwn.nix args)
  ];
in {
  homeConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.homeConfigurations or {}) data
  );

  debugAttrs = {
    inherit data;
  };
}
