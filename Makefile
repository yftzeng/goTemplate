VERSION=$(shell git describe --tags --always --dirty 2> /dev/null || date +%F_%H-%M-%S)
LDFLAGS=-s -X 'main.version=$(VERSION)'

PROXY_SITE := blog.gcos.me:3128

default:
	@echo $$ make init
	@echo $$ make build
	@echo $$ make run
	@echo $$ make doc
	@echo $$ make fmt
	@echo $$ make lint
	@echo $$ make vet
	@echo $$ make test
	@echo $$ make vendor_update
	@echo $$ make proxy_vendor_update
	@echo $$ make vendor_clean
	@echo $$ make distclean

.PHONY: build
build: check_gopath vet
	CGO_ENABLED=0 GOOS=linux go build -a -o ./pkg/main -ldflags "$(LDFLAGS)" ./src/main.go
	@echo ""
	@echo "================================================"
	@echo ""
	@test -x "./vendor/bin/goupx" && ./vendor/bin/goupx --strip-binary ./pkg/main && exit ; \
    test -x "$(shell which goupx)" && goupx --strip-binary ./pkg/main && exit ; \
	echo "goupx not found, please install with it:" && \
	echo "$$ make init"
	@echo ""
	@echo "================================================"
	@echo ""
	cp -rf ./config ./pkg/.
	cp -rf ./log ./pkg/.

.PHONY: doc
doc: check_gopath
	godoc -http=:6060 -index

# http://golang.org/cmd/go/#hdr-Run_gofmt_on_package_sources
.PHONY: fmt
fmt: check_gopath
	@go fmt ./src/...

.PHONY: run
run: build
	cd pkg ; ./main

.PHONY: test
test: check_gopath
	@go test -race ./src/...

.PHONY: vendor_clean
vendor_clean:
	rm -dRf ./src/vendor

.PHONY: distclean
distclean: vendor_clean
	rm -dRf trash-cache
	rm -dRf trash.conf
	rm -dRf vendor
	rm -dRf vendor_bin
	rm -dRf pkg/*

.PHONY: proxy_vendor_update
proxy_vendor_update: set_proxy
	@make vendor_update
	@make del_proxy > /dev/null

.PHONY: proxy_init
proxy_init: set_proxy
	@make init
	@make del_proxy > /dev/null

.PHONY: init
init: check_gopath
	@test -f VENDOR_BIN && \
	GOPATH=${PWD}/vendor_bin go get -u -v \
	$(shell paste -s -d ' ' VENDOR_BIN)
	@test -x "./vendor_bin/bin/trash" && _TMP_GOPATH=$$(pwd) && cd src && echo "GOPATH=$${_TMP_GOPATH}" > ../trash.conf && ../vendor_bin/bin/trash --cache "$${_TMP_GOPATH}/trash-cache" -u -f ../trash.conf && exit ; \
	echo "trash not found, please install with it:" && \
	echo "$$ make init"

.PHONY: vendor_update
vendor_update: check_gopath
	@test -x "./vendor_bin/bin/trash" && _TMP_GOPATH=$$(pwd) && ./vendor_bin/bin/trash --cache "$${_TMP_GOPATH}/trash-cache" -k -f trash.conf && exit ; \
	echo "trash not found, please install with it:" && \
	echo "$$ make init"
	@cd vendor && ln -s . src

# https://github.com/golang/lint
# go get github.com/golang/lint/golint
.PHONY: lint
lint: check_gopath
	@test -x "./vendor/bin/golint" && ./vendor/bin/golint ./src && exit ; \
    test -x "$(shell which golint)" && golint ./src && exit ; \
	echo "golint not found, please install with it:" && \
	echo "$$ make init"

# http://godoc.org/code.google.com/p/go.tools/cmd/vet
# go get code.google.com/p/go.tools/cmd/vet
.PHONY: vet
vet: check_gopath
	@go vet ./src/...

check_gopath:
ifndef GOPATH
GOPATH := ${PWD}/vendor
else
GOPATH := ${PWD}/vendor:${GOPATH}
endif
export GOPATH
#export GO15VENDOREXPERIMENT=1

.PHONY: set_proxy
set_proxy:
	@read -p "Proxy username: " username ; \
	read -s -p "Proxy password: " password ; \
	git config --global http.proxy http://$$username:$$password@$(PROXY_SITE) ; \
	git config --global https.proxy http://$$username:$$password@$(PROXY_SITE)

.PHONY: del_proxy
del_proxy:
	#@git config --global --remove-section http
	#@git config --global --remove-section https
	@git config --global --unset http.proxy || true
	@git config --global --unset https.proxy || true
