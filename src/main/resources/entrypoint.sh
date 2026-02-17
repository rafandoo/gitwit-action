#!/bin/sh
set -e

COMMAND="$1"
shift

ARGS=""
for arg in "$@"; do
  if [ -n "$arg" ]; then
    ARGS="$ARGS \"$arg\""
  fi
done

case "$COMMAND" in
  lint|changelog)

    if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
      echo "Detected pull request event"

      BASE=$(jq -r .pull_request.base.sha "$GITHUB_EVENT_PATH")
      HEAD=$(jq -r .pull_request.head.sha "$GITHUB_EVENT_PATH")

      RANGE="$BASE..$HEAD"

      echo "Using range: $RANGE"

      if [ -n "$ARGS" ]; then
        java -jar /app/gitwit.jar "$COMMAND" "$RANGE" "$ARGS"
      else
        java -jar /app/gitwit.jar "$COMMAND" "$RANGE"
      fi
    else
      if [ -n "$ARGS" ]; then
        java -jar /app/gitwit.jar "$COMMAND" "$ARGS"
      else
        java -jar /app/gitwit.jar "$COMMAND"
      fi
    fi
    ;;
  *)
    echo "❌ Invalid command: $COMMAND"
    echo "Allowed commands: lint, changelog"
    exit 1
    ;;
esac
