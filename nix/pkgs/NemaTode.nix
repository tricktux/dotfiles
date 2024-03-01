{ lib
, pkgs
, stdenv
, fetchFromGitHub
}:

let
  llvm = pkgs.llvmPackages_12;
  clang = llvm.clang;
in
with lib;

stdenv.mkDerivation {
  name = "NemaTode";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "internationalcybernetics";
    repo = "NemaTode";
    rev = "81609d4d3f4f1595e6b22fcbdf9000edc7d999e2";
    hash = "sha256-/GjeZhVXnHhqexMkvCvkbj6zdaci1i8Z3cDiuu8IUuY=";
  };

  cmakeFlags = [
    "-DCMAKE_C_COMPILER=clang"
    "-DCMAKE_CXX_COMPILER=clang++"
    "-GNinja"
  ];
  enableParallelBuilding = true;
  buildInputs = [ clang ];
  nativeBuildInputs = with pkgs; [ cmake ninja pkg-config ];

  meta = {
    description = "Cross platform C++ 11 NMEA Parser & GPS Framework";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
