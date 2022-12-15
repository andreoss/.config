final: prev: {
  linux = (prev.pkgs.linuxKernel.manualConfig {
    inherit (prev) stdenv lib;
    version = "6.1.0";
    configfile = ./config-huge;
    allowImportFromDerivation = true;
    src = prev.pkgs.fetchgit {
      url = "git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git";
      rev = "v6.1";
      sha256 = "sha256-7HBzP6P/7KLCfKas4TRFfCutG0azFzV+IpQABtDMHnk=";
    };
  }).overrideAttrs (attrs: { });
  linuxPackages =
    prev.pkgs.recurseIntoAttrs (prev.pkgs.linuxPackagesFor final.linux);
}
