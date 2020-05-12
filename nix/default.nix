{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, fetchFromGitHub ? pkgs.fetchFromGitHub
, python3Packages ? pkgs.python3Packages
, nassl ? pkgs.callPackage ./nassl.nix { }
, sslyze ? pkgs.callPackage ./sslyze.nix { }
, ...
}:
let
  nasslTlsprofiler = nassl.overrideAttrs (
    oldAttrs: rec {
      version = "2.2.0";
      src = fetchFromGitHub {
        owner = "fabian-hk";
        repo = "nassl";
        rev = "7321a149b98175ca20af41561eb04bcb3b7cba41";
        sha256 = "124sx3b0a6bq1w0w5vx4prczmck8n46knxz19ma7acnw5mrdbnx4";
      };
    }
  );
  sslyzeTlsprofiler = (sslyze.override { nassl = nasslTlsprofiler; }).overrideAttrs (
    oldAttrs: rec {
      version = "2.1.4";
      src = fetchFromGitHub {
        owner = "fabian-hk";
        repo = "sslyze";
        rev = "0594f493b3580cb6e639b78de509d4f785ae8c50";
        sha256 = "1y0liz36c1wprxk8sik7n8ysydwklclqk6vp81m7chj9p2n2sh4d";
      };

      # Tests are broken before 3.0.0
      # https://github.com/nabla-c0d3/sslyze/issues/417
      doInstallCheck = false;
    }
  );
in
python3Packages.buildPythonPackage rec {
  name = "tlsprofiler";
  version = "1.0";
  src = pkgs.fetchFromGitHub {
    owner = "danielfett";
    repo = name;
    rev = "c4a9cdcf951343ef6cf670df9351c197c6aaab80";
    sha256 = "1ng9ba1w6x9x86cngxx9p4dfjzkf3nn0w4ibn1kmwnf2rgdl6clw";
  };

  # Tests require network
  doCheck = false;

  patches = [ ./patches/nix-tlsprofiler-requirements.patch ];

  propagatedBuildInputs = with python3Packages; [ pytest requests cryptography nasslTlsprofiler sslyzeTlsprofiler ];

  meta = {
    homepage = "https://tlsprofiler.danielfett.de";
    description = "Compare the configuration of a TLS server to the Mozilla TLS configuration recommendations";
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    maintainers = [{ name = "Vincent Haupert"; email = "mail@vincent-haupert.de"; }];
  };
}