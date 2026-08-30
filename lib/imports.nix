{ lib }:
let
  importDir =
    {
      exclude ? [ ],
      recursive ? true,
    }:
    dir:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
      isModuleFile =
        n:
        lib.hasSuffix ".nix" n
        && n != "default.nix"
        && !(builtins.elem n exclude);
      files = builtins.filter (n: entries.${n} == "regular" && isModuleFile n) names;
      dirs = builtins.filter (n: entries.${n} == "directory" && !(builtins.elem n exclude)) names;
      importedFiles = builtins.map (n: import (dir + "/${n}")) files;
      importedDirs =
        builtins.map (
          d:
          let
            sub = dir + "/${d}";
          in
          if builtins.pathExists (sub + "/default.nix") then
            import (sub + "/default.nix")
          else
            importDir { inherit exclude; recursive = true; } sub
        ) dirs;
    in
    importedFiles ++ lib.optionals recursive importedDirs;
in
{
  inherit importDir;
}
