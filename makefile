# This Makefile should be run from the project's root directory.
# To run from another directory, use: make -C /path/to/project-root target_name

CONFIG_FILE_NAME := configurations
CONFIG_TEMPLATE_NAME := configurations.template

LIST_UTILS_OPTIONS :=

PROJECT_NAME := bash-utils
PROJECT_NAME_COMMENT := \# $(PROJECT_NAME)
PROFILE_PATH := $(HOME)/.bash_profile

SHELL := /usr/bin/env bash
SOURCE_BOOTSTRAP_COMMAND := source $(CURDIR)/bootstrap.sh

.PHONY: install
install: ensure-configuration ensure-profile

.PHONY: ensure-configuration
ensure-configuration:
	@if [[ ! -f $(CONFIG_FILE_NAME) ]]; then \
		echo "Configuration file not found, copying $(CONFIG_TEMPLATE_NAME) to $(CONFIG_FILE_NAME)"; \
		cp "$(CONFIG_TEMPLATE_NAME)" "$(CONFIG_FILE_NAME)"; \
		echo "You can now customize $(CONFIG_FILE_NAME)"; \
	else \
	    echo "Configuration file found, checking if an update is needed"; \
	    $(MAKE) update-configuration; \
	fi

# TODO
.PHONY: update-configuration
update-configuration:

.PHONY: ensure-profile
ensure-profile:
	@grep "$(PROJECT_NAME)" "$(PROFILE_PATH)" &>/dev/null || $(MAKE) add-to-profile

.PHONY: add-to-profile
add-to-profile:
	@./hack/profile-manager.sh add '$(PROJECT_NAME_COMMENT)' '$(SOURCE_BOOTSTRAP_COMMAND)'

.PHONY: uninstall
all: remove-from-profile

# TODO
.PHONY: remove-from-profile
remove-from-profile:
	@./hack/profile-manager.sh remove '$(PROJECT_NAME_COMMENT)' '$(SOURCE_BOOTSTRAP_COMMAND)'

.PHONY: list-utils
list-utils:
	@./hack/list-utils.sh $(LIST_UTILS_OPTIONS) $(CURDIR)

.PHONY: update
update: ensure-manpages count-loc

.PHONY: ensure-manpages
ensure-manpages:
	@./hack/ensure-manpages.sh $(CURDIR)

.PHONY: count-loc
count-loc:
	@find . -name '*.sh' | xargs wc -l
