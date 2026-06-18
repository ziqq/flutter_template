#!/usr/bin/env bash

set -euo pipefail

run_xcodebuild_clean() {
	local scheme_name="$1"
	local build_log

	build_log="$(mktemp -t ios-clean-xcodebuild.XXXXXX.log)"

	if xcodebuild clean -quiet -workspace Runner.xcworkspace -scheme "$scheme_name" -destination "generic/platform=iOS" >"$build_log" 2>&1; then
		echo "[ios-clean] Cleaned scheme '$scheme_name'."
		rm -f "$build_log"
		return 0
	fi

	cat "$build_log"
	rm -f "$build_log"
	return 1
}

cd ios/

swift_package_path="Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage"
scheme_dir="Runner.xcodeproj/xcshareddata/xcschemes"

# Xcode resolves local Swift packages even for clean, so it must run
# before Flutter removes ios/Flutter/ephemeral.
if command -v xcodebuild >/dev/null 2>&1; then
	if [ -d "$swift_package_path" ]; then
		clean_schemes=()
		for scheme_file in "$scheme_dir"/*.xcscheme; do
			[ -e "$scheme_file" ] || continue
			scheme_name="$(basename "$scheme_file" .xcscheme)"
			case "$scheme_name" in
				dev|prod)
					clean_schemes+=("$scheme_name")
					;;
			esac
		done

		if [ "${#clean_schemes[@]}" -eq 0 ]; then
			echo "[ios-clean] Skip: no shared app schemes found for xcodebuild clean."
		else
			for scheme_name in "${clean_schemes[@]}"; do
				run_xcodebuild_clean "$scheme_name"
			done
		fi
	else
		echo "[ios-clean] Skip: local Swift package is absent, xcodebuild clean is not needed."
	fi
fi

if command -v pod >/dev/null 2>&1; then
	pod cache clean --all >/dev/null 2>&1
fi

rm -rf .symlinks/
rm -rf Pods
rm -rf Podfile.lock
cd ..
flutter clean