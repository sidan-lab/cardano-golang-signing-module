#!/bin/bash

# Script to switch from prebuilt libraries to manually built library from target/release

echo "Switching to manually built library from target/release..."

# Backup the original file
cp signer.go signer.go.backup

# Replace all platform-specific LDFLAGS with a single unified one
sed -i.tmp \
    -e '/^#cgo linux.*LDFLAGS:/d' \
    -e '/^#cgo darwin.*LDFLAGS:/d' \
    -e '/^#cgo windows.*LDFLAGS:/d' \
    -e '/^#cgo CFLAGS:/a\
#cgo LDFLAGS: -L${SRCDIR}/target/release -lsigner_go' \
    signer.go

# Remove the temporary file created by sed
rm -f signer.go.tmp

echo "✅ Switched to manual build mode with unified LDFLAGS"
echo "📁 Original file backed up as signer.go.backup"
echo "🔨 Now build the Rust library with: cargo build --release"
echo "📦 The library will be available in target/release/" 