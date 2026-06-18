#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

DEFAULT_PACKAGES=(ui)
LOG_PREFIX="[tests]"

log_info() {
  echo "${LOG_PREFIX} $1"
}

log_done() {
  echo "${LOG_PREFIX} Done: $1"
}

log_skip() {
  echo "${LOG_PREFIX} Skip: $1"
}

log_error() {
  echo "${LOG_PREFIX} Error: $1" >&2
}

if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=("fvm" "flutter")
  log_info "Using Flutter via FVM."
else
  FLUTTER_CMD=("flutter")
  log_info "Using system Flutter executable."
fi

if [[ $# -gt 0 ]]; then
  PACKAGES=("$@")
else
  PACKAGES=("${DEFAULT_PACKAGES[@]}")
fi

is_verbose() {
  case "${VERBOSE:-0}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

run_build_runner_if_needed() {
  local package_name="$1"

  if [[ -f Makefile ]] && grep -Eq '^build-runner:' Makefile; then
    log_info "Running pre-test build_runner for package ${package_name}."
    make build-runner >/dev/null
    log_done "Pre-test build_runner completed for package ${package_name}."
  fi
}

run_coverage_report() {
  local label="$1"

  if [[ ! -f coverage/lcov.info ]]; then
    log_skip "Coverage report is missing for ${label}."
    return
  fi

  if ! command -v genhtml >/dev/null 2>&1; then
    log_skip "genhtml is not installed. Skipping HTML coverage for ${label}."
    return
  fi

  log_info "Generating HTML coverage for ${label}."
  genhtml coverage/lcov.info --output=coverage -o coverage/html >/dev/null
  log_done "HTML coverage generated for ${label}."
}

run_tests_in_directory() {
  local working_dir="$1"
  local label="$2"
  local package_name="$3"
  local -a test_targets=()
  local -a test_flags=(--coverage)

  pushd "${working_dir}" >/dev/null

  if [[ -f test/unit_test.dart ]]; then
    test_targets+=("test/unit_test.dart")
  fi

  if [[ -f test/widget_test.dart ]]; then
    test_targets+=("test/widget_test.dart")
  fi

  if [[ ${#test_targets[@]} -eq 0 ]] && [[ ! -d test ]]; then
    log_skip "${label} has no test directory."
    popd >/dev/null
    return
  fi

  if [[ ${#test_targets[@]} -eq 0 ]] && [[ -z "$(find test -type f -name '*_test.dart' -print -quit)" ]]; then
    log_skip "${label} has no Dart test files."
    popd >/dev/null
    return
  fi

  rm -rf coverage

  if [[ "${working_dir}" == "${ROOT_DIR}/packages/"* ]] && [[ "${working_dir}" != */example ]]; then
    run_build_runner_if_needed "${package_name}"
  fi

  log_info "Running tests for ${label}."

  if is_verbose; then
    test_flags+=(--color --reporter=expanded --concurrency=1)
  fi

  if [[ ${#test_targets[@]} -gt 0 ]]; then
    "${FLUTTER_CMD[@]}" test "${test_flags[@]}" "${test_targets[@]}"
  else
    "${FLUTTER_CMD[@]}" test "${test_flags[@]}"
  fi

  log_done "Tests passed for ${label}."
  run_coverage_report "${label}"

  popd >/dev/null
}

log_info "Starting package test suite."
log_info "Packages: ${PACKAGES[*]}"

for package in "${PACKAGES[@]}"; do
  package_dir="${ROOT_DIR}/packages/${package}"

  if [[ ! -d "${package_dir}" ]]; then
    log_error "Package directory not found: ${package_dir}"
    exit 1
  fi

  run_tests_in_directory "${package_dir}" "package ${package}" "${package}"

  if [[ -d "${package_dir}/example" ]]; then
    run_tests_in_directory "${package_dir}/example" "package ${package} example" "${package}"
  else
    log_skip "package ${package} has no example/ directory."
  fi
done

log_done "Package test suite completed. Coverage reports are in packages/<package>/coverage/html."