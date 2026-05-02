---
name: custom-flake-patterns
description: Use when packaging software not in nixpkgs as a custom flake, adding local flakes to a NixOS/home-manager config, or troubleshooting flake lock issues with local inputs.
---

# Custom Flake Patterns

Patterns and pitfalls for self-contained Nix flakes packaging software outside
nixpkgs (Electron apps, npm CLI tools, prebuilt binaries) and wiring them into
a config flake. Not a rigid template — every flake makes its own choices.

## Quick Reference

| Situation | Pattern |
|-----------|---------|
| Multi-arch packages | `flake-utils` → `eachDefaultSystem` |
| Local flake as input | `path:custom-flakes/name` (not `git+file://`) |
| Proprietary/unfree | `import nixpkgs { config.allowUnfree = true; }` |
| Pin fetch hash | Start with `""`, build, copy from error output |
| Pin npm deps hash | Start with `""`, build, copy `npmDepsHash` |
| Default output | `packages.<system>.default` (not `defaultPackage`) |
| Electron app | `autoPatchelfHook` + system libs in `buildInputs` |
| npm CLI | `buildNpmPackage`; generate lockfile if tarball lacks one |
| Node binary not +x | `chmod +x` entry point in `postInstall` |

## Key Patterns

### Scaffolding

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      in {
        packages = {
          default = self.packages.${system}.my-pkg;
          my-pkg = pkgs.callPackage ./my-pkg.nix { };
        };
      }
    );
}
```

### Wiring local flakes

Use `path:`, not `git+file://`. `git+file://` locks the repo's narHash and
breaks on every commit. `path:` is simpler and Just Works.

```nix
# In main flake.nix:
my-flake.url = "path:custom-flakes/my-flake";
```

### Hash discovery

Start with empty hashes, build, copy the reported hash from the error output:

```nix
src = fetchurl {
  url = "https://example.com/app.tar.gz";
  sha256 = "";   # build → copy hash → replace
};
```

Same iterative pattern for `npmDepsHash`. Pin the fetch hash first, rebuild to
get the deps hash. Both come from separate build attempts.

### Self-contained design

Limit inputs to `nixpkgs` + `flake-utils`. The flake can be moved to its own
repo later with zero changes. Version pins (hashes, package versions) live at
the top of `flake.nix` for easy bumping.

## Package-Specific Patterns

**Electron / prebuilt binaries:**
- `autoPatchelfHook` + `makeWrapper`; `buildInputs` needs the full set: `stdenv.cc.cc.lib`, `alsa-lib`, `gtk3`, `nss`, `cairo`, `pango`, `libx11`, `libxcb`, `libxkbcommon`, `libgbm`, `dbus`, `cups`
- `installPhase`: copy to `$out/lib/<pkg>/`, symlink binary to `$out/bin/`
- `postFixup`: `wrapProgram $out/bin/<pkg> --prefix LD_LIBRARY_PATH : $out/lib/<pkg>`
- Use `copyDesktopItems` + `makeDesktopItem` for `.desktop` file

**npm CLI tools:**
- `buildNpmPackage` (not `nodePackages`) for reproducibility
- If tarball lacks `package-lock.json`: generate with `runCommand`, vendor alongside derivation
- `npmPackFlags = [ "--ignore-scripts" ]`; `dontNpmBuild = true` for pre-built
- `sourceRoot = "package"` (npm tarballs extract to `package/`)
- `postInstall`: `chmod +x` entry point, symlink to `$out/bin/`, copy extra files

## Common Mistakes

- **`git+file://` for local flakes** — narHash drifts on every commit. Use `path:`.
- **`defaultPackage`** — deprecated. Use `packages.<system>.default`.
- **Node symlink not executable** — entry point may lack `+x`. `chmod +x` first.
- **Missing system libs** — `autoPatchelfHook` can only patch found libraries. Check with `ldd`.
- **Stale lock after adding input** — run `nix flake lock --update-input <name> --allow-dirty-locks`.
