# AGENTS.md

Guidance for AI coding agents working in this repository.

## What this repo is

A distribution repo for prebuilt Windows `libdvdcss-2.dll` binaries (used by
HandBrake). There is no source code, build system, or tests here — just
compiled DLLs and a README documenting how they were built.

## Layout

```
<version>/32-bit/libdvdcss-2.dll   # PE32, Intel 80386
<version>/64-bit/libdvdcss-2.dll   # PE32+, x86-64
README.md                          # user instructions + build notes
```

- Every version directory has exactly two files: `32-bit/` and `64-bit/`, each
  containing `libdvdcss-2.dll` (that exact filename).
- `src/` (downloaded libdvdcss source) and `dist/` (release archives) are
  gitignored scratch space. Never commit them.

## Adding a new version

For meson-based releases (1.5.0+), `.claude/skills/new-release/scripts/build.sh <version>`
automates steps 1–4 and bundles the `dist/` archives; see
`.claude/skills/new-release/SKILL.md` for the full release flow.

1. Build both architectures following the README section for that version
   (meson + mingw-w64 for 1.5.0+, autotools `./configure --host=...` for
   1.4.3 and earlier). Build source lives in `src/`.
2. Copy the outputs into `<version>/32-bit/` and `<version>/64-bit/`.
3. **Verify the architecture of each DLL before committing:**
   ```sh
   file <version>/*/libdvdcss-2.dll
   ```
   32-bit must report `PE32 ... Intel 80386`; 64-bit must report
   `PE32+ ... x86-64`. The two files must not be identical (`cmp` them).
   This has gone wrong before: 1.5.0 was first committed with the 32-bit DLL
   in both slots because upstream's `INSTALL` has a typo in the 64-bit
   command (see README).
4. DLLs are tracked with mode `100755`; keep that (`chmod +x`).
5. Update `README.md` if build steps changed.

## Conventions

- Never modify or rebuild existing versioned DLLs unless explicitly asked to
  fix a broken one.
- Commit messages are short and imperative, e.g. `Add version 1.5.0`,
  `Fix 64-bit library for version 1.5.0`.
- Release bundling (tarball/zip in `dist/`) is described at the bottom of the
  README.
