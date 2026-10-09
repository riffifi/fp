# Machine setup and validation

Hardware: ThinkPad P1 (`20MD000QMX`), Synaptics USB `06cb:009a`.
System: Ubuntu 26.04.1 LTS amd64, kernel `7.0.0-29-generic`, Python `3.14.4`.
Stock `fprintd 1.94.5-4` and `libfprint 1.95.1` reported no devices.

## Changes made

Installed locally built `open-fprintd 0.7~ppa2` and `python3-validity 0.15~ppa2`,
replacing the stock daemon while retaining `libpam-fprintd` and official client
commands. No third-party apt repository was added.

Sources are pinned in the build script:
- python-validity: `a6bbc21dce7b8b3c3cd92378a0b2579a2fb45920`
- open-fprintd: `b7073730bccca36e84484e3fcb4f8253ea038d07`

The sensor had an older account record with two fingerprints. Initial Linux
enrollment succeeded, but verification returned `verify-no-match`. Restricting
the sensor matcher to the Linux user and storage IDs produced `verify-match`.
Older account records were preserved; only the newly created Linux sample was
deleted once during re-enrollment.

Local patches also require root for backend registration and Suspend/Resume
calls, disable verbose sensor logging, and adapt packaging to Ubuntu 26.04.
The replacement package provides `fprintd (= 1.94.5-4)` to satisfy the installed
PAM module dependency; builds must be reviewed if Ubuntu changes that version.

Enabled the driver at boot, suspend/resume hooks, and fingerprint PAM
authentication with password fallback. PAM files before enabling fingerprint
login are backed up in `/var/backups/fingerprint-setup-20261010/`.

## Evidence and remaining checks

Completed during initial setup:
- Reader detection and right index finger enrollment.
- `fprintd-verify`: `verify-match` after account-specific matching was installed.
- Fresh `sudo -k /usr/bin/true`: fingerprint prompt, exit 0 without a password.
- Live unprivileged backend registration: `PermissionDenied`.
- Daemon restart and reader detection.
- `dpkg --audit`: no incomplete packages.

Cleanup audit on October 10, 2026:
- Both daemons active with verbose logging disabled.
- Driver and suspend/resume hooks enabled.
- Right index and right middle fingers currently listed for `leo`.
- PAM includes fingerprint authentication and password fallback.
- No incomplete packages reported.
- Clean build from pinned upstream sources and saved patches succeeded.
- Shell syntax checks passed for all three scripts.

A real suspend/resume, reboot, and graphical lock-screen login remain untested.
The original request is satisfied for reader use and sudo authentication; these
remaining checks determine behavior across the full desktop lifecycle.

## Reproduction and troubleshooting

Use the commands in [README.md](README.md) to build, install, enroll, enable,
and roll back. Keep the local patches: upstream packages omit these fixes.

```sh
journalctl -u python3-validity -u open-fprintd -n 80 --no-pager
```

Reported startup issues for this hardware and Python 3.14:
- https://github.com/uunicorn/python-validity/issues/271
- https://github.com/uunicorn/python-validity/issues/272
- https://github.com/uunicorn/python-validity/pull/273

Those proposed startup changes were not needed or applied on this machine.
Avoid factory reset if existing on-device fingerprints need to be preserved.
