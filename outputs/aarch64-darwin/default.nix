{lib, ...} @ args: let
  data = [
    (import ./src/zaochuan.nix args)
    (import ./src/chenhun.nix args)
  ];
in {
  homeConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.homeConfigurations or {}) data
  );

  debugAttrs = {
    inherit data;
  };
}
