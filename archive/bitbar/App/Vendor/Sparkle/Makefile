.PHONY: all localizable-strings release build test ci

ifndef BUILDDIR
    BUILDDIR := $(shell mktemp -d "$(TMPDIR)/Sparkle.XXXXXX")
endif

localizable-strings:
	rm -f Sparkle/en.lproj/Sparkle.strings
	genstrings -o Sparkle/en.lproj -s SULocalizedString Sparkle/*.m Sparkle/*.h
	iconv -f UTF-16 -t UTF-8 < Sparkle/en.lproj/Localizable.strings > Sparkle/en.lproj/Sparkle.strings
	rm Sparkle/en.lproj/Localizable.strings

release:
	xcodebuild -scheme Distribution -configuration Release -derivedDataPath "$(BUILDDIR)" build
	open -R "$(BUILDDIR)/Build/Products/Release/Sparkle-"*.tar.bz2
	cat Sparkle.podspec
	@echo "Don't forget to update CocoaPods!"

build:
	xcodebuild clean build

test:
	xcodebuild -scheme Distribution -configuration Debug test

uitest:
	xcodebuild -scheme UITests -configuration Debug test

ci:
	for i in {7..9} ; do \
		if xcrun --sdk "macosx10.$$i" --show-sdk-path 2> /dev/null ; then \
			( rm -rf build && xcodebuild -sdk "macosx10.$$i" -scheme Distribution -configuration Coverage -derivedDataPath build ) || exit 1 ; \
		fi ; \
	done
	for i in {10..11} ; do \
		if xcrun --sdk "macosx10.$$i" --show-sdk-path 2> /dev/null ; then \
			( rm -rf build && xcodebuild -sdk "macosx10.$$i" -scheme Distribution -configuration Coverage -derivedDataPath build test ) || exit 1 ; \
		fi ; \
	done

check-localizations:
	./Sparkle/CheckLocalizations.swift -root . -htmlPath "$(TMPDIR)/LocalizationsReport.htm"
	open "$(TMPDIR)/LocalizationsReport.htm"
