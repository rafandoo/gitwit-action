#!/bin/sh
set -eu

COMMAND="$1"
CHANGELOG_STDOUT="$2"
CHANGELOG_FROM_LATEST_RELEASE="$3"
LINT_AUTO_DETECT_PR="$4"
shift 4

set --
for arg in "$@"; do
  [ -n "$arg" ] && set -- "$@" "$arg"
done

log() {
  echo "▶ $*"
}

error() {
  echo "❌ $*" >&2
  exit 1
}

is_debug() {
  [ "${ACTIONS_STEP_DEBUG:-false}" = "true" ]
}

run_gitwit() {
  if is_debug; then
    java -jar /app/gitwit.jar --debug "$@"
  else
    java -jar /app/gitwit.jar "$@"
  fi
}

is_pr_event() {
  [ "${GITHUB_EVENT_NAME:-}" = "pull_request" ]
}

get_pr_range() {
  jq -r '.pull_request.base.sha + ".." + .pull_request.head.sha' \
    "$GITHUB_EVENT_PATH"
}

get_latest_release_tag() {
  : "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY not set}"

  owner="${GITHUB_REPOSITORY%%/*}"
  repo="${GITHUB_REPOSITORY##*/}"

  curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${owner}/${repo}/releases/latest" |
    jq -r '.tag_name // empty'
}

generate_changelog() {
  if [ "$CHANGELOG_FROM_LATEST_RELEASE" = "true" ]; then
    log "Fetching latest release tag"

    TAG=$(get_latest_release_tag || true)

    if [ -n "$TAG" ]; then
      : "${GITHUB_REF_NAME:?GITHUB_REF_NAME not set}"
      RANGE="$TAG..$GITHUB_REF_NAME"
      log "Using range: $RANGE"
      set -- "$@" "$RANGE"
    else
      log "No previous releases found."
    fi
  fi

  if [ "$CHANGELOG_STDOUT" = "true" ]; then
    log "Generating changelog to stdout"

    OUTPUT=$(run_gitwit changelog --stdout "$@")

    : "${GITHUB_OUTPUT:?GITHUB_OUTPUT not set}"
    {
      echo "changelog<<EOF"
      echo "$OUTPUT"
      echo "EOF"
    } >> "$GITHUB_OUTPUT"
  else
    log "Generating changelog to file"
    run_gitwit changelog "$@"
  fi
}

run_lint() {
  if is_pr_event && [ "$LINT_AUTO_DETECT_PR" = "true" ]; then
    log "Detected pull request event"

    RANGE=$(get_pr_range)
    log "Using range: $RANGE"

    run_gitwit lint "$@" "$RANGE"
  else
    run_gitwit lint "$@"
  fi
}

case "$COMMAND" in
  "changelog")
    generate_changelog
    ;;

  "lint")
    run_lint
    ;;

  *)
    error "Invalid command: $COMMAND - Allowed commands: lint, changelog"
    ;;
esac
