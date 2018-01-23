#!/bin/bash
nix-shell --pure --run 'fltk-config --use-images --compile fltk-image.cxx && ./fltk-image && rm fltk-image'
