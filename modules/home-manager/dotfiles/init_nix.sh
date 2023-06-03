#... Hack to get away with single user (non-daemon) Nix installations
if [[ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
  source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi
