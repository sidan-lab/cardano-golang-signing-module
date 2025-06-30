#!/bin/bash

# Full prebuilt build script - uses precompiled libraries

set -e  # Exit on any error

echo "📦 Starting prebuilt build..."

# Step 1: Switch to prebuilt mode
echo "📝 Step 1: Switching to prebuilt libraries..."
./switch_to_prebuilt.sh

# Step 2: Build Rust libraries
echo "🔍 Step 2: Building Rust libraries..."
./build_rust.sh

# Step 3: Detect platform
echo "🔍 Step 3: Detecting platform..."

# Detect current platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $(uname -m) == "arm64" ]]; then
        PLATFORM="darwin_arm64"
    else
        PLATFORM="darwin_amd64"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ $(uname -m) == "aarch64" ]]; then
        PLATFORM="linux_arm64"
    else
        PLATFORM="linux_amd64"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    PLATFORM="windows_amd64"
else
    echo "❌ Unsupported platform: $OSTYPE"
    exit 1
fi

echo "🎯 Using platform: $PLATFORM"

# Step 4: Build Go project
echo "🐹 Step 4: Building Go project with prebuilt libraries..."
if ! command -v go &> /dev/null; then
    echo "❌ Error: go not found. Please install Go first."
    exit 1
fi

go build
if [ $? -ne 0 ]; then
    echo "❌ Go build failed!"
    echo "💡 Try building manually: ./build_manual.sh"
    exit 1
fi

# Step 5: Run tests (optional)
echo "🧪 Step 5: Running tests..."
go test -v
if [ $? -ne 0 ]; then
    echo "⚠️  Some tests failed, but build completed"
else
    echo "✅ All tests passed!"
fi

echo ""
echo "🎉 Prebuilt build completed successfully!"
echo "📦 Using prebuilt library for $PLATFORM"
echo "🔄 To build from source: ./build_manual.sh" 