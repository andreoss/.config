self: super: {
  linuxSw = super.pkgs.linuxKernel.manualConfig {
    inherit (super) stdenv lib;
    inherit (super.pkgs.linuxKernel.kernels.linux_testing) src;
    version = "6.1.0-rc3-ptrck";
    configfile = ./.config;
    allowImportFromDerivation = true;
  };
  linuxSwPackages = super.pkgs.recurseIntoAttrs (super.pkgs.linuxPackagesFor self.linuxSw);
}
