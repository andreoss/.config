{
  lib,
  ...
}:
{
  systemd.globalEnvironment = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  };
  security =
    let
      russianCa = "https://gu-st.ru/content/lending/";
    in
    {
      pki.certificateFiles = with builtins; [
        (fetchurl {
          url = "${russianCa}/russian_trusted_root_ca_pem.crt";
          sha256 = "sha256:0135zid0166n0rwymb38kd5zrd117nfcs6pqq2y2brg8lvz46slk";
        })
        (fetchurl {
          url = "${russianCa}/russian_trusted_sub_ca_pem.crt";
          sha256 = "sha256:19jffjrawgbpdlivdvpzy7kcqbyl115rixs86vpjjkvp6sgmibph";
        })
      ];
      pki.caCertificateBlacklist = [ "CFCA EV ROOT" ];
    };
}
