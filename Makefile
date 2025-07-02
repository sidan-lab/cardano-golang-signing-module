.PHONY: all clean build-rust build-go test-go help

# Default target
all: build-rust build-go

help:
	@echo "Available targets:"
	@echo "  all          - Build Rust library and Go module"
	@echo "  build-rust   - Build Rust static library for Go"
	@echo "  build-go     - Build Go module"
	@echo "  test-go      - Run Go tests"
	@echo "  clean        - Clean build artifacts"
	@echo "  help         - Show this help message"

# Build Rust static library for Go
build-rust:
	@echo "Building Rust static library for Go..."
	@mkdir -p target/release
	@cargo build --release --lib
	@echo "Rust library built successfully"

# Build Go module (this will also trigger Rust build via cgo)
build-go: build-rust
	@echo "Building Go module..."
	@go build .
	@echo "Go module built successfully"

# Test Go module
test-go: build-rust
	@echo "Running Go tests..."
	@go test -v .
	@echo "Go tests completed"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf target/
	@go clean
	@echo "Clean completed"

# Example usage targets
example-mnemonic: build-rust
	@echo "Running mnemonic example..."
	@cd examples && go run -ldflags="-extldflags=-static" example_mnemonic.go

example-bech32: build-rust
	@echo "Running bech32 example..."
	@cd examples && go run -ldflags="-extldflags=-static" example_bech32.go

example-cli: build-rust
	@echo "Running CLI example..."
	@cd examples && go run -ldflags="-extldflags=-static" example_cli.go 