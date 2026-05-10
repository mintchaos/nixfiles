# NixOS Configuration Atlas Design

## Goal

Create a single self-contained HTML artifact that helps Xian understand the current NixOS configuration from multiple angles. The artifact should be visual, exploratory, and useful for maintenance decisions. It should document what is active, what exists but is not currently active, and how the repository might look through a dendritic capability-tree lens.

This task is documentation only. It does not refactor the Nix configuration.

## Audience

The primary audience is Xian revisiting the repository to answer questions like:

- What is actually in use on the current system?
- Which files and modules are present but dormant?
- How do the system, desktop, host, hardware, and home-manager pieces fit together?
- Where are the likely maintenance hotspots?
- Which parts could become reusable branches for future hosts?

## Output

The implementation should produce one static HTML file in the repository. The file should include all CSS inline and should not depend on external JavaScript, CSS, fonts, or CDNs.

Suggested path: `docs/nixos-configuration-atlas.html`.

## Design Direction

Use an executive-dashboard layout supported by selective maps. The artifact should be closer to an atlas than a flat inventory: it should present several mental models for understanding the same system.

The selected approach is:

1. Start with a concise dashboard of the active system.
2. Add maps only where they improve understanding.
3. Include maintenance suggestions as clearly labeled recommendations.
4. Include a dendritic lens that reframes the current repo as capability branches.
5. Include active and inactive reachability views.

## Core Lenses

### 1. At-a-Glance Dashboard

Show the current system summary in visual cards:

- Active host: `the-spine`
- Active system output: `nixosConfigurations.the-spine`
- Active standalone home-manager output: `homeConfigurations."xian@the-spine"`
- System architecture: `x86_64-linux`
- Primary desktop path: Niri on Wayland
- User: `xian`
- Build workflow: `nh` and flakes
- Major active features: home-manager, Niri, Vicinae, Dank Material Shell, Zen Browser, PipeWire, Tailscale, Docker, Steam/gaming support

### 2. Active Build Path

Show how the active flake output reaches the files that matter:

- `flake.nix`
  - `nixosConfigurations.the-spine`
    - `common/desktop-niri.nix`
      - `common/desktop.nix`
      - `inputs.niri.nixosModules.niri`
    - `hosts/the-spine.nix`
    - `hosts/the-spine-hardware-configuration.nix`
    - `home-manager.nixosModules.home-manager`
      - `home/desktop.nix`
        - `home/common/wayland.nix`
        - `home/common/apps.nix`
        - `home/common/niri/*`
        - Vicinae, Zen Browser, Dank Material Shell, and Cider MPRIS modules

Also show the standalone home-manager path:

- `homeConfigurations."xian@the-spine"`
  - imports `inputs.niri.homeModules.niri`
  - imports `home/desktop.nix`

### 3. Active vs Inactive Reachability Map

Define reachability conservatively:

- **Active** means reachable from current flake outputs or the active host path.
- **Dormant** means present in source but not exposed through the current active outputs.
- **Historical/example** means installation scaffolding, backups, or example files.
- **Local/sensitive-only** means files that are intentionally local, ignored, generated, or sensitive.

The artifact should avoid calling inactive files dead unless the repo provides clear evidence. Dormant modules may be useful future-host building blocks.

Likely inactive or dormant areas to show:

- `hosts/xian-gamingboot.nix` is present but not currently exposed as a flake output.
- `example-host.nix` and `disk.example.nix` are examples.
- `common/desktop-i3.nix` and `common/desktop-wayland.nix` are alternate desktop paths not used by `the-spine`.
- `home/portable.nix`, `home/common/x11.nix`, and i3/sway support are alternate or older paths.
- `backups/` contains historical configuration snapshots.
- `Makefile` contains older management commands that may not match current `nh` guidance.

### 4. Capability Tree / Dendritic Lens

Explain the dendritic pattern in repository-specific terms, based on the `mightyiam/dendritic` examples:

- In dendritic organization, most files are top-level modules.
- Each file represents one feature or capability.
- A capability can contribute to multiple lower-level configuration classes, such as NixOS and home-manager.
- Hosts compose capabilities rather than owning most of the structure.
- This can make adding future hosts easier because shared capabilities are explicit and reusable.

Show a conceptual capability tree for the current repo:

- Foundation
  - flakes and nix settings
  - base packages and editor/shell defaults
  - fonts and locale
- Hosts
  - `the-spine`
  - potential future hosts
  - dormant `xian-gamingboot`
- Desktop
  - common desktop base
  - Wayland base
  - Niri
    - input
    - layout
    - outputs
    - keybinds
    - spawn
    - window rules
  - alternate i3/X11 branch
- Home/User
  - apps
  - terminals
  - browsers
  - development tools
  - media/design tools
- Services
  - SSH
  - Tailscale
  - Docker
  - dnsmasq
  - PipeWire
  - Flatpak
  - printing/Avahi
- Hardware
  - GPU/graphics
  - controllers
  - input remapping
  - power/sleep
  - firmware
- Security and Secrets
  - SSH keys
  - password/keyfile handling
  - 1Password browser allowlist
  - firewall rules

The dendritic section should be framed as a lens and migration possibility, not as a mandate to refactor immediately.

### 5. Future Host Recipe

Add a visual recipe for building a future host from capability branches. Example:

`new-host = foundation + nix/flakes + user/xian + role/desktop + desktop/wayland/niri + hardware/<machine> + services/<needed>`

Use this to show current coupling:

- Good candidate branches: Niri submodules, apps, Wayland base, services like SSH/Tailscale/Docker, gaming/media support.
- Areas needing thought before reuse: host-specific user definition, display manager choice, hardware/power settings, firewall rules, boot/disk assumptions, older X11/i3 paths.

### 6. Subsystem Cards

Include cards for major subsystems with file references and status:

- Flake inputs and outputs
- System base and Nix settings
- Host `the-spine`
- Niri desktop stack
- Home-manager user stack
- Apps and development tools
- Networking and services
- Security and access
- Hardware, graphics, power, and sleep
- Gaming and media
- Dormant/alternate configurations

Each card should answer:

- What is it for?
- Which files define it?
- Is it active, dormant, historical, or local/sensitive-only?
- What are the interesting observations?
- What maintenance questions does it raise?

### 7. Maintenance Radar

Include a prioritized maintenance section. Suggestions should be framed as observations and options, not urgent defects. Each item should link to relevant files.

Candidate maintenance areas:

- Update or retire old Makefile management commands now that repository docs prefer `nh`.
- Decide whether dormant host `xian-gamingboot` should become a flake output, move to an archive, or become a future-host reference.
- Separate host-specific choices from reusable service/capability choices if future hosts are likely.
- Review old X11/i3/Sway/portable paths and mark them active alternatives, reference examples, or archive material.
- Consider whether boot/FDE documentation and implementation have drifted from current systemd-boot and disk layout assumptions.
- Review service naming inconsistencies or likely legacy options only where the source suggests them.
- Keep sensitive/local-only files clearly distinguished from documented reusable modules.

## Visual Style

The artifact should be readable in a browser without a build step. Use a polished but simple dashboard style:

- Dark theme suitable for technical reading.
- Card grid for summaries.
- CSS-only diagrams using boxes, connecting lines, badges, and nested trees.
- Status badges for active, dormant, historical/example, local/sensitive-only, and recommendation.
- Tables only where they improve scanning.
- File paths should be displayed clearly in monospace.

## Data Collection Requirements

Before writing the final artifact, inspect the relevant source files rather than guessing:

- `flake.nix`
- `README.md`
- `AGENTS.md`
- `common/*.nix`
- `hosts/*.nix`
- `home/*.nix`
- `home/common/*.nix`
- `home/common/niri/*.nix`
- `hardware/*.nix`
- `Makefile`
- `docs/plans/*` where relevant

Do not include secrets. Do not embed private key material or password hashes. If a file is sensitive or ignored, mention the category only if useful.

## Error Handling and Caveats

The artifact is based on static repository analysis. It should include a caveat that runtime state may differ from source-level reachability. For example, a package may be installed or a service may run due to state outside the current flake, but the artifact should focus on what the repository declares.

If a source file uses old or suspicious options, the artifact should label the concern as something to verify rather than claiming it is broken without testing.

## Testing / Verification

The generated HTML should be verified by:

- Opening or parsing it enough to catch malformed HTML.
- Running a simple grep or script check for accidental unfinished-marker strings.
- Confirming it references the active and inactive sections requested by Xian.
- Confirming it has no external network dependencies.

If available, use a local browser or HTML validation tooling, but do not add new project dependencies solely for validation.

## Out of Scope

- Refactoring the Nix repository into dendritic form.
- Changing flake outputs or host definitions.
- Running a system rebuild or activating any configuration.
- Adding JavaScript-heavy interactivity or a documentation generator.
- Exhaustively proving runtime service state.
