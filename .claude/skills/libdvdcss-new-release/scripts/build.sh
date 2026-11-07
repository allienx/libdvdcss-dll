#!/usr/bin/env bash
# Build 32-bit and 64-bit libdvdcss-2.dll for a given upstream version,
# copy them into <version>/{32,64}-bit/, verify, and bundle dist/ archives.
#
# Usage: build.sh <version>      (run from the repo root)
#
# Supports meson-based releases (1.5.0+). Older autotools releases are
# documented in README.md and must be built by hand.
set -euo pipefail

VERSION="${1:?usage: build.sh <version>}"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TARBALL="libdvdcss-${VERSION}.tar.xz"
URL="https://download.videolan.org/pub/libdvdcss/${VERSION}/${TARBALL}"
SRC="src/libdvdcss-${VERSION}"
NAME="libdvdcss-dll-${VERSION}"

if [[ -e "$VERSION" ]]; then
  echo "error: $VERSION/ already exists in the repo" >&2
  exit 1
fi

for tool in curl shasum meson ninja i686-w64-mingw32-gcc x86_64-w64-mingw32-gcc file zip; do
  command -v "$tool" >/dev/null || { echo "error: missing tool: $tool" >&2; exit 1; }
done

# --- Download and verify source -------------------------------------------
mkdir -p src
if [[ ! -f "src/$TARBALL" ]]; then
  curl -fL -o "src/$TARBALL" "$URL"
fi
expected="$(curl -fsSL "${URL}.sha256" | awk '{print $1}')"
actual="$(shasum -a 256 "src/$TARBALL" | awk '{print $1}')"
if [[ "$expected" != "$actual" ]]; then
  echo "error: sha256 mismatch for $TARBALL (expected $expected, got $actual)" >&2
  exit 1
fi
echo "sha256 OK: $actual"

rm -rf "$SRC"
tar -xJf "src/$TARBALL" -C src

[[ -f "$SRC/meson.build" ]] || { echo "error: $SRC has no meson.build (autotools release?)" >&2; exit 1; }

# --- Build ----------------------------------------------------------------
# Note: upstream INSTALL has a typo for 64-bit; use the x86_64 cross file.
build() {
  local dir="$1" crossfile="$2"
  (cd "$SRC" && meson setup "$dir" --cross-file "package/crossfiles/$crossfile" && ninja -C "$dir")
}
build build-w32 i686-w64-mingw32.meson
build build-w64 x86_64-w64-mingw32.meson

# --- Copy into repo -------------------------------------------------------
mkdir -p "$VERSION/32-bit" "$VERSION/64-bit"
cp "$SRC/build-w32/src/libdvdcss-2.dll" "$VERSION/32-bit/libdvdcss-2.dll"
cp "$SRC/build-w64/src/libdvdcss-2.dll" "$VERSION/64-bit/libdvdcss-2.dll"
chmod 755 "$VERSION"/*/libdvdcss-2.dll

# --- Verify architectures -------------------------------------------------
f32="$(file -b "$VERSION/32-bit/libdvdcss-2.dll")"
f64="$(file -b "$VERSION/64-bit/libdvdcss-2.dll")"
echo "32-bit: $f32"
echo "64-bit: $f64"
[[ "$f32" == PE32\ * && "$f32" == *"Intel 80386"* ]] || { echo "error: 32-bit DLL is not PE32/i386" >&2; exit 1; }
[[ "$f64" == PE32+* && "$f64" == *"x86-64"* ]] || { echo "error: 64-bit DLL is not PE32+/x86-64" >&2; exit 1; }
if cmp -s "$VERSION/32-bit/libdvdcss-2.dll" "$VERSION/64-bit/libdvdcss-2.dll"; then
  echo "error: 32-bit and 64-bit DLLs are identical" >&2
  exit 1
fi

# --- Bundle dist/ archives ------------------------------------------------
mkdir -p dist
rm -rf "dist/$NAME" "dist/$NAME.tar.gz" "dist/$NAME.zip"
mkdir "dist/$NAME"
cp -R "$VERSION/" "dist/$NAME"
(cd dist && tar -czf "$NAME.tar.gz" "$NAME/" && zip -qr "$NAME.zip" "$NAME/")

echo
echo "Built $VERSION:"
ls -l "$VERSION"/*/libdvdcss-2.dll "dist/$NAME.tar.gz" "dist/$NAME.zip"
