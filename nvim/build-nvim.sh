#! /usr/bin/env bash
set -e
brew install ninja cmake gettext curl

rm -rf /tmp/neovim
mkdir -p /tmp/neovim
INSTALL_DIR="$HOME/bin/neovim"

git clone -b v0.12.4 https://github.com/neovim/neovim.git /tmp/neovim
cd /tmp/neovim

make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$INSTALL_DIR" DEPS_CMAKE_FLAGS="-DCMAKE_CXX_COMPILER=$(xcrun -find c++)"

make install

ln -sf "$INSTALL_DIR/bin/nvim" "$HOME/bin/nvim"
