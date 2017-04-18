setup:
	gem install fastlane bundler --pre
	bundle install
	fastlane setup
wait:
	find . -name "*.swift" | entr fastlane scan --only_testing=Tests/$(test)

