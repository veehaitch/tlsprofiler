{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, fetchFromGitHub ? pkgs.fetchFromGitHub
, fetchurl ? pkgs.fetchurl
, python3Packages ? pkgs.python3Packages
, zlib ? pkgs.zlib
, openssl ? pkgs.openssl_1_1
, opensslLegacy ? pkgs.openssl_1_0_2
, ...
}:
let
  tlsparser = pkgs.callPackage ./tlsparser.nix { };
  zlibStatic = zlib.override { static = true; splitStaticOutput = false; };
  nasslOpensslArgs = {
    static = true;
    enableSSL2 = true;
  };
  nasslOpensslFlagsCommon = [
    "zlib"
    "no-zlib-dynamic"
    "no-shared"
    "--with-zlib-lib=${zlibStatic.out}/lib"
    "--with-zlib-include=${zlibStatic.out.dev}/include"
    "enable-rc5"
    "enable-md2"
    "enable-gost"
    "enable-cast"
    "enable-idea"
    "enable-ripemd"
    "enable-mdc2"
    "-fPIC"
  ];
  opensslStatic = (openssl.override nasslOpensslArgs).overrideAttrs (
    oldAttrs: rec {
      name = "openssl-${version}";
      version = "1.1.1";
      src = fetchurl {
        url = "https://www.openssl.org/source/${name}.tar.gz";
        sha256 = "0gbab2fjgms1kx5xjvqx8bxhr98k4r8l2fa8vw7kvh491xd8fdi8";
      };
      configureFlags = oldAttrs.configureFlags ++ nasslOpensslFlagsCommon ++ [
        "enable-weak-ssl-ciphers"
        "enable-tls1_3"
        "no-async"
      ];
      patches = [ ./patches/nix-ssl-cert-file.patch ];
      buildInputs = oldAttrs.buildInputs ++ [ zlibStatic ];
    }
  );
  opensslLegacyStatic = (opensslLegacy.override nasslOpensslArgs).overrideAttrs (
    oldAttrs: rec {
      name = "openssl-${version}";
      version = "1.0.2e";
      src = fetchurl {
        url = "https://www.openssl.org/source/${name}.tar.gz";
        sha256 = "1zqb1rff1wikc62a7vj5qxd1k191m8qif5d05mwdxz2wnzywlg72";
      };
      configureFlags = oldAttrs.configureFlags ++ nasslOpensslFlagsCommon;
      patches = [ ];
      buildInputs = oldAttrs.buildInputs ++ [ zlibStatic ];
    }
  );
in
python3Packages.buildPythonPackage rec {
  name = "nassl";
  version = "3.0.0";
  src = fetchFromGitHub {
    owner = "nabla-c0d3";
    repo = name;
    rev = version;
    sha256 = "1dhgkpldadq9hg5isb6mrab7z80sy5bvzad2fb54pihnknfwhp8z";
  };

  postPatch = ''
    sed -i 's/_DEPS_PATH = Path.*$/_DEPS_PATH = Path("deps")/g' build_tasks.py

    mkdir -p deps/openssl-OpenSSL_1_0_2e/
    cp ${opensslLegacyStatic.out}/lib/libssl.a \
      ${opensslLegacyStatic.out}/lib/libcrypto.a \
      deps/openssl-OpenSSL_1_0_2e/
    ln -s ${opensslLegacyStatic.out.dev}/include deps/openssl-OpenSSL_1_0_2e/include 

    mkdir -p deps/openssl-OpenSSL_1_1_1/
    cp ${opensslStatic.out}/lib/libssl.a \
      ${opensslStatic.out}/lib/libcrypto.a \
      deps/openssl-OpenSSL_1_1_1/
    ln -s ${opensslStatic.out.dev}/include deps/openssl-OpenSSL_1_1_1/include 

    mkdir -p deps/zlib-1.2.11/
    cp ${zlibStatic.out}/lib/libz.a deps/zlib-1.2.11/
  '';

  propagatedBuildInputs = with python3Packages; [ tlsparser pytest ];

  meta = {
    homepage = "https://github.com/nabla-c0d3/nassl";
    description = "Low-level OpenSSL wrapper for Python 3.7+.";
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    maintainers = [{ name = "Vincent Haupert"; email = "mail@vincent-haupert.de"; }];
  };
}
