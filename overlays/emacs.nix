final: prev: {
  emacs = (prev.pkgs.emacs.override {
    withToolkitScrollBars = false;
    withAthena = true;
    withXwidgets = false;
    nativeComp = true;
    enableParallelBuilding = false;
  }).overrideAttrs( old : {} );
}
