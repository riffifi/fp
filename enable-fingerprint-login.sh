#!/bin/sh
# Run only after fprintd-verify reports verify-match.
set -eu
[ "$(id -u)" -eq 0 ] || { echo 'Run this script with sudo or pkexec.' >&2; exit 1; }
backup_dir="/var/backups/fingerprint-setup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
for file in common-auth common-account common-password common-session common-session-noninteractive; do
    cp -a "/etc/pam.d/$file" "$backup_dir/$file"
done
DEBIAN_FRONTEND=noninteractive /usr/sbin/pam-auth-update --enable fprintd
printf 'PAM backup: %s\n' "$backup_dir"
