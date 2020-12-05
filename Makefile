
PROJECT_NAME ?= BitBar
PROJECT = $(shell find . -name 'BitBar.xcodeproj')

all: build

clean:
	rm -r ./**/build

build:
	git submodule init && git submodule update
	xcodebuild -project $(PROJECT)
	ps aux | grep $(PROJECT_NAME) | grep -v grep >/dev/null 2>&1 && killall $(PROJECT_NAME)
	open $(PROJECT)/../build/Release/$(PROJECT_NAME).app

