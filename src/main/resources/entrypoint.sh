#!/bin/sh
set -e

COMMAND="$1"
shift

case "$COMMAND" in
  lint|changelog)

    if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
      echo "Detected pull request event"

      BASE=$(jq -r .pull_request.base.sha "$GITHUB_EVENT_PATH")
      HEAD=$(jq -r .pull_request.head.sha "$GITHUB_EVENT_PATH")

      echo "Using range: $BASE..$HEAD"

      java -jar /app/gitwit.jar "$COMMAND" "$BASE..$HEAD" "$@"
    else
      echo "Not a PR event. Running normally."
      java -jar /app/gitwit.jar "$COMMAND" "$@"
    fi
    ;;
  *)
    echo "❌ Invalid command: $COMMAND"
    echo "Allowed commands: lint, changelog"
    exit 1
    ;;
esac