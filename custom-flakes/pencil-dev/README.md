# pencil-dev

Nix flake for [Pencil](https://pencil.dev) — design tool packages.

## Packages

| Package    | Binary      | Description          |
|------------|-------------|----------------------|
| `pencil`   | `pencil`    | CLI (`@pencil.dev/cli`) |
| `pencil-gui` | `pencil-gui` | GUI (Electron desktop app) |

## Usage

```nix
inputs.pencil-dev.url = "github:your-username/pencil-dev";

# In home.packages:
inputs.pencil-dev.packages.x86_64-linux.pencil
inputs.pencil-dev.packages.x86_64-linux.pencil-gui
```

## SKILL.md

The CLI package includes a SKILL.md for AI agents at:
`${pencil}/share/doc/pencil/SKILL.md`
