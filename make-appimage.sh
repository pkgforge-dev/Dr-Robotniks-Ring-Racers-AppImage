#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q ringracers | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/pixmaps/org.kartkrew.RingRacers.png
export DESKTOP=/usr/share/applications/org.kartkrew.RingRacers.desktop
export STARTUPWMCLASS=ringracers
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun /usr/bin/ringracers

# Turn AppDir into AppImage
quick-sharun --make-appimage
