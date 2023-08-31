{ config, pkgs, lib, ... }:
let cfg = config.home.development.cxx;
in {
  options = {
    home.development.cxx = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      version = mkOption {
        type = types.str;
        default = "536";
      };
    };
  };
  config = {
    home.file = { ".indent.pro".text = "--original"; };
    home.packages = lib.optionals cfg.enable (with pkgs; [
      autoconf
      entr
      automake
      binutils
      ccls
      clang-analyzer
      clang-tools
      cling
      cloc
      cmake
      cppcheck
      cpplint
      ctags
      gcc
      gcovr
      gdb
      gnumake
      indent
      lcov
      pkg-config
      strace
      tinycc
      valgrind
    ]);
  };
}
