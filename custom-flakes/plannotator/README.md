# Plannotator for NixOS

Standalone, CLI-only packaging of upstream **v0.29.4** for **x86_64-linux**.
The prebuilt Bun executable is patched for NixOS with `autoPatchelfHook`.
This does not run the upstream installer.

## Try before installing

From the root of this repository:

```sh
nix run ./custom-flakes/plannotator -- --version
nix run ./custom-flakes/plannotator -- review
```

The named app works too:

```sh
nix run ./custom-flakes/plannotator#plannotator -- --help
```

Run `review` inside the Git repository you want to review. From another
directory, use the absolute path to this flake.

Home Manager installs the same package through the root `plannotator` input.
Until that configuration is activated, use `nix run`; it needs no installation.

## Scope

- Git and the browser opener are supplied on the executable's PATH.
- No agent skills, plugins, hooks, services, or configuration are installed.
- Optional agent-terminal and call-flow runtimes are not bundled or tested.
  Upstream may offer to download them at runtime; they are outside this package.
- Automatic update checks and self-updates are disabled by the launcher.
  `update` (including `--check`) and `uninstall` print Nix-management advice
  instead of invoking the imperative installer/uninstaller.
- Normal use can still save application state in Plannotator's data directory.

## Verification

The `checks.x86_64-linux.startup` output checks version, help, and the
Nix-managed update guard with a disposable HOME.

After building, test the review server and argument forwarding without Home
Manager activation:

```sh
python3 custom-flakes/plannotator/tests/review.py \
  nix run "$PWD/custom-flakes/plannotator" --
```

This creates a temporary Git repository, checks its diff over HTTP with browser
launch disabled, and terminates the server afterward.

## Updating the pin

1. Download the desired release's `plannotator-linux-x64.tar.xz`.
2. Extract `plannotator-linux-x64` and verify its provenance **before patching**:

   ```sh
   gh attestation verify ./plannotator-linux-x64 \
     --repo backnotprop/plannotator \
     --source-ref refs/tags/vX.Y.Z \
     --signer-workflow backnotprop/plannotator/.github/workflows/release.yml
   ```

3. Compute the archive's fixed-output hash with `nix hash file --sri ARCHIVE`.
   Update `version` and `hash` in `flake.nix`, and the expected version in
   `tests/startup.sh`.
4. Rebuild the package/check through `nh`, rerun the standalone commands above,
   and update the root lock's local path input. Build Home Manager before
   activating it. Do not use `plannotator update`.

For v0.29.4, provenance was verified against release commit
`e23acfd5a36140a4667ee7795cf62f441ca6c2ec`.
The extracted executable's SHA-256 was
`90c68eedde7458dec1ce98991805cd1bc0e038aa9811fe7e605f31f8048b0a1f`.
Nix verifies the pinned archive hash on every fetch; provenance verification
is a pin-maintenance step, not a network-dependent build step.
