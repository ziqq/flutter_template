
IOS_CLEAN_SCRIPT := ./tool/scripts/flutter-clean-ios.sh
TEST_PACKAGES_SCRIPT := ./tool/scripts/test-packages.sh

SHELL := bash
.SHELLFLAGS := -e -o pipefail -c

ifeq ($(OS),Windows_NT)
HOST_OS := windows
else
UNAME_S := $(shell uname -s 2>/dev/null || echo Unknown)
ifeq ($(UNAME_S),Darwin)
HOST_OS := macos
else ifeq ($(UNAME_S),Linux)
HOST_OS := linux
else
HOST_OS := unknown
endif
endif

ROOT_DIR := $(CURDIR)
LOG_PREFIX := [make]

ANALYZE_FLAGS := --fatal-warnings --no-fatal-infos
TEST_FLAGS := --color --coverage --concurrency=50 --platform=tester --reporter=expanded --timeout=30s

VERBOSE_ENABLED := $(filter 1 true TRUE yes YES on ON,$(strip $(VERBOSE)))
CI_FLAGS := $(if $(VERBOSE_ENABLED),--verbose,)
FEATURE_TEST_FLAGS := --color --coverage --platform=tester --reporter=expanded --timeout=30s $(if $(VERBOSE_ENABLED),--concurrency=1,--concurrency=50)

FVM := $(shell command -v fvm 2>/dev/null)
ifeq ($(strip $(FVM)),)
DART := dart
FLUTTER := flutter
FLUTTERGEN := fluttergen
else
DART := fvm dart
FLUTTER := fvm flutter
FLUTTERGEN := fvm fluttergen
endif

define require_macos
	@if [ "$(HOST_OS)" != "macos" ]; then \
		echo "$(LOG_PREFIX) Error: target '$1' is supported only on macOS."; \
		exit 1; \
	fi
endef

PACKAGES := ui
PACKAGES_DIR := $(ROOT_DIR)/packages


.PHONY: help
help: ## help dialog
				@echo 'Usage: make <OPTIONS>  <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
				@$(DART) run tool/dart/ci.dart precommit $(CI_FLAGS)

.PHONY: ci
ci: ## CI build pipeline
				@$(DART) run tool/dart/ci.dart precommit $(CI_FLAGS)

.PHONY: precommit
precommit: ## validate the branch before commit
				@$(DART) run tool/dart/ci.dart precommit $(CI_FLAGS)

.PHONY: gen-pretty
gen-pretty: ## Pretty CI-style generation pipeline
				@$(DART) run tool/dart/ci.dart gen $(CI_FLAGS)

.PHONY: check-pretty
check-pretty: ## Pretty CI-style analysis pipeline
				@$(DART) run tool/dart/ci.dart check $(CI_FLAGS)

.PHONY: test-pretty
test-pretty: ## Pretty CI-style test pipeline
				@$(DART) run tool/dart/ci.dart test $(CI_FLAGS)

.PHONY: doctor
doctor: ## Flutter doctor
				@$(FLUTTER) doctor

.PHONY: version
version: ## Flutter version
				@$(FLUTTER) --version

.PHONY: check
check: ## Check code
				@$(DART) run tool/dart/ci.dart check $(CI_FLAGS)

.PHONY: analyze-app-only
analyze-app-only:
				@$(DART) run tool/dart/ci.dart analyze-app $(CI_FLAGS)

.PHONY: analyze
analyze: ## Analyze code
				@$(DART) run tool/dart/ci.dart check $(CI_FLAGS)

.PHONY: analyze-packages analyze-packages-only
analyze-packages: get ## Analyze pakcahes
				@$(MAKE) --no-print-directory analyze-packages-only

analyze-packages-only:
				@$(DART) run tool/dart/ci.dart analyze-packages $(CI_FLAGS)

.PHONY: format
format: ## Format code
				@$(DART) run tool/dart/ci.dart format $(CI_FLAGS)

.PHONY: format-path
format-path: ## Format Dart files inside DIR
				@if [ -z "$(DIR)" ]; then echo "$(LOG_PREFIX) Error: DIR is required for format-path"; exit 1; fi
				@if [ ! -d "$(ROOT_DIR)/$(DIR)" ]; then echo "$(LOG_PREFIX) Error: directory '$(DIR)' does not exist"; exit 1; fi
				@echo "$(LOG_PREFIX) Formatting sources in $(DIR)..."
				@cd "$(ROOT_DIR)/$(DIR)" && find lib test -path '*/generated/*' -prune -o -type f -name '*.dart' ! -name '*.*.dart' ! -name 'messages_.*.dart' ! -name 'l10n.dart' -exec $(DART) format --line-length 120 {} + 2>/dev/null || (echo "$(LOG_PREFIX) Error: formatting failed in $(DIR)"; exit 1)

.PHONY: fix
fix: format ## Fix code
				@$(DART) fix --apply lib

.PHONY: get
get: ## Get the packages in root directory
				@$(DART) run tool/dart/ci.dart get $(CI_FLAGS)

.PHONY: android-plugins-clean
android-plugins-clean: ## Clean Android Gradle build dirs of all Flutter plugins (fixes stale registrant after package version changes)
				@echo "$(LOG_PREFIX) Cleaning Android plugin build directories..."
				@rm -rf "$(ROOT_DIR)/build" || true
				@if [ -d "$(ROOT_DIR)/android" ]; then \
					cd "$(ROOT_DIR)/android" && ./gradlew --quiet clean || { echo "$(LOG_PREFIX) Error: gradle clean failed"; exit 1; }; \
				fi
				@echo "$(LOG_PREFIX) Android plugin build directories cleaned."

.PHONY: cache-repair
cache-repair: ## Clean the pub cache
				@echo "$(LOG_PREFIX) Repairing Flutter pub cache..."
				@$(FLUTTER) pub cache repair
				@echo "$(LOG_PREFIX) Pub cache repaired."

.PHONY: cache-clean
cache-clean: ## Full clean of Dart/Flutter caches
	@$(DART) run tool/dart/ci.dart cache-clean $(CI_FLAGS)

.PHONY: ios-pods-install
ios-pods-install: ## Refresh Flutter artifacts and CocoaPods dependencies
				$(call require_macos,$@)
				@echo "$(LOG_PREFIX) Cleaning Flutter and iOS Pod artifacts..."
				@rm -rf build ios/Podfile.lock
				@$(FLUTTER) clean || (echo "$(LOG_PREFIX) Error: flutter clean failed"; exit 1)
				@$(MAKE) --no-print-directory get
				@cd ios && pod install --repo-update || (echo "$(LOG_PREFIX) Error: pod install --repo-update failed"; exit 1)
				@echo "$(LOG_PREFIX) iOS dependencies refreshed."

.PHONY: codegen
codegen: ## Generate code
				@$(DART) run tool/dart/ci.dart gen $(CI_FLAGS)

.PHONY: gen
gen: codegen ## Generate all

.PHONY: fluttergen
fluttergen: ## Generate assets
				@$(DART) run tool/dart/ci.dart fluttergen $(CI_FLAGS)

.PHONY: l10n
l10n: ## Generate localization
				@$(DART) run tool/dart/ci.dart l10n $(CI_FLAGS)

.PHONY: outdated
outdated: get ## Check outdated dependencies
				@$(FLUTTER) pub outdated

.PHONY: upgrade
upgrade: ## Upgrade dependencies
				@echo "$(LOG_PREFIX) Upgrading workspace dependencies..."
				@$(FLUTTER) pub upgrade || (echo "$(LOG_PREFIX) Error: dependency upgrade failed"; exit 1)
				@echo "$(LOG_PREFIX) Dependency upgrade completed."

.PHONY: dependencies
dependencies: upgrade ## Check outdated dependencies
				@$(FLUTTER) pub outdated --dependency-overrides --dev-dependencies --prereleases --show-all --transitive

.PHONY: build-runner
build-runner: ## Run build_runner:build
				@$(DART) run tool/dart/ci.dart build-runner $(CI_FLAGS)

.PHONY: build-runner-only
build-runner-only:
				@$(DART) run tool/dart/ci.dart build-runner $(CI_FLAGS)

.PHONY: build-runner-dir
build-runner-dir: get ## Run build_runner for DIR
				@if [ -z "$(DIR)" ]; then echo "$(LOG_PREFIX) Error: DIR is required for build-runner-dir"; exit 1; fi
				@echo "$(LOG_PREFIX) Running build_runner for $(DIR)..."
				@$(DART) run build_runner build --build-filter "$(DIR)/*.dart" || (echo "$(LOG_PREFIX) Error: build_runner failed for $(DIR)"; exit 1)
				@$(DART) format --fix -l 120 "$(DIR)" || (echo "$(LOG_PREFIX) Error: dart format failed for $(DIR)"; exit 1)
				@echo "$(LOG_PREFIX) build_runner completed for $(DIR)."

.PHONY: build-runner-watch
build-runner-watch: get ## Watch build_runner for DIR
				@if [ -z "$(DIR)" ]; then echo "$(LOG_PREFIX) Error: DIR is required for build-runner-watch"; exit 1; fi
				@echo "$(LOG_PREFIX) Watching build_runner changes for $(DIR)..."
				@$(DART) run build_runner watch --build-filter "$(DIR)/**/*.dart"

.PHONY: pubspec-generator
pubspec-generator: ## Generate pubspec.g.dart using pubspec_generator
				@$(DART) run tool/dart/ci.dart pubspec-generator $(CI_FLAGS)

.PHONY: sheety-localization
sheety-localization: ## Generate localization from Google Sheets
				@$(DART) run tool/dart/ci.dart sheety-localization $(CI_FLAGS)

.PHONY: icons
icons: ## Generate app icons used https://pub.dev/packages/flutter_launcher_icons
				@echo "$(LOG_PREFIX) Generating launcher icons..."
				@$(DART) run flutter_launcher_icons:main -f flutter_launcher_icons*  || (echo "$(LOG_PREFIX) Error: launcher icon generation failed"; exit 1)
				@echo "$(LOG_PREFIX) Launcher icons generated."

.PHONY: splash-screen
splash-screen: ## Generate app splash screen used https://pub.dev/packages/flutter_native_splash
				@echo "$(LOG_PREFIX) Generating native splash screens..."
				@$(DART) run flutter_native_splash:create  || (echo "$(LOG_PREFIX) Error: splash screen generation failed"; exit 1)
				@echo "$(LOG_PREFIX) Splash screens generated."

.PHONY: init-firebase
init-firebase: ## Init firebase
				@npm install -g firebase-tools
				@firebase login
				@firebase init
#				@fvm dart pub global activate flutterfire_cli
#				@flutterfire configure \
#				-i tld.domain.app \
#				-m tld.domain.app \
#				-a tld.domain.app \
#				-p project \
#				-e email			@gmail.com \
#				-o lib/src/common/constant/firebase_options.g.dart

# "assets/images/products\/(\d+)\/(\d+)\.jpg"
#downscale-images:
#				@cd assets/data/images
#				@find . -name "*.jpg" -exec mogrify -format webp {} \;
#				@find . -name "*.jpeg" -exec mogrify -format webp {} \;
#				@find . -name "*.png" -exec mogrify -format webp {} \;
#				@find . -name "*.jpg" -exec rm -f {} \;
#				@find . -name "*.jpeg" -exec rm -f {} \;
#				@find . -name "*.png" -exec rm -f {} \;
#				@find . -type f \( -name "0.webp" -o -name "1.webp" -o -name "2.webp" -o -name "3.webp" -o -name "4.webp" -o -name "5.webp" -o -name "6.webp" -o -name "7.webp" -o -name "8.webp" -o -name "9.webp" \) -exec mogrify -resize '512x512>' -quality 120 {} \;
#				@find . -name "thumbnail.webp" -exec mogrify -resize '256x256>' -quality 75 {} \;

.PHONY: test-unit
test-unit: ## Run unit tests
				@$(DART) run tool/dart/ci.dart test-app --verbose $(CI_FLAGS)

.PHONY: test-packages
test-packages: ## Run package unit tests
				@$(DART) run tool/dart/ci.dart test-packages $(CI_FLAGS)

.PHONY: test-feature
test-feature: get ## Run app tests for a specific FEATURE tag
				@if [ -z "$(FEATURE)" ]; then echo "$(LOG_PREFIX) Error: FEATURE is required for test-feature"; exit 1; fi
				@echo "$(LOG_PREFIX) Running app tests for feature tag '$(FEATURE)'..."
				@$(FLUTTER) test $(FEATURE_TEST_FLAGS) --tags="$(FEATURE)" test/unit_test.dart test/widget_test.dart || (echo "$(LOG_PREFIX) Error: feature tests failed"; exit 1)
				@echo "$(LOG_PREFIX) Feature tests completed for tag '$(FEATURE)'."

.PHONY: test-unit-all
test-unit-all: ## Run unit tests for app and packages
				@$(DART) run tool/dart/ci.dart test $(CI_FLAGS)

.PHONY: test-integration
test-integration: ## Run integration tests
				@if [ -z "$(DEVICE)" ]; then echo "$(LOG_PREFIX) Error: DEVICE is required for integration tests. Use '$(FLUTTER) devices' and run 'make test-integration DEVICE=<device-id>'"; exit 1; fi
				@echo "$(LOG_PREFIX) Running integration tests on device: $(DEVICE)..."
				@$(FLUTTER) test integration_test/app_test.dart -d "$(DEVICE)" --flavor dev --dart-define-from-file=config/development.json || (echo "$(LOG_PREFIX) Error: integration tests failed"; exit 1)
				@echo "$(LOG_PREFIX) Integration tests completed."

.PHONY: coverage
coverage: ## Get coverage
				@dart pub global activate coverage
				@dart pub global run coverage:test_with_coverage -fb -o coverage -- \
					--platform vm --compiler=kernel --coverage=coverage \
					--reporter=expanded --file-reporter=json:coverage/tests.json \
					--timeout=10m --concurrency=12 --color \
						test/unit_test.dart test/widget_tests.dart
#				@dart test --concurrency=6 --platform vm --coverage=coverage test/
#				@dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
				@mv coverage/lcov.info coverage/lcov.base.info
#				 @lcov -r coverage/lcov.base.info -o coverage/lcov.base.info "lib/src/protobuf/client.*.dart" "lib/**/*.g.dart"
				@mv coverage/lcov.base.info coverage/lcov.info
				@lcov --list coverage/lcov.info
				@genhtml -o coverage coverage/lcov.info

.PHONY: genhtml
genhtml: ## Generate coverage html
				@genhtml coverage/lcov.info -o coverage/html

.PHONY: tag
tag: ## Add a tag to the current commit
	@$(DART) run tool/dart/tag.dart

.PHONY: tag-add
tag-add: ## Add TAG. E.g: make tag-add TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "¯\_(ツ)_/¯ TAG is not set"; exit 1; fi
				@echo ""
				@echo "START ADDING TAG: $(TAG)"
				@echo ""
				@git tag $(TAG)
				@git push origin $(TAG)
				@echo ""
				@echo "CREATED AND PUSHED TAG $(TAG)"
				@echo ""

.PHONY: tag-remove
tag-remove: ## Delete TAG. E.g: make tag-delete TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "¯\_(ツ)_/¯ TAG is not set"; exit 1; fi
				@echo ""
				@echo "START DELETING TAG: $(TAG)"
				@echo ""
				@git tag -d $(TAG)
				@git push --delete origin $(TAG)
				@echo ""
				@echo "DELETED TAG $(TAG)"
				@echo ""

.PHONY: build-ios-prod
build-ios-prod: analyze test-unit-all ## Build for IOS with production ENV
				$(call require_macos,$@)
				@echo "$(LOG_PREFIX) Building iOS release with production configuration..."
				@$(FLUTTER) build ios --dart-define-from-file=config/production.json --flavor prod --release || (echo "$(LOG_PREFIX) Error: iOS production build failed"; exit 1)
				@echo "$(LOG_PREFIX) iOS production build completed."

.PHONY: build-ios-and-install-prod
build-ios-and-install-prod: build-ios-prod ## Build and install for IOS with production ENV
				$(call require_macos,$@)
				@echo "$(LOG_PREFIX) Installing production iOS build..."
				@$(FLUTTER) install --flavor prod || (echo "$(LOG_PREFIX) Error: iOS production install failed"; exit 1)
				@echo "$(LOG_PREFIX) iOS production install completed."

.PHONY: build-ios-dev
build-ios-dev: ## Build for IOS with development ENV
				$(call require_macos,$@)
				@echo "$(LOG_PREFIX) Building iOS release with development configuration..."
				@$(FLUTTER) build ios --dart-define-from-file=config/development.json --flavor dev --release || (echo "$(LOG_PREFIX) Error: iOS development build failed"; exit 1)
				@echo "$(LOG_PREFIX) iOS development build completed."

.PHONY: build-ios-and-install-dev
build-ios-and-install-dev: build-ios-dev ## Build and install for IOS with development ENV
				$(call require_macos,$@)
				@echo "$(LOG_PREFIX) Installing development iOS build..."
				@$(FLUTTER) install --flavor dev || (echo "$(LOG_PREFIX) Error: iOS development install failed"; exit 1)
				@echo "$(LOG_PREFIX) iOS development install completed."

.PHONY: build-android
build-android: build-android-dev build-android-prod ## Build for Android with development and production environment

.PHONY: build-android-dev
build-android-dev: ## Build for Android with development environment
				@echo "$(LOG_PREFIX) Building Android APK with development configuration..."
				@$(FLUTTER) build apk --dart-define-from-file=config/development.json --flavor dev || (echo "$(LOG_PREFIX) Error: Android development build failed"; exit 1)
				@echo "$(LOG_PREFIX) Android development build completed."

.PHONY: build-android-and-install-dev
build-android-and-install-dev: build-android-dev ## Build and install for Android with development environment
				@echo "$(LOG_PREFIX) Installing development Android build..."
				@$(FLUTTER) install --flavor dev || (echo "$(LOG_PREFIX) Error: Android development install failed"; exit 1)
				@echo "$(LOG_PREFIX) Android development install completed."

.PHONY: build-android-prod
build-android-prod: ## Build for Android with production environment
				@echo "$(LOG_PREFIX) Building Android APK with production configuration..."
				@$(FLUTTER) build apk --dart-define-from-file=config/production.json --flavor prod || (echo "$(LOG_PREFIX) Error: Android production build failed"; exit 1)
				@echo "$(LOG_PREFIX) Android production build completed."

.PHONY: build-android-and-install-prod
build-android-and-install-prod: build-android-prod ## Build and install for Android with production environment
				@echo "$(LOG_PREFIX) Installing production Android build..."
				@$(FLUTTER) install --flavor prod || (echo "$(LOG_PREFIX) Error: Android production install failed"; exit 1)
				@echo "$(LOG_PREFIX) Android production install completed."

.PHONY: build-android-for-google
build-android-for-google: analyze test-unit-all ## Build for Android with GMS & production environment
				@echo "$(LOG_PREFIX) Building Android APK for Google services flavor..."
				@$(FLUTTER) build apk --flavor google || (echo "$(LOG_PREFIX) Error: Google services Android build failed"; exit 1)
				@echo "$(LOG_PREFIX) Google services Android build completed."

.PHONY: build-android-for-huawei
build-android-for-huawei: analyze test-unit-all ## Build for Android with HMS & production environment
				@echo "$(LOG_PREFIX) Building Android APK for Huawei services flavor..."
				@$(FLUTTER) build apk --flavor huawei || (echo "$(LOG_PREFIX) Error: Huawei services Android build failed"; exit 1)
				@echo "$(LOG_PREFIX) Huawei services Android build completed."

# build-web:
# 	@flutter build web --release --dart-define-from-file=config/production.json --no-source-maps --pwa-strategy offline-first --web-renderer auto --web-resources-cdn --base-href /

# deploy-web: build-web
# 	@firebase deploy

#build-web-wasm: # https://docs.flutter.dev/platform-integration/web/wasm
#	@fvm spawn main build web --wasm --release --dart-define-from-file=config/development.json --no-source-maps --pwa-strategy offline-first --web-renderer skwasm --web-resources-cdn --base-href /

#deploy-web-wasm: build-web-wasm
#	@firebase hosting:channel:deploy wasm --expires 14d

# serve-web: build-web
# 	@firebase serve --only hosting -p 120

# build-windows:
# 	@flutter build windows --release --dart-define-from-file=config/production.json