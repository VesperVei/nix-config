{myvars, ...}: {
  networking.hostName = myvars.darwinHostName;
  networking.computerName = myvars.darwinHostName;
  system.defaults.smb.NetBIOSName = myvars.darwinHostName;
}
