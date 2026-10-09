#!/bin/sh
set -eu
[ "$(id -u)" -eq 0 ] || { echo 'Run this script with sudo or pkexec.' >&2; exit 1; }
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$repo_dir/artifacts"
for package in open-fprintd_0.7~ppa2_all.deb python3-validity_0.15~ppa2_all.deb; do
    [ -f "$package" ] || { echo "Missing package: $package. Run build-fingerprint-driver.sh first." >&2; exit 1; }
done
# A sensor reboot triggers udev, which can otherwise race systemctl stop.
[ "$(systemctl is-enabled python3-validity 2>/dev/null || true)" != masked ] || {
    echo 'python3-validity is already masked; resolve that before installation.' >&2
    exit 1
}
systemctl mask --runtime python3-validity
trap 'systemctl unmask --runtime python3-validity; systemctl daemon-reload' EXIT
systemctl stop python3-validity || true
systemctl stop open-fprintd || true
/usr/bin/apt-get install -y --reinstall ./open-fprintd_0.7~ppa2_all.deb ./python3-validity_0.15~ppa2_all.deb
systemctl unmask --runtime python3-validity
systemctl daemon-reload
systemctl restart open-fprintd
systemctl restart python3-validity
systemctl enable python3-validity open-fprintd-resume open-fprintd-suspend
