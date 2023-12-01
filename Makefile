.PHONY: test
test:
	swift test

.PHONY: lint
lint:
	swiftlint lint --config .swiftlint.yaml .
