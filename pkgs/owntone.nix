{ lib
, stdenv
, fetchFromGitHub
, autoconf-archive
, autoreconfHook
, pkg-config

, gettext
, gawk
, gperf
, bison
, flex
, libconfuse
, libunistring
, sqlite
, ffmpeg
, minixml
, libgcrypt
, avahi
, zlib
, libevent
, libplist
, libsodium
, json_c
, curl
, libgpg-error

, withDefault ? true
, withAll ? false
, withChromecast ? withAll
, gnutls
, withPulseaudio ? withAll
, libpulseaudio
, withSpotify ? withDefault
, protobufc
, withWebinterface ? withDefault
, withWebsockets ? withDefault
, libwebsockets

}: stdenv.mkDerivation rec {
  pname = "owntone";
  version = "28.5";

  src = fetchFromGitHub {
    owner = pname;
    repo = "owntone-server";
    rev = version;
    sha256 = "p5tqzG0/oNCeJeD25chBliVNXbBWgAoX77AXM7b9jL8=";
  };

  nativeBuildInputs = [ autoconf-archive autoreconfHook pkg-config ];

  configureFlags =
    lib.optional withChromecast "--enable-chromecast" ++
    lib.optional withPulseaudio "--with-pulseaudio" ++
    lib.optional (!withSpotify) "--disable-spotify" ++
    lib.optional (!withWebinterface) "--disable-webinterface" ++
    lib.optional (!withWebsockets) "--without-libwebsockets";

  buildInputs = [
    gettext
    gawk
    gperf
    bison
    flex
    libconfuse
    libunistring.out.dev
    sqlite.out.dev
    ffmpeg.out.dev
    minixml
    libgcrypt.out.dev
    avahi
    zlib.out.dev
    libevent.out.dev
    libplist
    libsodium.out.dev
    json_c.out.dev
    curl.out.dev
    libgpg-error.out.dev
  ] ++ (lib.optionals withChromecast [
    gnutls
  ]) ++ (lib.optionals withPulseaudio [
    libpulseaudio.out.dev
  ]) ++ (lib.optionals withSpotify [
    protobufc
  ]) ++ (lib.optionals (withWebinterface || withWebsockets) [
    libwebsockets
  ]);
}
