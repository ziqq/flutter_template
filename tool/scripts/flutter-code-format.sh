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
    echo "Formatting lib directory..."
    find lib -type f -name '*.dart' \
      ! -path '*/generated/*' \
      ! -name '*.*.dart' \
      ! -name 'messages_.*.dart' \
      ! -name 'l10n.dart' \
      -exec fvm dart format --set-exit-if-changed --line-length 120 {} + || true
  fi

  # Process test directory if it exists
  if [ -d "test" ]; then
    echo "Formatting test directory..."
    find test -type f -name '*.dart' \
      ! -path '*/generated/*' \
      ! -name '*.*.dart' \
      ! -name 'messages_.*.dart' \
      ! -name 'l10n.dart' \
      -exec fvm dart format --set-exit-if-changed --line-length 120 {} + || true
  fi

  if [ ! -d "lib" ] && [ ! -d "test" ]; then
    echo "No lib or test directories found in $dir"
  fi

  cd ..
done
