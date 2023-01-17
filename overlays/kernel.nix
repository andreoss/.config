final: prev: {
  linux = (prev.pkgs.linuxKernel.manualConfig {
    inherit (prev) stdenv lib;
    version = "6.2.0-rc4";
    configfile = ./config-huge;
    allowImportFromDerivation = true;
    src = prev.pkgs.fetchurl {
      url = "https://git.kernel.org/torvalds/t/linux-6.2-rc4.tar.gz";
      sha256 = "sha256-dyNCXhEjQbW953MoUVeB15NOq+2Dc/0UzIWtruly0PA";
    };
  }).overrideAttrs (attrs: { });
  linuxPackages =
    prev.pkgs.recurseIntoAttrs (prev.pkgs.linuxPackagesFor final.linux);
}
