#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake  \
    libvpx \
    libyuv \
    ninja  \
    sdl2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

# Comment this out if you need an AUR package
#make-aur-package ringracers-data
#make-aur-package ringracers

echo "Building stable version of Ring Racers..."
echo "---------------------------------------------------------------"
REPO="https://github.com/KartKrewDev/RingRacers"
VERSION="$(curl -sL https://api.github.com/repos/KartKrewDev/RingRacers/releases/latest | grep '"tag_name"' | head -1 | cut -d '"' -f 4)"
git clone --branch "$VERSION" "$REPO" ./RingRacers
VERSION_NOV="${VERSION#v}"
echo "$VERSION_NOV" > ~/version

# Assets zip from same latest tag
curl -L -o Dr.Robotnik.s-Ring-Racers-${VERSION}-Assets.zip \
  "https://github.com/KartKrewDev/RingRacers/releases/download/$VERSION/Dr.Robotnik.s-Ring-Racers-${VERSION}-Assets.zip"

mkdir -p ./AppDir/bin
mkdir -p ./AppDir/share/games/RingRacers
bsdtar -xvf Dr.Robotnik.s-Ring-Racers-${VERSION}-Assets.zip -C ./AppDir/share/games/RingRacers

cd ./RingRacers
export CXXFLAGS="${CXXFLAGS:-} -Wp,-U_GLIBCXX_ASSERTIONS"
cmake ./ -G Ninja -Wno-dev \
    -DCMAKE_BUILD_TYPE='Release' \
    -DCMAKE_C_FLAGS="-g1 -O3" \
    -DCMAKE_CXX_FLAGS=-"g1 -O3 -fpermissive" \
    -DSRB2_CONFIG_DEV_BUILD=OFF \
    -DSRB2_SDL2_EXE_NAME="ringracers" \
    -DACSVM_INSTALL_LIB=OFF
cmake --build build -j$(nproc)
mv -v bin/ringracers ../AppDir/bin
