{ lib, mkDerivation, fetchgit, fetchurl, cmake, darkhttpd, gettext, makeWrapper, pkg-config
, libdigidocpp, opensc, openldap, openssl, pcsclite, qtbase, qttranslations, qtsvg }:

mkDerivation rec {
  pname = "qdigidoc";
  version = "4.2.8";

  src = fetchgit {
    url = "https://github.com/open-eid/DigiDoc4-Client";
    rev = "v${version}";
    sha256 = "02k2s6l79ssvrksa0midm7bq856llrmq0n40yxwm3j011nvc8vsm";
    fetchSubmodules = true;
  };

  tsl = fetchurl {
    url = "https://ec.europa.eu/tools/lotl/eu-lotl-pivot-300.xml";
    sha256 = "1cikz36w9phgczcqnwk4k3mx3kk919wy2327jksmfa4cjfjq4a8d";
  };

  # Adds explicit imports for QPainterPath, fixed in upstream (https://github.com/open-eid/DigiDoc4-Client/pull/914)
  patches = [ ./qt5.15.patch ];

  nativeBuildInputs = [ cmake darkhttpd gettext makeWrapper pkg-config ];

  postPatch = ''
    substituteInPlace client/CMakeLists.txt \
      --replace $\{TSL_URL} file://${tsl}
  '';

  buildInputs = [
    libdigidocpp
    opensc
    openldap
    openssl
    pcsclite
    qtbase
    qtsvg
    qttranslations
  ];

  postInstall = ''
    wrapProgram $out/bin/qdigidoc4 \
      --prefix LD_LIBRARY_PATH : ${opensc}/lib/pkcs11/
  '';

  meta = with lib; {
    description = "Qt-based UI for signing and verifying DigiDoc documents";
    homepage = "https://www.id.ee/";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ yegortimoshenko mmahut ];
  };
}
