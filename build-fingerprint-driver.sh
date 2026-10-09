#!/bin/sh
# Build patched Ubuntu 26.04 drivers without adding an apt repository.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$repo_dir/.work" "$repo_dir/artifacts"
build_dir=$(mktemp -d "$repo_dir/.work/build.XXXXXX")
for project in python-validity open-fprintd; do
    git clone "https://github.com/uunicorn/$project.git" "$build_dir/$project"
done
git -C "$build_dir/python-validity" checkout --detach a6bbc21dce7b8b3c3cd92378a0b2579a2fb45920
git -C "$build_dir/open-fprintd" checkout --detach b7073730bccca36e84484e3fcb4f8253ea038d07
for project in python-validity open-fprintd; do
    git -C "$build_dir/$project" apply "$repo_dir/patches/$project.patch"
done
# Preserve the official client tools and match libpam-fprintd's exact dependency.
# This setup targets fprintd 1.94.5-4 on Ubuntu 26.04.
(cd "$build_dir" && apt-get download fprintd=1.94.5-4)
dpkg-deb -x "$build_dir/fprintd_1.94.5-4_amd64.deb" "$build_dir/stock-fprintd"
mkdir -p "$build_dir/open-fprintd/clients"
for client in enroll list delete verify; do
    cp "$build_dir/stock-fprintd/usr/bin/fprintd-$client" "$build_dir/open-fprintd/clients/"
done
for project in open-fprintd python-validity; do
    (cd "$build_dir/$project" && dpkg-buildpackage -us -uc -b)
done
cp "$build_dir/open-fprintd_0.7~ppa2_all.deb" "$repo_dir/artifacts/"
cp "$build_dir/python3-validity_0.15~ppa2_all.deb" "$repo_dir/artifacts/"
printf 'Packages saved to %s/artifacts\n' "$repo_dir"
