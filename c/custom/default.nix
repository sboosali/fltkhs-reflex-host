{ stdenv #, lib

, fltk
, libpng
, libjpeg
, zlib

# TODO identify platform-specific dependencies with fltk-config
, libXrender
, libXfixes
, libXft
, fontconfig
 
}:

# fltk-image

let
  name = "fltk-example-${subname}-${version}";
  version = "0.1";

  filename = "fltk-${subname}";
  subname = "custom";

in

stdenv.mkDerivation {
  inherit name version;

  src = ./.; 

  buildInputs = [ 
    fltk
    libpng zlib libjpeg 
    libXrender libXfixes libXft fontconfig 
  ];
  
  buildPhase = ''
    fltk-config --use-images --compile ${filename}.cxx 
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${filename} $out/bin
  '';

}
