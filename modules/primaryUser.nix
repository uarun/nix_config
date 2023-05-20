{
  config,
  lib,
  options,
  ...
}:
let
  inherit (lib) mkAliasDefinitions mkOption types;
in {
  #... Define some aliases for ease of use
  options = {
    user = mkOption {
      description = "Primary user configuration";
      type = types.attrs;
      default = {};
    };

    hmgr = mkOption {
      description = "Home Manager Bootstrap";
      type = types.attrs;
      default = {};
    };
  };

  config = {
    #... hmgr -> home-manager.users.<primary user>
    home-manager.users.${config.user.name} = mkAliasDefinitions options.hmgr;

    #... user -> users.users.<primary user>
    users.users.${config.user.name} = mkAliasDefinitions options.user;
  };
}
