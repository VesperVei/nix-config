{myvars, ...}: {
  users.users.${myvars.username}.home = myvars.darwinHomeDirectory;
}
