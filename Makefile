setup:
	@bundle install
	@fastlane import_keys
test:
	@fastlane test
package:
	@fastlane package
release:
	@fastlane release
build:
	@fastlane build