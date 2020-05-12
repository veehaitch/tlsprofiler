with import <nixpkgs> { };

mkShell {
  buildInputs = [ (callPackage ./default.nix { }) ];
}
