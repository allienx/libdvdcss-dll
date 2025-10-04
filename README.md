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

* Download the source code from the repository [here](https://code.videolan.org/videolan/libdvdcss).
* Follow the instructions in the `INSTALL` file for Windows.
  * You will need to install `meson` and `mingw-w64`

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

```sh
mkdir dist/libdvdss-dll-<version>
cp -R <version>/ dist/libdvdss-dll-<version>
```

Create a `.tar.gz` archive:

```sh
cd dist
tar -czf libdvdcss-dll-<version>.tar.gz libdvdcss-dll-<version>/
```

Create a `zip` archive:

```sh
cd dist
zip -r libdvdcss-dll-<version>.zip libdvdcss-dll-<version>/
```
