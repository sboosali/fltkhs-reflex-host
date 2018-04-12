{ nixpkgs ? import <nixpkgs> {}

}: 

with nixpkgs;

callPackage ./. { 
  inherit (xorg) libXrender libXfixes libXft; 
}
