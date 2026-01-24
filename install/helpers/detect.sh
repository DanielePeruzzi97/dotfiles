#!/usr/bin/env bash
# System detection utilities

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

detect_arch() {
  local arch=$(uname -m)
  case "$arch" in
    x86_64) echo "amd64" ;;
    aarch64) echo "arm64" ;;
    *) echo "$arch" ;;
  esac
}
