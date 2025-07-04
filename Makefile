# Use `make V=1` to print commands.
$(V).SILENT:


# MAIN_BUILD_PKG  ?= . 
# MAIN_APPS       ?= cli
# SUB_APPS        ?= azt loop
# MAIN_ENTRY_FILE ?= .                 # Or: "main.go"

-include ./ci/mk/env.mk
-include ./ci/mk/cc.mk
-include ./ci/mk/git.mk

-include .env
-include .env.local


NAME           := azt
PACKAGE_NAME   := github.com/moreban/azt
ENTRY_PKG      := ./cli/azt

PLATFORM       := linux
ARCH           := amd64
BUILD_DIR      := bin
LOGS_DIR       := ./logs
GO             := $(shell which go)
GOOS           := $(shell go env GOOS)
GOARCH         := $(shell go env GOARCH)
GOPROXY        := $(shell go env GOPROXY)
GOVERSION      := $(shell go version)
DEFAULT_TARGET := $(GOOS)-$(GOARCH)
W_PKG          := github.com/hedzr/cmdr/v2/conf
CMDR_SETTING   := \
	-X '$(W_PKG).Buildstamp=$(TIMESTAMP)' \
	-X '$(W_PKG).Githash=$(GIT_REVISION)' \
	-X '$(W_PKG).GitSummary=$(GIT_SUMMARY)' \
	-X '$(W_PKG).GitDesc=$(GIT_DESC)' \
	-X '$(W_PKG).BuilderComments=$(BUILDER_COMMENT)' \
	-X '$(W_PKG).GoVersion=$(GOVERSION)' \
	-X '$(W_PKG).Version=$(GIT_VERSION)' \
	-X '$(W_PKG).AppName=$(NAME)'
GOBUILD := CGO_ENABLED=0 \
	$(GO) build \
	-tags "cmdr hzstudio sec antonal" \
	-trimpath \
	-ldflags="-s -w $(CMDR_SETTING)" \
	-o $(BUILD_DIR)

.PHONY: all $(BUILD_DIR)/$(NAME) release release-all test build
all: build
normal: clean $(BUILD_DIR)/$(NAME)

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.zip
	rm -f *.dat

geoip.dat:
	wget https://github.com/v2fly/geoip/raw/release/geoip.dat

geoip-only-cn-private.dat:
	wget https://github.com/v2fly/geoip/raw/release/geoip-only-cn-private.dat

geosite.dat:
	wget https://github.com/v2fly/domain-list-community/raw/release/dlc.dat -O geosite.dat

## test: run go test
test: cov
## cov: run go coverage
cov: | $(LOGS_DIR)
	@$(HEADLINE) "Running go coverage..."
	$(GO) test ./... -v -race -cover -coverprofile=$(LOGS_DIR)/coverage-cl.txt -covermode=atomic -test.short -vet=off 2>&1 | tee $(LOGS_DIR)/cover-cl.log && echo "RET-CODE OF TESTING: $?"

$(LOGS_DIR):
	@mkdir -pv $@

.PHONY: directories
directories: | $(BUILD_DIR) $(LOGS_DIR)

## build: build executable for current OS and CPU (arch)
build: $(DEFAULT_TARGET)
	@echo BUILD OK

azt-go: $(BUILD_DIR)/$(NAME)
azt: $(BUILD_DIR)/$(NAME)
$(BUILD_DIR)/$(NAME): | $(BUILD_DIR)
	@# mkdir -p $(BUILD_DIR)
	GOOS=$(PLATFORM) GOARCH=$(ARCH) $(GOBUILD) $(ENTRY_PKG)
	$(LL) $(BUILD_DIR)/$(NAME)

install: $(BUILD_DIR)/$(NAME) geoip.dat geoip-only-cn-private.dat geosite.dat
	@$(INSTALL_CMD) mkdir -pv $(INSTALL_PREFIX)/etc/$(NAME)
	@$(INSTALL_CMD) mkdir -pv $(INSTALL_PREFIX)/share/$(NAME)
	# @$(INSTALL_CMD) cp example/*.json $(INSTALL_PREFIX)/etc/$(NAME)
	@$(INSTALL_CMD) cp $(BUILD_DIR)/$(NAME) $(INSTALL_PREFIX)/bin/$(NAME)
	# @$(INSTALL_CMD) cp example/$(NAME).service $(INSTALL_PREFIX)/lib/systemd/system/
	# @$(INSTALL_CMD) cp example/$(NAME)@.service $(INSTALL_PREFIX)/lib/systemd/system/
	# @$(INSTALL_CMD) systemctl daemon-reload
	@$(INSTALL_CMD) cp geosite.dat $(INSTALL_PREFIX)/share/$(NAME)/geosite.dat
	@$(INSTALL_CMD) cp geoip.dat $(INSTALL_PREFIX)/share/$(NAME)/geoip.dat
	@$(INSTALL_CMD) cp geoip-only-cn-private.dat $(INSTALL_PREFIX)/share/$(NAME)/geoip-only-cn-private.dat
	# @$(INSTALL_CMD) ln -fs $(INSTALL_PREFIX)/share/$(NAME)/geoip.dat /usr/bin/
	# @$(INSTALL_CMD) ln -fs $(INSTALL_PREFIX)/share/$(NAME)/geoip-only-cn-private.dat /usr/bin/
	# @$(INSTALL_CMD) ln -fs $(INSTALL_PREFIX)/share/$(NAME)/geosite.dat /usr/bin/
	@$(INSTALL_HELP)

uninstall:
	# @$(UNINSTALL_CMD) rm $(INSTALL_PREFIX)/lib/systemd/system/$(NAME).service
	# @$(UNINSTALL_CMD) rm $(INSTALL_PREFIX)/lib/systemd/system/$(NAME)@.service
	# @$(UNINSTALL_CMD) systemctl daemon-reload
	@$(UNINSTALL_CMD) rm $(INSTALL_PREFIX)/bin/$(NAME)
	@$(UNINSTALL_CMD) rm -rd $(INSTALL_PREFIX)/etc/$(NAME)
	@$(UNINSTALL_CMD) rm -rd $(INSTALL_PREFIX)/share/$(NAME)
	# @$(UNINSTALL_CMD) rm /usr/bin/geoip.dat
	# @$(UNINSTALL_CMD) rm /usr/bin/geoip-only-cn-private.dat
	# @$(UNINSTALL_CMD) rm /usr/bin/geosite.dat
	@$(UNINSTALL_HELP)

%.zip: % geosite.dat geoip.dat geoip-only-cn-private.dat
	@zip -du $(NAME)-$@ -j $(BUILD_DIR)/$</*
	# @zip -du $(NAME)-$@ example/*
	@-zip -du $(NAME)-$@ *.dat
	@echo "<<< ---- $(NAME)-$@"

release: geosite.dat geoip.dat geoip-only-cn-private.dat \
	darwin-amd64.zip darwin-arm64.zip \
	linux-amd64.zip linux-arm64.zip \
	windows-amd64.zip windows-arm64.zip
	ls -la azt-*.*

release-all: geosite.dat geoip.dat geoip-only-cn-private.dat darwin-amd64.zip darwin-arm64.zip linux-386.zip linux-amd64.zip \
	linux-arm.zip linux-armv5.zip linux-armv6.zip linux-armv7.zip linux-armv8.zip \
	linux-mips-softfloat.zip linux-mips-hardfloat.zip linux-mipsle-softfloat.zip linux-mipsle-hardfloat.zip \
	linux-mips64.zip linux-mips64le.zip \
	freebsd-386.zip freebsd-amd64.zip \
	windows-386.zip windows-amd64.zip windows-arm.zip windows-armv6.zip \
	windows-armv7.zip windows-arm64.zip

-include ./ci/mk/go-targets.mk
-include ./ci/mk/help.mk

help-extras:
	@echo
	@echo "              GO = $(GO)"
	@echo "            GOOS = $(GOOS)"
	@echo "          GOARCH = $(GOARCH)"
	@echo "         GOPROXY = $(GOPROXY)"
	@echo
	@echo "  DEFAULT_TARGET = $(DEFAULT_TARGET)"
	@echo "       TIMESTAMP = $(TIMESTAMP)"
	@echo "   VERSION (git) = $(GIT_VERSION)"
	@echo " VERSION (dirty) = $(DIRTY_VERSION)"
	@echo "     COMMIT/HASH = $(GIT_HASH)"
	@echo "    GIT_REVISION = $(GIT_REVISION)"
	@echo "        GIT_DESC = $(GIT_DESC)"
	@echo
	@echo "            NAME = $(NAME)"
	@echo
	@echo " To build $(NAME) under current os and arch, use: 'make V=1 build', or 'make build'."
	@echo " To build $(NAME) for others, use: 'make build linux-amd64', or other os and architect names."
