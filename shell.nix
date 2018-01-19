{ nixpkgs ? import <nixpkgs> {}

, compiler ? "default"

, withProfiling ? false
, withHoogle    ? false 

}:

/* Usage:

  nix-shell
  cabal configure -fFastCompile
  cabal build
  cabal run

*/

let

  inherit (nixpkgs) pkgs;
  inherit (pkgs)    fetchFromGitHub;

  lib = import "${nixpkgs.path}/pkgs/development/haskell-modules/lib.nix" { pkgs = nixpkgs; };
  hs = pkgs.haskell.lib;

  haskellPackagesWithCompiler = 
    if compiler == "default"
    then pkgs.haskellPackages
    else pkgs.haskell.packages.${compiler};

  haskellPackagesWithProfiling = 
    if withProfiling
    then haskellPackagesWithCompiler.override {
           overrides = self: super: {
             mkDerivation = args: super.mkDerivation (args // { enableLibraryProfiling = true; });
           };
         }
    else haskellPackagesWithCompiler;
                 
  haskellPackagesWithHoogle =
    if withHoogle
    then haskellPackagesWithProfiling.override {
           overrides = self: super: {
             ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
             ghcWithPackages = self.ghc.withPackages;
           };
         }
    else haskellPackagesWithProfiling;

  cabal2nixResult = src: nixpkgs.runCommand "cabal2nixResult" {
    buildCommand = ''
      cabal2nix file://"${src}" >"$out"
    '';
    buildInputs = with nixpkgs; [
      cabal2nix
    ];
  } "";

  sources = {

    reflex = fetchFromGitHub {
      owner  = "reflex-frp";
      repo   = "reflex";
      rev    = "e8029ed9db6c29b784f5ca1b8896642379680cb5";
      sha256 = "143p2yy8szd5mn3vwhk54b2y33bcsh595rks8lm33r8v1gkbhnm8";
      fetchSubmodules = true;
    };

    /* $ nix-prefetch-git https://github.com/reflex-frp/reflex

       Commit date is 2018-01-09 13:22:03 -0500
       hash is 143p2yy8szd5mn3vwhk54b2y33bcsh595rks8lm33r8v1gkbhnm8
       {
         "url": "https://github.com/reflex-frp/reflex",
         "rev": "e8029ed9db6c29b784f5ca1b8896642379680cb5",
         "date": "2018-01-09T13:22:03-05:00",
         "sha256": "143p2yy8szd5mn3vwhk54b2y33bcsh595rks8lm33r8v1gkbhnm8",
         "fetchSubmodules": true
       }
*/

    # This is where to put the output from nix-prefetch-git
    #
    # This is based on the results o
    #   nix-prefetch-git http://github.com/ekmett/mtl
    #
    # For general git fetching:
    #
    # mtl = fetchgit {
    #   url = "http://github.com/ekmett/mtl";
    #   rev = "f75228f7a750a74f2ffd75bfbf7239d1525a87fe";
    #   sha256= "032s8g8j4djx7y3f8ryfmg6rwsmxhzxha2qh1fj15hr8wksvz42a";
    # };
    #
    # Or, more efficient for github repos:
    #
    # mtl = fetchFromGitHub {
    #   owner = "ekmett";
    #   repo = "mtl";
    #   rev = "f75228f7a750a74f2ffd75bfbf7239d1525a87fe";
    #   sha256= "032s8g8j4djx7y3f8ryfmg6rwsmxhzxha2qh1fj15hr8wksvz42a";
    # };
  };

  modifiedHaskellPackages = haskellPackagesWithHoogle.override {
    overrides = self: super: {

      fltkhs = self.callPackage ../fltkhs {};

      exception-transformers = hs.dontCheck super.exception-transformers;
            # Setup: Encountered missing dependencies:
            # HUnit >=1.2 && <1.6
            # builder for ‘/nix/store/365zv27f15qplgd6gd58fa8v26x2gg5z-exception-transformers-0.4.0.5.drv’ failed with exit code 1

      reflex = hs.doJailbreak (self.callPackage (cabal2nixResult sources.reflex) {});
             # Setup: Encountered missing dependencies:
             # bifunctors >=5.2 && <5.5
             # builder for ‘/nix/store/x9ii8r831w40jbx37y3h1600zlbpcbpc-reflex-0.5.drv’ failed with exit code 1

      # Add various dependencies here.
      #
      # Local dependencies:
      # my-dependency = self.callPackage ./deps/my-dependency {};
      #
      # Local dependencies with tests disabled:
      # my-dependency = lib.dontCheck (self.callPackage ./deps/my-dependency {});
      #
      # Git dependencies:
      # mtl = self.callPackage (cabal2nixResult sources.mtl) {};
    };
  }; 

  drv = modifiedHaskellPackages.callPackage ./. {};

  env = if pkgs.lib.inNixShell then drv.env else drv;

in

  env
