APP := App
DIST := "$(PWD)/Dist/BitBar.xcarchive/Products/Applications"
CERT := bitbar.p12
APP2="BitBar"
KEYCHAIN := build.chain
PROJECT_NAME ?= BitBar
version ?= beta
ifdef class
	ARGS=-only-testing:BitBarTests/$(class)
endif
BUILD_ATTR := xcodebuild -workspace $(PROJECT_NAME).xcworkspace -scheme
CONFIG := Debug
BUILD := $(BUILD_ATTR) $(PROJECT_NAME)
BUNDLE := $(PROJECT_NAME).app
CONSTRUCT=xcodebuild -workspace BitBar.xcworkspace -scheme BitBar clean

default: clean
release: archive compress
archive: install_deps
	@echo "[Task] Building app for deployment..."
	@mkdir -p Dist
	@$(BUILD) -archivePath Dist/BitBar clean archive
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
watch:
	@echo "[Task] Watching for file changes..."
	@find . -name "*.swift" | entr -r make test
init:
	@echo "[Task] Installing dependencies..."
	@gem install cocoapods xcpretty --no-ri --no-rdoc
import_cert: unpack_p12
	@security create-keychain -p travis $(KEYCHAIN)
	@security default-keychain -s $(KEYCHAIN)
	@security unlock-keychain -p travis $(KEYCHAIN)
	@security set-keychain-settings -t 3600 -u $(KEYCHAIN)
	@security import $(CERT) -k $(KEYCHAIN) -P "$(CERTPWD)" -T /usr/bin/codesign
setup: init install import_cert
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
	$(CONSTRUCT) $(ARGS) test
pipefail:
	set -o pipefail
ci: pipefail test
build: install_deps
	$(CONSTRUCT) build
# Decrypt certificate stored in repo used by the keychain
unpack_p12:
	travis encrypt-file --decrypt Resources/bitbar.p12.enc bitbar.p12 --iv $(encrypted_34de277e100a_iv) --key $(encrypted_34de277e100a_key)