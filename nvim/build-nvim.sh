#! /usr/bin/env bash
brew install ninja cmake gettext curl
mkdir -p /tmp/neovim
git clone -b v0.12.4 https://github.com/neovim/neovim.git /tmp/neovim
cd /tmp/neovim

make CMAKE_BUILD_TYPE=Release DEPS_CMAKE_FLAGS="-DCMAKE_CXX_COMPILER=$(xcrun -find c++)"
make install
