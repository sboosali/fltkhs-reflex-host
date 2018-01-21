{ mkDerivation

, base, dependent-sum, fltkhs, mtl, ref-tf, reflex
, stdenv, text, transformers, spiros

, fltk, libjpeg
# , cabal-install
}:
mkDerivation {
  pname = "fltkhs-reflex";
  version = "0.0.1";
  src = ./.;
  isLibrary = true;
  isExecutable = true;

  libraryHaskellDepends = [
    base dependent-sum fltkhs mtl ref-tf reflex spiros text transformers
  ];
  librarySystemDepends  = [
    # fltk libjpeg 
    # cabal-install
  ];

  # buildDepends = [ cabal-install ];
  # setupDepends = [ cabal-install ];
  
  executableHaskellDepends = [ base ];

  homepage = "http://github.com/sboosali/fltkhs-reflex-host#readme";
  description = "reflex bindings for fltkhs";
  license = stdenv.lib.licenses.gpl2;
}
