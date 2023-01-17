final: prev: {
  linux = (prev.pkgs.linuxKernel.manualConfig {
    inherit (prev) stdenv lib;
    version = "6.2.0-rc4";
    configfile = ./config-huge;
    allowImportFromDerivation = true;
    src = prev.pkgs.fetchgit {
      url = "git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git";
      rev = "v6.2-rc4";
      sha256 = "sha256-7HBzP6P/7KLCfKas4TRFfCutG0azFzV+IpQABtDMHnk=";
    };
  }).overrideAttrs (attrs: { });
  linuxPackages =
    prev.pkgs.recurseIntoAttrs (prev.pkgs.linuxPackagesFor final.linux);
}
