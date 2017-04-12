APP := App
DIST := "$(PWD)/Dist/BitBar.xcarchive/Products/Applications"
CERT := bitbar.p12
APP2="BitBar"
KEYCHAIN := build.chain
PROJECT_NAME ?= BitBar
ifdef class
	ARGS=-only-testing:BitBarTests/$(class)
endif
BUILD_ATTR := xcodebuild -workspace $(APP)/$(PROJECT_NAME).xcworkspace -scheme
CONFIG := Debug
BUILD := $(BUILD_ATTR) $(PROJECT_NAME)
BUNDLE := $(PROJECT_NAME).app
CONSTRUCT=xcodebuild -workspace BitBar.xcworkspace -scheme BitBar clean

default: clean
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
	@pod install --repo-update
kill:
	@echo "[Task] Killing all running instances of $(PROJECT_NAME)..."
	@killall $(PROJECT_NAME) || :
open:
	@echo "[Task] Opening $(BUNDLE) build from $(CONFIG)..."
	@open $(APP)/.build/$(PROJECT_NAME)/Build/Products/$(CONFIG)/$(BUNDLE)
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
install_deps:
	pod install --repo-update
test: install_deps
	$(CONSTRUCT) $(ARGS) clean test
pipefail:
	set -o pipefail
ci: pipefail test
build: install_deps
	$(CONSTRUCT) build
