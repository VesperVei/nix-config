{lib, ...} @ args: let
  data = [
    (import ./src/vespervei.nix args)
  ];
in {
  homeConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.homeConfigurations or {}) data
  );

  debugAttrs = {
    inherit data;
  };
}
