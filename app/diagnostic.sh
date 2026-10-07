#!/usr/bin/env bash

set -u

show_help() {
    cat <<'HELP'
Diagnostic Tool

Usage:
  diagnostic system
  diagnostic network <host>
  diagnostic disk
  diagnostic help

Commands:
  system          Display Linux system information
  network <host>  Resolve a host and check connectivity
  disk            Display disk usage
  help            Display this help message
HELP
}

system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Operating System: $(. /etc/os-release; echo "$PRETTY_NAME")"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "CPU count: $(nproc)"
    echo
    echo "=== Memory ==="
    free -h
}

network_check() {
    local host="$1"

    if ! getent hosts "$host" >/dev/null 2>&1; then
        echo "ERROR: Cannot resolve host: $host" >&2
        return 1
    fi

    echo "=== Host Resolution ==="
    getent hosts "$host"

    echo "=== Connectivity ==="
    if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
        echo "Connectivity: SUCCESS"
    else
        echo "Connectivity: FAILED"
        return 1
    fi
}

disk_info() {
    echo "=== Disk Usage ==="
    df -h
}

case "${1:-}" in
    help)
        [[ $# -eq 1 ]] || {
            echo "ERROR: help takes no extra arguments." >&2
            exit 2
        }
        show_help
        ;;
    system)
        [[ $# -eq 1 ]] || {
            echo "ERROR: system takes no extra arguments." >&2
            exit 2
        }
        system_info
        ;;
    disk)
        [[ $# -eq 1 ]] || {
            echo "ERROR: disk takes no extra arguments." >&2
            exit 2
        }
        disk_info
        ;;
    network)
        if [[ $# -ne 2 || -z "${2:-}" ]]; then
            echo "ERROR: network requires exactly one host." >&2
            show_help
            exit 2
        fi
        network_check "$2"
        exit $?
        ;;
    *)
        echo "ERROR: Invalid command." >&2
        show_help
        exit 2
        ;;
esac
