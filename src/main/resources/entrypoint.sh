#!/bin/sh
set -e

COMMAND="$1"
CHANGELOG_STDOUT="$2"
shift 2

ARGS="$@"

run_gitwit() {
  java -jar /app/gitwit.jar "$@"
}

get_pr_range() {
  BASE=$(jq -r .pull_request.base.sha "$GITHUB_EVENT_PATH")
  HEAD=$(jq -r .pull_request.head.sha "$GITHUB_EVENT_PATH")
  echo "$BASE..$HEAD"
}

is_pr_event() {
  [ "$GITHUB_EVENT_NAME" = "pull_request" ]
}

if [ "$COMMAND" = "changelog" ]; then
  if [ "$CHANGELOG_STDOUT" = "true" ]; then
    echo "📝 Generating changelog to stdout"

    OUTPUT=$(run_gitwit changelog --stdout $ARGS)

    echo "changelog<<EOF" >> "$GITHUB_OUTPUT"
    echo "$OUTPUT" >> "$GITHUB_OUTPUT"
    echo "EOF" >> "$GITHUB_OUTPUT"

  else
    echo "📝 Generating changelog to file"

    run_gitwit changelog $ARGS
  fi
elif [ "$COMMAND" = "lint" ]; then
    if is_pr_event; then
      echo "Detected pull request event"
      RANGE=$(get_pr_range)
      echo "Using range: $RANGE"
      run_gitwit lint "$RANGE" $ARGS
    else
      run_gitwit lint $ARGS
    fi

else
  echo "❌ Invalid command: $COMMAND"
  echo "Allowed commands: lint, changelog"
  exit 1
fi
