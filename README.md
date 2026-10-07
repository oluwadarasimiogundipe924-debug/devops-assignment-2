# Assignment 2 — Dockerized Diagnostic CLI

## Overview

This project packages a Bash-based Linux diagnostic tool in a Docker
container. It provides commands to display system information, check
network connectivity, and view disk usage.

## Project Structure

- `app/diagnostic.sh` — main command-line application
- `app/health-check.sh` — container health check
- `Dockerfile` — builds the Docker image
- `compose.yaml` — Docker Compose configuration
- `.dockerignore` — excludes unnecessary build files
- `test.sh` — automated Docker tests
- `grade.sh` — supplied assignment grader

## Requirements

- Linux or Ubuntu
- Bash
- Docker Engine
- Docker Compose plugin

## Build the Image

```bash
docker build -t diagnostic-tool .
