final: prev: {
  linux = (prev.pkgs.linuxKernel.manualConfig {
    inherit (prev) stdenv lib;
    version = "6.2.5";
    configfile = ./config-huge;
    allowImportFromDerivation = true;
    src = prev.pkgs.fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.2.5.tar.xz";
      sha256 = "sha256-ZasBks9uWAigdViJRN6P6/nmHxqFFH5Hn/1EBwjO5bk=";
    };
  }).overrideAttrs (attrs: { });
  linuxPackages =
    prev.pkgs.recurseIntoAttrs (prev.pkgs.linuxPackagesFor final.linux);
}
