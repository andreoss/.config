self: super: {
  emacs = super.pkgs.emacs.override {
    withToolkitScrollBars = false;
    withAthena = true;
    nativeComp = true;
  };
}
