#!/usr/bin/env bash

set -u

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

echo "======================================"
echo " Assignment 2 - Local Grader"
echo " Dockerized Diagnostic CLI"
echo "======================================"
echo

# Required files
for f in README.md Dockerfile compose.yaml .dockerignore app/diagnostic.sh test.sh; do
    if [[ -f "$f" ]]; then
        pass "Required file exists: $f"
    else
        fail "Missing required file: $f"
    fi
done

# Bash syntax
for f in app/*.sh test.sh; do
    [[ -f "$f" ]] || continue

    if bash -n "$f" >/dev/null 2>&1; then
        pass "Bash syntax: $f"
    else
        fail "Bash syntax error: $f"
    fi
done

# Executable check
if [[ -x app/diagnostic.sh ]]; then
    pass "diagnostic.sh is executable"
else
    fail "app/diagnostic.sh is not executable"
fi

# Docker availability
if ! command -v docker >/dev/null 2>&1; then
    echo
    echo "ERROR: Docker is required to grade Assignment 2."
    exit 2
fi

# Dockerfile checks
if grep -Eq '^[[:space:]]*FROM[[:space:]]+' Dockerfile; then
    pass "Dockerfile has FROM"
else
    fail "Dockerfile has no FROM"
fi

if grep -Eq 'ENTRYPOINT|CMD' Dockerfile; then
    pass "Dockerfile defines ENTRYPOINT or CMD"
else
    fail "Dockerfile has neither ENTRYPOINT nor CMD"
fi

# .dockerignore check
if grep -Eq '^\.git/?$|^\.git$' .dockerignore; then
    pass ".dockerignore excludes .git"
else
    fail ".dockerignore should exclude .git"
fi

# Build Docker image
IMAGE="student-diagnostic-grader"

if docker build -t "$IMAGE" . >/tmp/assignment2-docker-build.log 2>&1; then
    pass "Docker image builds successfully"
else
    fail "Docker image failed to build"
    cat /tmp/assignment2-docker-build.log
fi

# Helper for functional tests
run_test() {
    name="$1"
    shift

    if "$@" >/tmp/assignment2-test.log 2>&1; then
        pass "$name"
        return 0
    else
        fail "$name"
        cat /tmp/assignment2-test.log
        return 1
    fi
}

# Functional tests
run_test "Docker help command works" \
    docker run --rm "$IMAGE" help

run_test "Docker system command works" \
    docker run --rm "$IMAGE" system

run_test "Docker disk command works" \
    docker run --rm "$IMAGE" disk

# Invalid command must fail
docker run --rm "$IMAGE" invalid-command \
    >/tmp/assignment2-test.log 2>&1

rc=$?

if [[ $rc -ne 0 ]]; then
    pass "Invalid command returns non-zero"
else
    fail "Invalid command should return non-zero"
fi

# Compose validation
if docker compose config >/tmp/assignment2-compose.log 2>&1; then
    pass "Docker Compose configuration is valid"
else
    fail "Docker Compose configuration is invalid"
    cat /tmp/assignment2-compose.log
fi

# Student test suite
if [[ -x ./test.sh ]]; then
    if ./test.sh >/tmp/assignment2-student-tests.log 2>&1; then
        pass "Student test.sh passes"
    else
        fail "Student test.sh fails"
        cat /tmp/assignment2-student-tests.log
    fi
else
    echo "WARN: test.sh is not executable; running with bash"

    if bash ./test.sh >/tmp/assignment2-student-tests.log 2>&1; then
        pass "Student test.sh passes"
    else
        fail "Student test.sh fails"
        cat /tmp/assignment2-student-tests.log
    fi
fi

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

docker image rm "$IMAGE" >/dev/null 2>&1 || true

[[ $FAIL -eq 0 ]]
