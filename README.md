# libdvdcss

From the [website](http://www.videolan.org/developers/libdvdcss.html):

> libdvdcss is a simple library designed for accessing DVDs like a block device without having to bother about the decryption.

This repository hosts the compiled `libdvdcss-2.dll` for Windows. Download
the `.dll` from this repository and drop it into the Handbrake installation
folder to convert your DVDs to mp4 files.

## Instructions

* Pick the version of libdvdcss you want (the highest version should be fine).
* Download the appropriate `libdvdcss-2.dll` from this repository.
* Move `libdvdcss-2.dll` into the Handbrake installation folder (usually `C:\Program Files\HandBrake`).
* Enjoy ripping your DVDs. Please use responsibly.

## Compile libdvdcss yourself (for versions 1.5.0 and later)

These steps do the same thing as
`.claude/skills/libdvdcss-new-release/scripts/build.sh <version>`. Run them
from the repo root.

Install the tools:

```sh
# macOS
brew install meson ninja mingw-w64

# Debian/Ubuntu
sudo apt-get install meson ninja-build mingw-w64
```

Download the source from [download.videolan.org](https://download.videolan.org/pub/libdvdcss/)
and check it against upstream's checksum:

```sh
VERSION=1.6.0
mkdir -p src
curl -fL -o src/libdvdcss-$VERSION.tar.xz \
  https://download.videolan.org/pub/libdvdcss/$VERSION/libdvdcss-$VERSION.tar.xz
curl -fsSL https://download.videolan.org/pub/libdvdcss/$VERSION/libdvdcss-$VERSION.tar.xz.sha256 \
  | (cd src && shasum -a 256 -c -)   # must print "OK"
tar -xJf src/libdvdcss-$VERSION.tar.xz -C src
```

Build both architectures. The `INSTALL` file has a typo: its 64-bit command
uses the `i686` cross file, which builds a second 32-bit DLL. Use the
`x86_64` cross file instead:

```sh
cd src/libdvdcss-$VERSION

# 32-bit
meson setup build-w32 --cross-file package/crossfiles/i686-w64-mingw32.meson
ninja -C build-w32

# 64-bit
meson setup build-w64 --cross-file package/crossfiles/x86_64-w64-mingw32.meson
ninja -C build-w64

cd ../..
```

Copy the DLLs into the repo:

```sh
mkdir -p $VERSION/32-bit $VERSION/64-bit
cp src/libdvdcss-$VERSION/build-w32/src/libdvdcss-2.dll $VERSION/32-bit/
cp src/libdvdcss-$VERSION/build-w64/src/libdvdcss-2.dll $VERSION/64-bit/
chmod 755 $VERSION/*/libdvdcss-2.dll
```

Check the architectures before committing:

```sh
file $VERSION/*/libdvdcss-2.dll
# 32-bit/... PE32 executable (DLL) (console) Intel 80386, for MS Windows
# 64-bit/... PE32+ executable (DLL) (console) x86-64, for MS Windows

cmp $VERSION/32-bit/libdvdcss-2.dll $VERSION/64-bit/libdvdcss-2.dll
# must report that the files differ
```

Then bundle the release archives (see [Bundling a release](#bundling-a-release)).

## Compile libdvdcss yourself (for versions 1.4.3 and earlier)

**Either Linux, macOS, or Windows 10 is required.**

These instructions are tailored for those familiar with the command line on a Linux machine. I documented them so I don't forget them.

Download the libdvdcss [source code](http://download.videolan.org/pub/libdvdcss/).

For Windows 10:

* Open the Ubuntu VM built into Windows 10 (Windows Subsystem for Linux).
* `cd` to the directory the source code was downloaded to (the path to your Downloads folder in the Ubuntu VM is `/mnt/c/Users/<username>/Downloads`).

Run the following to build `libdvdcss-2.dll`:

```sh
# macOS
brew install mingw-w64

# Windows 10 and Ubuntu
sudo apt-get install mingw-w64

tar -xjf /path/to/libdvdcss.tar.bz2
cd /path/to/libdvdcss

# 32-bit
./configure --host=i686-w64-mingw32

# 64-bit
./configure --host=x86_64-w64-mingw32

make
# .libs/libdvdcss-2.dll

# Run 'make clean' before compiling again.
```

### Troubleshooting

If you get an error like `WARNING: 'aclocal-1.15' is missing on your system.`

```sh
touch aclocal.m4 Makefile.am Makefile.in
```

## Bundling a release

From the repo root, with `VERSION` set as above:

```sh
NAME=libdvdcss-dll-$VERSION
rm -rf dist/$NAME dist/$NAME.tar.gz dist/$NAME.zip
mkdir -p dist/$NAME
cp -R $VERSION/32-bit $VERSION/64-bit dist/$NAME/

cd dist
tar -czf $NAME.tar.gz $NAME/
zip -qr $NAME.zip $NAME/
cd ..
```

Each archive should contain `libdvdcss-dll-<version>/32-bit/libdvdcss-2.dll`
and `libdvdcss-dll-<version>/64-bit/libdvdcss-2.dll`.

## Publishing a release

Commit only the new version directory (`src/` and `dist/` are gitignored):

```sh
git add $VERSION
git commit -m "Add version $VERSION"
```

Tag, push, and create the GitHub release:

```sh
git tag v$VERSION
git push origin main v$VERSION
gh release create v$VERSION \
  dist/libdvdcss-dll-$VERSION.tar.gz dist/libdvdcss-dll-$VERSION.zip \
  --title v$VERSION \
  --notes "Read the official [changelog](https://code.videolan.org/videolan/libdvdcss/-/blob/$VERSION/NEWS?ref_type=tags)."
```

Tags use a `v` prefix. A re-release that fixes a broken build of an existing
version gets a `-N` suffix (e.g. `v1.5.0-1`) and a sentence in the notes
explaining the fix.
