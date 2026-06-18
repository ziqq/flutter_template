#!/bin/bash

cd packages
for dir in */ ; do
  # Skip localization package
  if [ "$dir" = "localization/" ]; then
    echo "Skipping localization package"
    continue
  fi

  echo "Processing package: $dir"
  cd "$dir"

  # Process lib directory if it exists
  if [ -d "lib" ]; then
    echo "Check format in lib directory..."
    find lib \
        -path '*/generated/*' -prune -o \
        -type f -name '*.dart' \
        ! -name '*.*.dart' \
        ! -name 'messages_.*.dart' \
        ! -name 'l10n.dart' \
        -print0 |
        xargs -0 dart format --set-exit-if-changed --line-length 120 -o none || true
  fi

  # Process test directory if it exists
  if [ -d "test" ]; then
    echo "Check format in test directory..."
    find test \
        -path '*/generated/*' -prune -o \
        -type f -name '*.dart' \
        ! -name '*.*.dart' \
        ! -name 'messages_.*.dart' \
        ! -name 'l10n.dart' \
        -print0 |
        xargs -0 dart format --set-exit-if-changed --line-length 120 -o none || true
  fi

  if [ ! -d "lib" ] && [ ! -d "test" ]; then
    echo "No lib or test directories found in $dir"
  fi

  cd ..
done
