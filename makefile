CONFIG_FILE_NAME := configurations
CONFIG_TEMPLATE_NAME := configurations.template

PROJECT_NAME := bash-utils
PROFILE_PATH := $(HOME)/.bash_profile

SHELL := /bin/bash

.PHONY: all
all: ensure-configuration ensure-profile

.PHONY: ensure-configuration
ensure-configuration:
	@if [[ ! -f $(CONFIG_FILE_NAME) ]]; then \
		echo "Configuration file not found, copying $(CONFIG_TEMPLATE_NAME) to $(CONFIG_FILE_NAME)"; \
		cp "$(CONFIG_TEMPLATE_NAME)" "$(CONFIG_FILE_NAME)"; \
		echo "You can now customize $(CONFIG_FILE_NAME)"; \
	fi

.PHONY: ensure-profile
ensure-profile:
	@grep "$(PROJECT_NAME)" "$(PROFILE_PATH)" &>/dev/null || $(MAKE) add-to-profile

.PHONY: add-to-profile
add-to-profile:
	echo >> "$(PROFILE_PATH)"
	echo '# $(PROJECT_NAME)' >> "$(PROFILE_PATH)"
	echo 'source "$(CURDIR)/bootstrap.sh"' >> "$(PROFILE_PATH)"
	echo >> "$(PROFILE_PATH)"

.PHONY: remove-from-profile
remove-from-profile:
	# TODO
