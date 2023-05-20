{
  allowBroken = false;
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "roon-server"
    "vscode"
  ];
}
