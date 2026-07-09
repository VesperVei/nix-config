{lib, ...} @ args: let
  data = [
    (import ./src/ctf-pwn.nix args)
    (import ./src/aly-2h2g.nix args)
  ];
in {
  homeConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.homeConfigurations or {}) data
  );

  debugAttrs = {
    inherit data;
  };
}
