#!/bin/bash

set -e

echo "=== Go Signer Module Build Check ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
        exit 1
    fi
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check prerequisites
print_info "Checking prerequisites..."

# Check Rust
if command -v cargo &> /dev/null; then
    echo -e "${GREEN}✓ Cargo found: $(cargo --version)${NC}"
else
    echo -e "${RED}✗ Cargo not found. Please install Rust toolchain.${NC}"
    exit 1
fi

# Check Go
if command -v go &> /dev/null; then
    echo -e "${GREEN}✓ Go found: $(go version)${NC}"
else
    echo -e "${RED}✗ Go not found. Please install Go.${NC}"
    exit 1
fi

# Check C compiler
if command -v gcc &> /dev/null; then
    echo -e "${GREEN}✓ GCC found: $(gcc --version | head -n1)${NC}"
elif command -v clang &> /dev/null; then
    echo -e "${GREEN}✓ Clang found: $(clang --version | head -n1)${NC}"
else
    echo -e "${RED}✗ C compiler not found. Please install GCC or Clang.${NC}"
    exit 1
fi

echo

# Check file structure
print_info "Checking file structure..."

required_files=(
    "src/lib.rs"
    "src/c_interface.rs"
    "include/signer.h"
    "go.mod"
    "signer.go"
    "signer_test.go"
    "Cargo.toml"
    "Makefile"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ Found: $file${NC}"
    else
        echo -e "${RED}✗ Missing: $file${NC}"
        exit 1
    fi
done

echo

# Build Rust library
print_info "Building Rust library..."
make build-rust
print_status "Rust library build"

# Check if library was created
if [ -f "target/release/libsigner_go.a" ]; then
    echo -e "${GREEN}✓ Static library created: target/release/libsigner_go.a${NC}"
    ls -lh target/release/libsigner_go.a
else
    echo -e "${RED}✗ Static library not found${NC}"
    exit 1
fi

echo

# Build Go module
print_info "Building Go module..."
go build .
print_status "Go module build"

echo

# Run tests
print_info "Running Go tests..."
go test -v .
print_status "Go tests"

echo
echo -e "${GREEN}=== All checks passed! ===${NC}"
echo
echo "You can now use the Go signer module:"
echo "  cd examples"
echo "  go run example_mnemonic.go" 