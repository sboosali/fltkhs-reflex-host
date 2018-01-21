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
  name = "fltk-examples-${version}";
  version = "0.1";
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
    # gcc -o fltk-image fltk-image.cxx 
    fltk-config --use-images --compile fltk-image.cxx
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp fltk-image $out/bin
  '';

  meta = {
    description = "runnable FLTK examples";
#    maintainers = with lib.maintainers; [ sboosali ];
  };

}
