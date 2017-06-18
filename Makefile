# https://stackoverflow.com/questions/43070534/openssl-ctls-trouble-with-vapor-2
ifdef test
	_test=--only_testing=Tests/$(test)
endif

setup:
	gem install bundler fastlane --pre
	brew tap vapor/homebrew-tap
	brew update
	brew install tailor ctls coreutils
	bundle install
	bundle exec fastlane setup
test:
	bundle exec fastlane test
wait: test
	@find . -name "*.swift" | entr -p make test
deploy:
	bundle exec fastlane deploy
clean:
	swift package reset
	swift package clean
	rm -rf .build
	rm -fr Pods
	rm -fr build
	rm -fr Vapor.xcodeproj
	rm -fr Package.pins
	rm -rf BitBar.xcworkspace
symlink_vapor:
	mkdir -p .build
	gln -rfs Packages/.build/checkouts/ctls.git-* .build/ctls
	gln -rfs Packages/*.xcodeproj/GeneratedModuleMap/CHTTP .build/CHTTP
prebuild_vapor:
	swift package --chdir Packages fetch
	swift package --chdir Packages generate-xcodeproj
