{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, fetchFromGitHub ? pkgs.fetchFromGitHub
, python3Packages ? pkgs.python3Packages
, nassl ? pkgs.callPackage ./nassl.nix { }
, ...
}:
python3Packages.buildPythonPackage rec {
  name = "sslyze";
  version = "3.0.4";
  src = fetchFromGitHub {
    owner = "nabla-c0d3";
    repo = name;
    rev = version;
    sha256 = "19fnnbdmpfdpmadqqcnj79hh72wrjiahn58rbxis4586ydyi552g";
  };

  propagatedBuildInputs = with python3Packages; [ nassl cryptography typing-extensions faker ];

  meta = {
    homepage = "https://github.com/nabla-c0d3/sslyze";
    description = "Fast and powerful SSL/TLS scanning library.";
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    maintainers = [{ name = "Vincent Haupert"; email = "mail@vincent-haupert.de"; }];
  };
}
