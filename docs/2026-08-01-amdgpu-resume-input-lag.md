# AMDGPU resume-related input lag investigation

## Status

The immediate performance failure has been reproduced and measured, and a display-mode toggle reliably cleared it once. The lower-level component responsible for leaving the GPU in the bad state has not been isolated beyond the AMDGPU/SMU/display path.

No persistent workaround has been implemented yet. Before using the proven mode toggle after every resume, the next recurrence should be used to test whether reapplying the current mode fixes the GPU state without briefly blanking the monitor.

## Affected system

- Host: `the-spine`
- GPU: AMD Radeon RX 6800 XT (`1002:73bf`, `amdgpu`)
- Monitor: Acer XV340CK P on `DP-3`
- Display mode: 3440×1440 at 143.923 Hz
- Compositor: Niri unstable 2026-06-18, commit `49fc611`
- Kernel during investigation: Linux 7.0.12
- Mesa during investigation: 26.1.2, RADV
- Game: The Artisan of Glimmith, Steam app 4160210
- Game path: D3D11 through DXVK/RADV and Xwayland using Proton Hotfix
- LACT: 0.9.0 with automatic performance level, a 271 W power cap, and fan-curve control

## Symptom

After a fresh boot, the game performs normally. After quitting and reopening it—particularly after the machine has suspended—the following can occur:

- Mouse input in the game feels delayed.
- Typing in unrelated applications is delayed while the game is open.
- Closing the game restores normal desktop responsiveness.
- Restarting Steam without rebooting does not clear the problem.

The desktop-wide effect initially looked like an input-stack problem, but measurements showed that input delivery was downstream of a saturated GPU.

## Confirmed bad state

With the game open and both in-game mouse input and terminal typing lagging:

- GPU busy: 99%
- GPU memory busy: 94–99%
- GPU clock: approximately 2.37–2.39 GHz
- VRAM clock: fixed at 96 MHz, the lowest exposed DPM state
- GPU power: approximately 93–105 W
- Game GPU-engine use: approximately 102% over a five-second DRM fdinfo sample
- Game CPU use: approximately 112–125%
- Niri GPU-engine use: approximately 2%
- VRAM use: approximately 4.2 GiB of 16 GiB
- No thermal throttling was reported.
- No contemporaneous AMDGPU kernel errors were logged.

Relevant commands:

```bash
dev=/sys/class/drm/card1/device
cat "$dev/gpu_busy_percent"
cat "$dev/mem_busy_percent"
cat "$dev/pp_dpm_sclk"
cat "$dev/pp_dpm_mclk"
cat "$dev/power_dpm_force_performance_level"
lact cli stats
```

The bad `pp_dpm_mclk` state looked like:

```text
0: 96Mhz *
1: 456Mhz
2: 673Mhz
3: 1000Mhz
```

## Recovery test and confirmed good state

Changing Niri's live output mode from 143.923 Hz to 120 Hz immediately improved mouse and typing responsiveness:

```bash
niri msg output DP-3 mode '3440x1440@120.000'
```

In the improved state:

- VRAM rose to 1000 MHz under game load.
- GPU busy dropped below saturation; observed samples ranged from 57–82%.
- GPU memory busy dropped to approximately 30–47%.
- Game GPU-engine use was 23% in one five-second sample.
- Game CPU use fell to approximately 47%.
- Input responsiveness returned to normal.

Switching back to the original mode did not reintroduce the problem:

```bash
niri msg output DP-3 mode '3440x1440@143.923'
```

At 143.923 Hz after the reset, input remained normal and VRAM stayed at 1000 MHz under load. This shows that 143.923 Hz itself is not the cause. Triggering a real modeset cleared stale post-resume GPU/display state.

## What has been ruled out

### Stale Steam or Proton process state

The game and Steam were fully exited, and no Steam, Proton, Wine, pressure-vessel, or game-overlay processes remained. Relaunching Steam and the game without rebooting reproduced the lag.

### A simple uncapped-frame-rate problem

The game's configuration recorded VSync enabled and a 60 FPS limit. Reducing the configured limit to 30 FPS did not change the symptom or GPU saturation. The original 60 FPS and 3440×1440 settings were restored afterward.

### GPU core performance policy

Temporarily setting `power_dpm_force_performance_level` to `high` was accepted by the kernel but did not improve responsiveness or change the 96 MHz VRAM state. Automatic mode was restored afterward.

### Steam overlay or compositor as the dominant GPU client

DRM fdinfo deltas attributed essentially all graphics-engine use to `Geri-Win64-Shipping.exe`. Niri, Xwayland, Steam, the terminal, and the browser each used a small fraction by comparison.

## Inconclusive tests and related observations

### Explicit VRAM DPM selection

The following test was attempted:

```bash
echo manual | sudo tee /sys/class/drm/card1/device/power_dpm_force_performance_level
echo 3 | sudo tee /sys/class/drm/card1/device/pp_dpm_mclk
```

The kernel left state 0 selected, so this did not actually test performance at a forced 1000 MHz VRAM clock. Automatic mode was restored. Do not treat the unchanged symptom as evidence against the VRAM-clock diagnosis.

### LACT resume errors

After each resume, LACT reloaded its configuration. It also logged errors while restoring manual fan control:

```text
could not set fan speed: io error: Invalid argument (os error 22)
disabling fan control
```

The kernel logged:

```text
Failed to set manual fan control mode
manual fan speed control should be enabled first
```

These errors correlate with resume but do not establish that LACT caused the VRAM DPM failure. LACT's configuration uses `performance_level: auto` and does not configure memory clocks.

### High I/O pressure accounting

`vmstat` and `/proc/pressure/io` reported high I/O wait even when storage devices were idle and desktop input felt normal. Because it persisted in both good and bad input states, it is not currently considered causal. It may deserve a separate investigation.

## Current diagnosis

The immediate cause of the desktop-wide lag is GPU queue saturation while the RX 6800 XT's VRAM remains at 96 MHz under game load. A display modeset restores normal 1000 MHz VRAM scaling and removes the saturation and lag.

The most likely boundary containing the lower-level fault is the post-resume AMDGPU SMU/display state. Current evidence does not distinguish among a kernel/AMDGPU regression, firmware behavior, or an interaction with Niri's output restoration. The modeset is a workaround, not a claimed upstream root-cause fix.

## Plan for the next recurrence

When the lag recurs, keep the game open and do not change game, GPU, or display settings before collecting evidence.

### 1. Confirm the same failure signature

```bash
dev=/sys/class/drm/card1/device
niri msg outputs | head -5
printf 'busy='; cat "$dev/gpu_busy_percent"
printf 'mem_busy='; cat "$dev/mem_busy_percent"
printf 'performance_level='; cat "$dev/power_dpm_force_performance_level"
cat "$dev/pp_dpm_sclk"
cat "$dev/pp_dpm_mclk"
lact cli stats
```

Expected signature: lag is present, GPU and memory busy are near 100%, performance level is `auto`, and `pp_dpm_mclk` marks 96 MHz as active.

### 2. Test the no-blank same-mode request

Request the already active mode without first switching to another mode:

```bash
niri msg output DP-3 mode '3440x1440@143.923'
```

Immediately test mouse movement and typing, then repeat the measurements above.

The no-blank approach passes only if all of the following occur:

1. Input becomes normal.
2. VRAM reaches 1000 MHz under the same game load.
3. GPU and memory busy fall materially below saturation.
4. The monitor does not visibly blank.

If the request is a no-op or any criterion fails, reject this approach.

### 3. Reconfirm the proven fallback if needed

```bash
niri msg output DP-3 mode '3440x1440@120.000'
niri msg output DP-3 mode '3440x1440@143.923'
```

Recheck input and GPU state. This fallback was proven during the original investigation, but it should be reconfirmed on the next recurrence before automation.

## Persistent workaround design

Implement a host-specific post-resume action for `the-spine` only.

The action should:

1. Run after resume, not before suspend.
2. Wait for Xian's Niri IPC socket and `DP-3` output to become available, with a bounded timeout.
3. Run `niri msg` as user `xian` with the discovered `NIRI_SOCKET`.
4. Use the same-mode request if the next recurrence proves it works.
5. Otherwise use the proven 120 Hz → 143.923 Hz toggle.
6. Log which workaround ran and whether both Niri commands succeeded.
7. Treat failure as non-fatal so a resume is never blocked by the workaround.

The configuration should live near the existing GPU and sleep settings in `hosts/the-spine.nix`, or in a narrowly named module imported only by that host if the service definition would obscure the host file. Comments must describe the observed 96 MHz post-resume VRAM state and why a modeset is required.

A manual command should remain documented here even after automation, both as a recovery path and as a way to test whether the workaround is still necessary.

## Verification plan for the persistent workaround

1. Build without activating:

   ```bash
   nh os build -q
   ```

2. Activate only after a successful build.
3. Suspend and resume the system.
4. Verify the post-resume action ran successfully in the journal.
5. Launch The Artisan of Glimmith at 3440×1440 and 60 FPS.
6. Confirm mouse and terminal typing are normal.
7. Confirm VRAM reaches 1000 MHz under load and GPU load is no longer pinned at 99%.
8. Repeat a suspend/resume cycle with Steam already running.
9. Confirm failures in socket/output discovery are logged but do not block resume.

## Removal and retest criteria

This workaround should be easy to find and remove because a future kernel, Mesa, Niri, firmware, or LACT update may resolve the lower-level issue.

After a relevant update:

1. Temporarily disable the post-resume action.
2. Rebuild and activate the configuration.
3. Perform at least three suspend/resume cycles.
4. After each cycle, launch or relaunch the game and check input responsiveness.
5. Under comparable game load, verify that VRAM reaches 1000 MHz without a manual modeset.
6. If all cycles pass, remove the workaround and update this document with the versions that resolved it.
7. If any cycle reproduces the 96 MHz state, restore the workaround and record the tested versions.

## Manual recovery

Until automation is implemented, use:

```bash
niri msg output DP-3 mode '3440x1440@120.000'
niri msg output DP-3 mode '3440x1440@143.923'
```

This may briefly blank the monitor. It changes only Niri's live output configuration and leaves the configured preferred mode unchanged.
