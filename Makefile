setup:
	gem install fastlane bundler --pre
	bundle install
	bundle exec pod install --repo-update
	fastlane setup
wait:
	find . -name "*.swift" | entr fastlane scan --only_testing=Tests/$(test)

