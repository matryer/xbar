ifdef test
	_test=--only_testing=Tests/$(test)
endif

setup:
	gem install bundler fastlane --pre
	brew update
	brew install tailor
	bundle install
	fastlane setup
test:
	@bundle exec fastlane scan $(_test) || :
wait: test
	@find . -name "*.swift" | entr -p make test
rem:
	security delete-keychain travis.keychain | :
