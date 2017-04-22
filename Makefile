setup:
	gem install bundler --pre
	gem install fastlane -v 2.27.0
	bundle install
	bundle exec pod install --repo-update
	fastlane setup
wait:
	find . -name "*.swift" | entr fastlane scan --only_testing=Tests/$(test)

