APP_NAME := SimpleMarker
PROJECT := $(APP_NAME).xcodeproj
SCHEME := $(APP_NAME)
DERIVED_DATA := .build
BUILD_DIR := $(DERIVED_DATA)/Build/Products/Release
DIST_DIR := dist
APP_BUNDLE := $(APP_NAME).app

.PHONY: release clean-release

release:
	rm -rf "$(DIST_DIR)/$(APP_BUNDLE)"
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-configuration Release \
		-derivedDataPath "$(DERIVED_DATA)" \
		build
	mkdir -p "$(DIST_DIR)"
	cp -R "$(BUILD_DIR)/$(APP_BUNDLE)" "$(DIST_DIR)/$(APP_BUNDLE)"
	@printf "Built app: %s\n" "$(DIST_DIR)/$(APP_BUNDLE)"

clean-release:
	rm -rf "$(DERIVED_DATA)" "$(DIST_DIR)"
