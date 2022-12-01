final: prev: {
  linux = (prev.pkgs.linuxKernel.manualConfig {
    inherit (prev) stdenv lib;
    version = "6.1.0-rc7";
    configfile = ./config-huge;
    allowImportFromDerivation = true;
    src = prev.pkgs.fetchurl {
      url = "https://git.kernel.org/torvalds/t/linux-6.1-rc7.tar.gz";
      hash = "sha256-5S9SY7BhSIux8aWREkZE93bwiG3sDSIB8bxMG9eNFJc=";
    };
  }).overrideAttrs (attrs: {});
  linuxPackages =
    prev.pkgs.recurseIntoAttrs (prev.pkgs.linuxPackagesFor final.linux);
}
