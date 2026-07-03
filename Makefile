# Makefile for claude-box — build the container image and install the launcher.

IMAGE       ?= localhost/claude-box:latest
CONTAINERFILE ?= Containerfile
SCRIPT      := claude-box
PREFIX      ?= /usr/local
BINDIR      ?= $(PREFIX)/bin
DEST        := $(DESTDIR)$(BINDIR)/$(SCRIPT)

.PHONY: all build install uninstall clean help

all: build ## Build the image (default)

build: ## Build the claude-box container image
	podman build -t $(IMAGE) -f $(CONTAINERFILE) .

install: $(SCRIPT) ## Install claude-box as a terminal-wide command
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 $(SCRIPT) $(DEST)
	@echo "Installed $(DEST)"

uninstall: ## Remove the installed claude-box command
	rm -f $(DEST)
	@echo "Removed $(DEST)"

clean: ## Remove the built container image
	-podman rmi $(IMAGE)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
