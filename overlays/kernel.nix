final: prev: {
  linux = (prev.pkgs.linuxKernel.manualConfig {
    inherit (prev) stdenv lib;
    version = "6.1.0-rc6";
    configfile = ./.config;
    allowImportFromDerivation = true;
    src = prev.pkgs.fetchurl {
      url = "https://git.kernel.org/torvalds/t/linux-6.1-rc6.tar.gz";
      hash = "sha256-yW1r4F5h8iGK5F53QCW50/pJTRos1kMLnfJmlpsssew=";
    };
  }).overrideAttrs (attrs: {
    postConfigure = ''
       export PATH=$PATH:${prev.pkgs.kmod}/bin
       make $makeFlags "''${makeFlagsArray[@]}" localyesconfig
    '';

  });
  linuxPackages =
    prev.pkgs.recurseIntoAttrs (prev.pkgs.linuxPackagesFor final.linux);
}
