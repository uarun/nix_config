{ pkgs, config, ... }:
{
  launchd.user.agents.colima = {
    serviceConfig = {
      Label = "com.colima.docker";
      ProgramArguments = [
        "${pkgs.colima}/bin/colima" "start"
        "--vm-type" "vz"
        "--arch" "aarch64"
        "--memory" "4"  # GB of RAM allocated to the VM
      ];
      EnvironmentVariables = {
        PATH = "${pkgs.docker}/bin:${pkgs.coreutils}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "${config.user.home}/Library/Logs/colima.stdout.log";
      StandardErrorPath = "${config.user.home}/Library/Logs/colima.stderr.log";
    };
  };
}
