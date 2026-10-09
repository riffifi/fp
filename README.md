# ThinkPad P1 fingerprint setup for Ubuntu 26.04

Makes the Synaptics `06cb:009a` reader work using patched
[python-validity](https://github.com/uunicorn/python-validity) and
[open-fprintd](https://github.com/uunicorn/open-fprintd).

The patches restrict verification to the Linux account's sensor record, require
root to register backends or suspend/resume them, and disable verbose sensor
logging. Older on-device account records are preserved.

## Build and install

Targets Ubuntu 26.04 amd64 with `fprintd` / `libpam-fprintd` version `1.94.5-4`.
No third-party apt repository is needed. Build dependencies:

```sh
sudo apt install git build-essential debhelper dh-python python3-setuptools python3-dbus python3-gi python3-usb python3-yaml python3-cryptography innoextract libpam-fprintd
./build-fingerprint-driver.sh
sudo ./apply-fingerprint-driver.sh
fprintd-list "$USER"
fprintd-enroll -f right-index-finger "$USER"
fprintd-verify -f right-index-finger "$USER"
```

After verification reports `verify-match`:

```sh
sudo ./enable-fingerprint-login.sh
sudo -k true
```

Place the enrolled finger on the reader when prompted. Password authentication
remains available as fallback. Installation downloads and extracts Lenovo's
firmware using upstream's hash-checked downloader.

Generated source checkouts, logs, and packages are ignored under `.work/` and
`artifacts/`. Patches apply to pinned upstream commits; client executables are
extracted from Ubuntu's official `fprintd` package during the build.

## Rollback

```sh
sudo pam-auth-update --disable fprintd
sudo apt remove python3-validity open-fprintd
sudo apt install fprintd libpam-fprintd
```

The replacement services are community software. The included authorization
checks address backend registration and lifecycle calls; they are not a complete
security audit of the upstream services.

See [fingerprint-notes.md](fingerprint-notes.md) for machine-specific results,
validation limits, and the existing PAM backup location.
