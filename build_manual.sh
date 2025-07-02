#!/bin/bash

# Full manual build script - builds everything from source

set -e  # Exit on any error

echo "🔨 Starting full manual build..."

# Step 1: Switch to manual build mode
echo "📝 Step 1: Switching to manual build mode..."
./switch_to_manual_build.sh

# Step 2: Build Rust library
echo "🦀 Step 2: Building Rust library..."
if ! command -v cargo &> /dev/null; then
    echo "❌ Error: cargo not found. Please install Rust first."
    echo "   Visit: https://rustup.rs/"
    exit 1
fi

cargo build --release
if [ $? -ne 0 ]; then
    echo "❌ Rust build failed!"
    exit 1
fi

echo "✅ Rust library built successfully"

# Step 3: Build Go project
echo "🐹 Step 3: Building Go project..."
if ! command -v go &> /dev/null; then
    echo "❌ Error: go not found. Please install Go first."
    exit 1
fi

go build
if [ $? -ne 0 ]; then
    echo "❌ Go build failed!"
    exit 1
fi

# Step 4: Run tests (optional)
echo "🧪 Step 4: Running tests..."
go test -v
if [ $? -ne 0 ]; then
    echo "⚠️  Some tests failed, but build completed"
else
    echo "✅ All tests passed!"
fi

echo ""
echo "🎉 Manual build completed successfully!"
echo "📦 Your library is ready to use"
echo "🔄 To switch back to prebuilt: ./build_prebuilt.sh" 