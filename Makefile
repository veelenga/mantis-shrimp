APP_NAME = MantisShrimp
APP = build/$(APP_NAME).app
INSTALL_DIR = $(HOME)/Applications
INSTALL_APP = $(INSTALL_DIR)/$(APP_NAME).app
DEV_DIR = $(shell xcode-select -p)
TESTING_FRAMEWORKS = $(DEV_DIR)/Library/Developer/Frameworks
TESTING_LIBS = $(DEV_DIR)/Library/Developer/usr/lib
TEST_FLAGS = -Xswiftc -F$(TESTING_FRAMEWORKS) -Xlinker -F$(TESTING_FRAMEWORKS) \
	-Xlinker -rpath -Xlinker $(TESTING_FRAMEWORKS) -Xlinker -rpath -Xlinker $(TESTING_LIBS)

.PHONY: build test app dmg run install

build:
	swift build

test:
	swift test $(TEST_FLAGS)

app:
	scripts/bundle.sh

dmg: app
	scripts/dmg.sh

run: app
	open $(APP)

install: app
	-pkill -x $(APP_NAME)
	sleep 1
	mkdir -p $(INSTALL_DIR)
	rm -rf $(INSTALL_APP)
	cp -R $(APP) $(INSTALL_DIR)/
	open $(INSTALL_APP)
