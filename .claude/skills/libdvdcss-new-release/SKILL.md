---
name: libdvdcss-new-release
description: Build and publish a new libdvdcss-dll release for a given upstream libdvdcss version (e.g. "/libdvdcss-new-release 1.6.0"). Downloads and verifies the source, cross-compiles 32/64-bit DLLs, adds them to the repo, bundles archives, and drafts the commit, tag, and GitHub release.
argument-hint: <version>
---

# New libdvdcss-dll release

Target version: `$ARGUMENTS`. If it's empty, list the versions at
https://download.videolan.org/pub/libdvdcss/ and ask which one to build.

## 1. Build

Run from the repo root:

```sh
.claude/skills/libdvdcss-new-release/scripts/build.sh <version>
```

The script:
- downloads `libdvdcss-<version>.tar.xz` into `src/` and checks it against the upstream `.sha256`
- builds both architectures with meson and the mingw-w64 cross files
- copies the DLLs to `<version>/32-bit/` and `<version>/64-bit/` (mode 755)
- checks that the 32-bit DLL is `PE32 … Intel 80386`, the 64-bit DLL is `PE32+ … x86-64`, and the two files differ
- writes `dist/libdvdcss-dll-<version>.tar.gz` and `.zip`

If it fails, stop and report the error. Don't work around a failed check.
The script only handles meson releases (1.5.0+). If the source turns out to
use autotools, follow the README's autotools instructions by hand, then run
the same `file`/`cmp` checks.

Prerequisites (macOS): `brew install meson ninja mingw-w64`.

## 2. Update the README

The README instructions are version-agnostic, so it usually doesn't need
changes. Update it only if the build steps changed. For example, add a note
if upstream's `INSTALL` changed in a way that matters, or if a script
workaround was needed.

## 3. Commit (ask first)

Show `git status` and the `file` output, then ask before committing. Stage
only `<version>/` and any README changes. Never stage `src/` or `dist/`
(they're gitignored).

Commit message: `Add version <version>`.

## 4. Tag, push, and publish the GitHub release (ask first)

These steps are public, so confirm with the user before doing them.

```sh
git tag v<version>
git push origin main v<version>
gh release create v<version> \
  dist/libdvdcss-dll-<version>.tar.gz dist/libdvdcss-dll-<version>.zip \
  --title v<version> \
  --notes "Read the official [changelog](https://code.videolan.org/videolan/libdvdcss/-/blob/<version>/NEWS?ref_type=tags)."
```

Tags use a `v` prefix. A re-release that fixes a broken build of an existing
version uses a `-N` suffix (e.g. `v1.5.0-1`) and gets a sentence in the notes
explaining the fix.
