{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, fetchFromGitHub ? pkgs.fetchFromGitHub
, python3Packages ? pkgs.python3Packages
, ...
}:
python3Packages.buildPythonPackage rec {
  name = "tls_parser";
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "nabla-c0d3";
    repo = name;
    rev = version;
    sha256 = "1gpfn3bw3lah5d0rar8mba8jv81n7r5vaqyj4p8lzqic95g5fh1n";
  };

  meta = {
    homepage = "https://github.com/nabla-c0d3/tls_parser";
    description = "Small library to parse TLS records.";
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    maintainers = [{ name = "Vincent Haupert"; email = "mail@vincent-haupert.de"; }];
  };
}
