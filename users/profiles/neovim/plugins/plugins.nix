{ pkgs, ... }:
with pkgs.vimUtils; with pkgs; {


  neoranger = buildVimPluginFrom2Nix {
    name = "neoranger-git-2019-06-11";
    src = fetchTarball {
      url = "https://github.com/Lokaltog/neoranger/archive/5edfbdd5c14d589f4f57ba1dab28a9072107cb83.tar.gz";
      sha256 = "1s4r868w98890d5lp0spf37bfv6sb6z4an3p3q14fwd2sb0ysq8f";
    };
    meta = {
      homepage = https://github.com/Lokaltog/neoranger;
      maintainers = [ stdenv.lib.maintainers.jagajaga ];
    };
  };


  bundler = buildVimPluginFrom2Nix {
    name = "bundler-git-2022-05-03";
    src = fetchTarball {
      url = "https://github.com/tpope/vim-bundler/archive/43da96e6ea726c1a91b8b7ceea1d6019df4231d7.tar.gz";
      sha256 = "1x935ak93niqvqxz90vrmnqzl7d5c8lhaxnvq0n9vc6byxydydqp";
    };
    meta = {
      homepage = https://github.com/tpope/vim-bundler;
      maintainers = [ stdenv.lib.maintainers.jagajaga ];
    };
  };


  racket = buildVimPluginFrom2Nix {
    name = "racket-git-2021-04-10";
    src = fetchTarball {
      url = "https://github.com/wlangstroth/vim-racket/archive/32ad23165c96d05da7f3b9931d2889b7e39dcb86.tar.gz";
      sha256 = "1yyqx471p11vj6gya4yzkiy07vfwzpx10bf6s7dh2h7zp2nz10br";
    };
    meta = {
      homepage = https://github.com/wlangstroth/vim-racket;
      maintainers = [ stdenv.lib.maintainers.jagajaga ];
    };
  };

}
