{lib, ...} @ args: let
  data = [
    (import ./src/macbook.nix args)
    (import ./src/chenhun.nix args)
  ];
in {
  homeConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.homeConfigurations or {}) data
  );
  darwinConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.darwinConfigurations or {}) data
  );

  debugAttrs = {
    inherit data;
  };
}
