default: help

LOCAL_BIN = ./bin
PROTOC_PLUGIN = $(LOCAL_BIN)/protoc-gen-gogoroach
PROTOC_PLUGIN_SOURCE = cmd/protoc-gen-gogoroach/main.go

export SHELL := env PWD=$(CURDIR) bash

PROTO_DIR = txtmsg
PROTO = $(PROTO_DIR)/message.proto
GO_SOURCE = $(PROTO_DIR)/message.pb.go
TEMP_GO_ROOT = github.com/
TEMP_GO_SOURCE = $(TEMP_GO_ROOT)/mspilly22/plib/$(GO_SOURCE)

SED = sed
SED_INPLACE := $(shell $(SED) --version 2>&1 | grep -q GNU && echo -i || echo "-i ''")

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(firstword $(MAKEFILE_LIST))

.PHONY: protoc-gen-gogoroach
protoc-gen-gogoroach: $(PROTOC_PLUGIN) ## Create the protoc-gen-gogoroach binary
$(PROTOC_PLUGIN): $(PROTOC_PLUGIN_SOURCE)
	go build -o $(PROTOC_PLUGIN) $^

.PHONY: gen-temp-pb-go
gen-temp-pb-go: protoc-gen-gogoroach $(TEMP_GO_SOURCE) ## Regenerate the pb.go file in the temporary location
$(TEMP_GO_SOURCE): $(PROTO)
	PATH=$$PATH:$(LOCAL_BIN) protoc \
		-I. \
		--go_out=$(TEMP_GO_ROOT) \
		--gogoroach_out=Mgoogle/protobuf/any.proto=github.com/gogo/protobuf/types,plugins=grpc,import_prefix=:. \
		$^
	$(SED) $(SED_INPLACE) -E \
		-e '/import _ /d' \
		-e 's!import (fmt|math) "github.com/(fmt|math)"! !g' \
		-e 's!github.com/((bytes|encoding/binary|errors|fmt|io|math|github\.com|(google\.)?golang\.org)([^a-z]|$$))!\1!g' \
		-e 's!golang.org/x/net/context!context!g' \
		$(TEMP_GO_SOURCE)
	gofmt -s -w $(TEMP_GO_SOURCE)

.PHONY: refresh-pb-go
refresh-pb-go: $(TEMP_GO_SOURCE) $(GO_SOURCE) ## Copy the generated pb.go file from its temporary location to permanent location
	cp --preserve $(TEMP_GO_SOURCE) $(GO_SOURCE)

.PHONY: verify-pb-go-up-to-date
verify-pb-go-up-to-date: gen-temp-pb-go ## This verifies that the generated protobuf file is up to date
	diff -U2 $(TEMP_GO_SOURCE) $(GO_SOURCE)

.PHONY: test
test: ## Test the library
	go test ./...

