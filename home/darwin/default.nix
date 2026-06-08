{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../base/core
      ../base/tui
      ../base/gui
    ];
  # enable management of XDG base directories on macOS.
  xdg.enable = true;
}
