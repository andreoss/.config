{ ... }:
{
  # Split into focused per-container modules under ../containers so each is a
  # small, single-responsibility definition. Only this composer is wired into
  # the "ps" host (see flake.nix); the ../containers directory lives outside
  # the auto-discovered os/ tree, so these stay ps-only.
  imports = [
    ../containers/gateway.nix
    ../containers/workstation.nix
  ];
}
