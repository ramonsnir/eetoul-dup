#!/bin/bash

export INSTALL_PATH="/opt"
export LIBGIT2_VERSION="v0.23.3"

# Install other dependencies
if [ ! -d "$INSTALL_PATH/libgit2" ]; then
  rm -fr "$INSTALL_PATH/_build_libgit2" 2>/dev/null || [ 1 -eq 1 ]
  mkdir -p "$INSTALL_PATH/_build_libgit2"
  cd "$INSTALL_PATH/_build_libgit2"
  rm "$LIBGIT2_VERSION.tar.gz" 2>/dev/null || [ 1 -eq 1 ]
  wget "https://github.com/libgit2/libgit2/archive/$LIBGIT2_VERSION.tar.gz"
  tar -xzf "$LIBGIT2_VERSION.tar.gz"
  mv libgit2-*/* .
  mkdir build && cd build
  cmake ..
  cmake --build .
  mkdir -p "$INSTALL_PATH/libgit2"
  cmake .. -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH/libgit2"
  cmake --build . --target install
fi
