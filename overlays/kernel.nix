final: prev: {
  linux = (prev.pkgs.linuxKernel.manualConfig {
    inherit (prev) stdenv lib;
    version = "6.1.0-rc8";
    configfile = ./config-huge;
    allowImportFromDerivation = true;
    src = prev.pkgs.fetchgit {
      url = "git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git";
      rev = "v6.1-rc8";
      sha256 = "sha256-KSAotMNO3u+Y02txyCG7ax4YLt87Wwon6o2G8pMVZZY=";
    };
  }).overrideAttrs (attrs: { });
  linuxPackages =
    prev.pkgs.recurseIntoAttrs (prev.pkgs.linuxPackagesFor final.linux);
}
