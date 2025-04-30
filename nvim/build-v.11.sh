brew install ninja cmake gettext curl
mkdir -p /tmp/neovim-v11
git clone -b release-0.11 https://github.com/neovim/neovim.git /tmp/neovim-v11
cd /tmp/neovim-v11
make CMAKE_BUILD_TYPE=Debug MACOSX_DEPLOYMENT_TARGET=15.4 DEPS_CMAKE_FLAGS="-DCMAKE_CXX_COMPILER=$(xcrun -find c++)"
sudo make install
# TEST_FILTER_OUT='does not deadlock' make test
