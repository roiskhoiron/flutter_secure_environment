VERSION = $(shell cat ./VERSION)
BUILD_NUMBER = $(shell cat ./BUILDNUMBER)
MERGE_COMMIT=$(shell git rev-parse HEAD | cut -c -8 )
BUILD_NUMBER_FILE=BUILDNUMBER

#UTILITY
.PHONY: all run_dev_mobile run_unit clean_cache upgrade lint format help

all: lint format run_dev_mobile

run_dev_mobile:
	@echo "╠ Running the development app"
	@flutter run --dart-define=environment=development --flavor development

run_prod_mobile:
	@echo "╠ Running the production app"
	@flutter run --dart-define=environment=production --flavor production

run_unit:
	@echo "╠ Running the tests"
	@flutter test || (echo "▓▓ Error while running tests ▓▓"; exit 1)

upgrade: clean_cache
	@echo "╠ Upgrading dependencies..."
	@flutter pub upgrade

lint:
	@echo "╠ Verifying code..."
	@dart analyze . || (echo "▓▓ Lint error ▓▓"; exit 1)

format:
	@echo "╠ Formatting the code"
	@dart format .

clean_cache:
	@echo "╠ clean cache the dependency"
	flutter clean cache


#DEPLOYMENT
increment_build:
	@echo "╠ increment_build the code"
	@if ! test -f $(BUILD_NUMBER_FILE); then echo 0 > $(BUILD_NUMBER_FILE); fi
	@@echo $$(($(shell cat ./BUILDNUMBER)+1)) > $(BUILD_NUMBER_FILE)
	echo $(shell cat ./BUILDNUMBER)

release_android_dev: increment_build clean_cache
	flutter build apk --dart-define=environment=development --release --build-name=$(VERSION) --build-number=$(shell cat ./BUILDNUMBER) --flavor development --obfuscate --split-debug-info=./flutter_secure_androis_dev

release_android_prod: increment_build clean_cache
	flutter build apk --dart-define=environment=production --release --build-name=$(VERSION) --build-number=$(shell cat ./BUILDNUMBER) --flavor production --obfuscate --split-debug-info=./flutter_secure_android_prod

release_ios_dev: increment_build clean_cache
	flutter build ipa --dart-define=environment=development --release --build-name=$(VERSION) --build-number=$(shell cat ./BUILDNUMBER) --flavor development --obfuscate --split-debug-info=./flutter_secure_androis_dev

release_ios_prod: increment_build clean_cache
	flutter build ipa --dart-define=environment=production --release --build-name=$(VERSION) --build-number=$(shell cat ./BUILDNUMBER) --flavor production --obfuscate --split-debug-info=./flutter_secure_ios_prod

#HELPER
help: ## This help dialog.
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
    for help_line in $${help_lines[@]}; do \
        IFS=$$'#' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf "%-30s %s\n" $$help_command $$help_info ; \
    done

build_runner:
	flutter pub run build_runner build

buil_runner_conflicts:
	flutter pub run build_runner build --delete-conflicting-outputs