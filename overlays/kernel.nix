final: prev: {
  linux = (prev.pkgs.linuxKernel.manualConfig {
    inherit (prev) stdenv lib;
    version = "6.3.0-rc1";
    configfile = ./config-huge;
    allowImportFromDerivation = true;
    src = prev.pkgs.fetchurl {
      url = "https://git.kernel.org/torvalds/t/linux-6.3-rc1.tar.gz";
      sha256 = "sha256-oZhG9dYlRthT4TbRNuJ+/Kw/mRuGTIu2E9Dw5ge+xCo=";
    };
  }).overrideAttrs (attrs: { });
  linuxPackages =
    prev.pkgs.recurseIntoAttrs (prev.pkgs.linuxPackagesFor final.linux);
}
