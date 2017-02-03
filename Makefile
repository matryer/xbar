APP := App
DIST := "$(PWD)/Dist/BitBar.xcarchive/Products/Applications"
CERT := bitbar.p12
KEYCHAIN := build.chain
PLIST_BUDDY := /usr/libexec/PlistBuddy
APP_PLIST := App/BitBar/Info.plist
BUNDLE_VERSION := "$(shell $(PLIST_BUDDY) -c "Print CFBundleShortVersionString" $(APP_PLIST))"
PROJECT_NAME ?= BitBar
ifdef class
	ARGS="-only-testing:BitBarTests/$(class)"
endif
BUILD_ATTR := xcodebuild -workspace $(APP)/$(PROJECT_NAME).xcworkspace -scheme
CONFIG := Debug
BUILD := $(BUILD_ATTR) $(PROJECT_NAME)
TEST := $(BUILD_ATTR) BitBarTests $(ARGS) test
BUNDLE := $(PROJECT_NAME).app

default: clean
build:
	@echo "[Task] Building $(PROJECT_NAME), this might take a while..."
	@$(BUILD) | xcpretty
release:
	git tag $(BUNDLE_VERSION)
	git push origin $(BUNDLE_VERSION)
archive:
	@echo "[Task] Building app for deployment..."
	@mkdir -p Dist
	@$(BUILD) -archivePath Dist/BitBar clean archive | xcpretty
	@echo "[Task] Completed building"
clean:
	@echo "[Task] Cleaning up..."
	@$(BUILD) clean | xcpretty
install:
	@echo "[Task] Installing dependencies..."
	@pod install --project-directory=$(APP) --repo-update
kill:
	@echo "[Task] Killing all running instances of $(PROJECT_NAME)..."
	@killall $(PROJECT_NAME) || :
open:
	@echo "[Task] Opening $(BUNDLE) build from $(CONFIG)..."
	@open $(APP)/.build/$(PROJECT_NAME)/Build/Products/$(CONFIG)/$(BUNDLE)
test:
	@echo "[Task] Running test suite..."
	@$(TEST) | xcpretty -c
ci:
	@set -o pipefail && $(TEST) | xcpretty -c
watch:
	@echo "[Task] Watching for file changes..."
	@find . -name "*.swift" | entr -r make test
init:
	@echo "[Task] Installing dependencies..."
	@gem install cocoapods xcpretty --no-ri --no-rdoc
setup: init install
	@security create-keychain -p travis $(KEYCHAIN)
	@security default-keychain -s $(KEYCHAIN)
	@security unlock-keychain -p travis $(KEYCHAIN)
	@security set-keychain-settings -t 3600 -u $(KEYCHAIN)
	@security import $(CERT) -k $(KEYCHAIN) -P "$(CERTPWD)" -T /usr/bin/codesign
lint:
	@echo "[Task] Linting swift files..."
	@swiftlint
fix:
	@echo "[Task] Fixing linting errors..."
	@swiftlint autocorrect
compress:
	@echo "[Task] Compressing application..."
	@ditto -c -k --sequesterRsrc --keepParent "$(DIST)/BitBar.app" "BitBar-$(version).zip"
	@echo "[Task] File has been compressed to BitBar-$(version).zip"
release: archive compress
