#! /usr/bin/env bash
brew install ninja cmake gettext curl
mkdir -p /tmp/neovim-v11
git clone -b v0.11.5 https://github.com/neovim/neovim.git /tmp/neovim-v11
cd /tmp/neovim-v11

make CMAKE_BUILD_TYPE=Release DEPS_CMAKE_FLAGS="-DCMAKE_CXX_COMPILER=$(xcrun -find c++)"
make install
