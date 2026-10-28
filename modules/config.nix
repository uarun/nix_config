{ lib }:
{
  allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "snowsql"
      "vista-fonts"
      "vscode"
      "drawio"
      "liquibase"
      "twg"
    ];
}
