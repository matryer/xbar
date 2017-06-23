CLI := .build/BitBarCLI
CONFIGURATION ?= Debug
PROJECT_DIR ?= ${PWD}
MODE=${echo ${CONFIGURATION} | tr '[:upper:]' '[:lower:]'}

ifeq (${CONFIGURATION},"Release")
  MODE=release
else
  MODE=debug
endif

install_deps:
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
build:
	bundle exec fastlane build
clean:
	swift package -C Packages reset
	swift package -C Packages clean
	pod cache clean --all
	rm -rf .build
	rm -rf BitBar.xcworkspace
	rm -rf Packages/*.xcodeproj
	rm -rf Packages/Package.pins
	rm -rf /usr/local/bin/bitbar
pod_install:
	pod install --verbose
setup: create_build_dir prebuild_vapor symlink_vapor pod_install
create_build_dir:
	mkdir -p .build
	mkdir -p .build/BitBar/Build/Products/Debug
	mkdir -p .build/BitBar/Build/Products/Release
symlink_vapor: create_build_dir
	gln -rfs Packages/.build/checkouts/ctls.git-* .build/ctls
	gln -rfs Packages/*.xcodeproj/GeneratedModuleMap/CHTTP .build/CHTTP
prebuild_vapor:
	swift package --chdir Packages fetch
	swift package --chdir Packages generate-xcodeproj
rebuild: clean prebuild_vapor symlink_vapor
	pod install
build_cli: create_build_dir
	git -C ${CLI} pull --quiet || git clone https://github.com/oleander/BitBarCLI.git ${CLI}
	swift build -C ${CLI} -c ${MODE}
	gcp -rf "${PROJECT_DIR}/${CLI}/.build/${MODE}/BitBarCli" "${PROJECT_DIR}/.build/CLI"
clean_slate: clean setup build