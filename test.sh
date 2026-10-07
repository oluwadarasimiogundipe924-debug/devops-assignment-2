#!/usr/bin/env bash

set -u

IMAGE="diagnostic-tool"
PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

echo "=============================="
echo "Assignment 2 - Student Tests"
echo "=============================="

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is required."
    exit 1
fi

# Build the image if it is not already available.
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    if docker build -t "$IMAGE" .; then
        pass "Docker image builds"
    else
        fail "Docker image builds"
        exit 1
    fi
fi

# Help
if docker run --rm "$IMAGE" help >/dev/null 2>&1; then
    pass "Help command works"
else
    fail "Help command works"
fi

# System
if docker run --rm "$IMAGE" system >/dev/null 2>&1; then
    pass "System command works"
else
    fail "System command works"
fi

# Disk
if docker run --rm "$IMAGE" disk >/dev/null 2>&1; then
    pass "Disk command works"
else
    fail "Disk command works"
fi

# Invalid command must fail.
if docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1; then
    fail "Invalid command is rejected"
else
    pass "Invalid command is rejected"
fi

# Network without a host must return exit code 2.
docker run --rm "$IMAGE" network >/dev/null 2>&1
rc=$?

if [[ "$rc" -eq 2 ]]; then
    pass "Missing network host returns exit code 2"
else
    fail "Missing network host returns exit code 2"
fi

echo
echo "=============================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "=============================="

[[ "$FAIL" -eq 0 ]]
