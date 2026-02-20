#!/bin/sh
set -eu

COMMAND="$1"
CHANGELOG_STDOUT="$2"
CHANGELOG_FROM_LATEST_RELEASE="$3"
shift 3

set --
for arg in "$@"; do
  [ -n "$arg" ] && set -- "$@" "$arg"
done

run_gitwit() {
  java -jar /app/gitwit.jar "$@"
}

is_pr_event() {
  [ "$GITHUB_EVENT_NAME" = "pull_request" ]
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

case "$COMMAND" in
  "changelog")

    if [ "$CHANGELOG_FROM_LATEST_RELEASE" = "true" ]; then
      echo "🔍 Fetching latest release tag"

      TAG=$(get_latest_release_tag || true)

      if [ -n "$TAG" ]; then
        : "${GITHUB_REF_NAME:?GITHUB_REF_NAME not set}"
        RANGE="$TAG..$GITHUB_REF_NAME"
        echo "Using range: $RANGE"
        set -- "$@" "$RANGE"
      else
        echo "No previous releases found."
      fi
    fi

    if [ "$CHANGELOG_STDOUT" = "true" ]; then
      echo "📝 Generating changelog to stdout"

      OUTPUT=$(run_gitwit changelog --stdout "$@")

      : "${GITHUB_OUTPUT:?GITHUB_OUTPUT not set}"
      {
        echo "changelog<<EOF"
        echo "$OUTPUT"
        echo "EOF"
      } >> "$GITHUB_OUTPUT"
    else
      echo "📝 Generating changelog to file"
      run_gitwit changelog "$@"
    fi
    ;;

  "lint")
    if is_pr_event; then
      echo "Detected pull request event"
      RANGE=$(get_pr_range)
      echo "Using range: $RANGE"

      run_gitwit lint "$@" "$RANGE"
    else
      run_gitwit lint "$@"
    fi
    ;;

  *)
    echo "❌ Invalid command: $COMMAND"
    echo "Allowed commands: lint, changelog"
    exit 1
    ;;
esac
