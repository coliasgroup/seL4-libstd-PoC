.PHONY: none
none:

.PHONY: clean
clean:
	rm -rf target

.PHONY: update-manifests
update-manifests:
	$(MAKE) -C hacking/cargo-manifest-management update
	cargo update -w

.PHONY: build
build:
	nix-build -A build

.PHONY: simulate
simulate:
	script=$$(nix-build -A simulate --no-out-link) && $$script

.PHONY: test
test:
	script=$$(nix-build -A test --no-out-link) && $$script
