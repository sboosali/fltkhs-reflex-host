{ mkDerivation, base, dependent-sum, fltkhs, mtl, ref-tf, reflex
, stdenv, text, transformers
}:
mkDerivation {
  pname = "fltkhs-reflex";
  version = "0.0.1";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base dependent-sum fltkhs mtl ref-tf reflex text transformers
  ];
  executableHaskellDepends = [ base ];
  homepage = "http://github.com/sboosali/fltkhs-reflex-host#readme";
  description = "reflex bindings for fltkhs";
  license = stdenv.lib.licenses.gpl2;
}
