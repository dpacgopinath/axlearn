#!/usr/bin/env bash

set -e

# Log installed versions
echo "PIP FREEZE:"
pip freeze

exit_if_error() {
  local exit_code=$1
  shift
  printf 'ERROR: %s\n' "$@" >&2
  exit "$exit_code"
}

pre-commit install
pre-commit run --all-files || exit_if_error $? "pre-commit failed."
# Run pytype separately to utilize all cpus and for better output.
pytype -j auto . || exit_if_error $? "pytype failed."
pytest --durations=10 -n auto -v -m "not (gs_login or tpu or high_cpu or fp64)" || exit_if_error $? "pytest failed."
JAX_ENABLE_X64=1 pytest -n auto -v -m "fp64" || exit_if_error $? "pytest failed."