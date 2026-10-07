#!/usr/bin/env bash

set -eu

if [[ ! -x /app/diagnostic.sh ]]; then
    echo "UNHEALTHY: diagnostic.sh is missing or not executable."
    exit 1
fi

for command_name in hostname uname df free ping getent; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "UNHEALTHY: Missing command: $command_name"
        exit 1
    fi
done

if ! bash -n /app/diagnostic.sh; then
    echo "UNHEALTHY: diagnostic.sh has a syntax error."
    exit 1
fi

echo "HEALTHY: Diagnostic application is ready."
