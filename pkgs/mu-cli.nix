{ fetchFromGitHub, stdenv }: stdenv.mkDerivation {
  name = "mu-cli";
  src = fetchFromGitHub {
    owner = "mu-semtech";
    repo = "mu-cli";
    rev = "875dd1dd034e76aedc96b090446c1dff69c0a1ed";
    hash = "sha256-uV5K5aqDXv8OvotVC5omDVv7v4T0K8g6JYvZST7NmZc=";
  };

  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/mu $out/bin/
    chmod +x $out/bin/mu
  '';
}
