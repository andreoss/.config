{
  config,
  pkgs,
  inputs,
  ...
}:
{
  config = {
    home.packages = with pkgs; [
      antiword
      expect
      inputs.ghostty.packages.x86_64-linux.default
    ];
    home.file.".config/procps/toprc".source = ./../toprc;
  };
}
