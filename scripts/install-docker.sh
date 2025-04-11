#!/bin/bash

set -e

if [ "$(id -u)" != '0' ]; then
  # Restart script as postgres user when run as root.
  echo "$(basename "$0") requires to be run as root. Entering root..."
  exec sudo -- "${BASH_SOURCE[0]}" "$@"
fi

## See https://docs.docker.com/engine/install/debian/

conflicting_packages=(
  docker.io
  docker-doc
  docker-compose
  podman-docker
  containerd
  runc
)

docker_packages=(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
  docker-compose-plugin
)

# shellcheck disable=SC2016
apt-get remove --yes "$(
  dpkg-list \
    --showformat '${db:Status-Abbrev}\t${Binary:Package}\n' \
    --show "${conflicting_packages[@]}" |
    grep '^ii' |
    awk '{ print $2 }'
)"
apt-get install --yes "${docker_packages[@]}"
