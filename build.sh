#!/bin/bash
# Kick Shaper - macOS derleme ve kurulum betigi
#
# Kullanim:
#   ./build.sh            -> derler, imzalar, dist/ klasorune koyar
#   ./build.sh install    -> yukaridakine ek olarak eklenti klasorlerine kopyalar

set -euo pipefail
cd "$(dirname "$0")"

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Bu betik yalnizca macOS icindir." >&2
    exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
    echo "Xcode Command Line Tools gerekli. Su komutu calistirip kurulumu bitir, sonra tekrar dene:" >&2
    echo "  xcode-select --install" >&2
    exit 1
fi

if ! command -v cmake >/dev/null 2>&1; then
    echo "CMake gerekli. Homebrew ile kurabilirsin:" >&2
    echo "  brew install cmake" >&2
    exit 1
fi

echo "==> Yapilandiriliyor (ilk seferde JUCE indirilir, birkac dakika surebilir)"
cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13

echo "==> Derleniyor"
cmake --build build --config Release -j "$(sysctl -n hw.ncpu)"

VST3_SRC="$(find build -type d -name '*.vst3' -print -quit)"
AU_SRC="$(find build -type d -name '*.component' -print -quit)"

if [[ -z "$VST3_SRC" || -z "$AU_SRC" ]]; then
    echo "Derleme ciktisi bulunamadi (VST3: '${VST3_SRC}', AU: '${AU_SRC}')." >&2
    exit 1
fi

echo "==> dist/ klasorune kopyalaniyor"
rm -rf dist
mkdir -p dist
cp -R "$VST3_SRC" dist/
cp -R "$AU_SRC" dist/

echo "==> Imzalaniyor (ad-hoc)"
for bundle in dist/*.vst3 dist/*.component; do
    codesign --force --deep --sign - "$bundle"
done

if [[ "${1:-}" == "install" ]]; then
    VST3_DIR="$HOME/Library/Audio/Plug-Ins/VST3"
    AU_DIR="$HOME/Library/Audio/Plug-Ins/Components"
    mkdir -p "$VST3_DIR" "$AU_DIR"

    for bundle in dist/*.vst3; do
        rm -rf "$VST3_DIR/$(basename "$bundle")"
        cp -R "$bundle" "$VST3_DIR/"
    done
    for bundle in dist/*.component; do
        rm -rf "$AU_DIR/$(basename "$bundle")"
        cp -R "$bundle" "$AU_DIR/"
    done

    # Logic'in AU listesini yenilemesi icin
    killall -9 AudioComponentRegistrar 2>/dev/null || true

    echo "==> Kuruldu:"
    echo "    $VST3_DIR"
    echo "    $AU_DIR"
else
    echo "==> Hazir. Dosyalar dist/ klasorunde. Otomatik kurmak icin: ./build.sh install"
fi
