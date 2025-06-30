# Go Signer Module

A Go module for calling cryptocurrency transaction signing functions from a Rust library through CGO.

> **📝 Normal Workflow**: First try importing the package normally (`go mod tidy`, `go build`). If you get architecture or linking errors, then clone the repository and use manual build (`./build_manual.sh`).

## 🚀 Quick Start

### Step 1: Try Normal Go Import (Recommended First)
```go
// In your Go project
import "github.com/sidan-lab/cardano-golang-signing-module"

// Try to use the library
func main() {
    signer, err := signer.NewMnemonicSigner(mnemonic, derivationPath)
    // ... your code
}
```

```bash
# Install dependencies
go mod tidy
go build  # or go run main.go
```

### Step 2: Manual Build (If Prebuilt Libraries Don't Work)

If you get errors like "no prebuilt library for your architecture" or linking errors, follow these steps:

#### 1. Clone the repository
```bash
git clone https://github.com/sidan-lab/cardano-golang-signing-module.git
cd cardano-golang-signing-module
```

#### 2. Build the library manually
```bash
./build_manual.sh
```

#### 3. Use the local library in your project

```bash
# In your project directory
go mod edit -replace github.com/sidan-lab/cardano-golang-signing-module=/path/to/cardano-golang-signing-module
go mod tidy
go build
```

### For Publishing New Versions (Maintainers Only)
```bash
./build_prebuilt.sh
```

## 📋 When Do You Need Manual Build?

### Normal Workflow
1. **First try** importing the package normally (`go mod tidy`, `go build`)
2. **If that fails** with architecture or linking errors → use manual build

### Manual Build Required When:
- ❌ **No prebuilt library** for your architecture (ARM, exotic platforms, etc.)
- ❌ **Linking errors** with prebuilt libraries
- ❌ **CGO compilation issues** with distributed binaries
- ✅ **Development** - you're modifying the Rust code
- ✅ **Custom optimizations** - need specific build flags
- ✅ **Latest features** - using unreleased Rust code changes
- ✅ **Security** - want to build from source yourself

### Prebuilt Build (For Maintainers Only)
**Use `./build_prebuilt.sh` only when:**
- 🔧 **Publishing new version** - creating libraries for distribution
- 🔧 **Cross-platform builds** - building for all supported platforms
- 🔧 **Release preparation** - updating prebuilt binaries for users

## 🏗️ Complete Manual Build Guide

### Prerequisites

1. **Install Rust** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   ```

2. **Install Go** (1.19+):
   ```bash
   # macOS
   brew install go
   
   # Linux
   sudo apt install golang-go  # Ubuntu/Debian
   sudo yum install golang      # CentOS/RHEL
   
   # Windows - download from https://golang.org/dl/
   ```

3. **C Compiler**:
   ```bash
   # macOS - Xcode Command Line Tools
   xcode-select --install
   
   # Linux
   sudo apt install build-essential  # Ubuntu/Debian
   sudo yum groupinstall "Development Tools"  # CentOS/RHEL
   
   # Windows - Visual Studio Build Tools or MinGW
   ```

### Step-by-Step Manual Build

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd cardano-golang-signing-module
   ```

2. **Run the complete manual build**:
   ```bash
   ./build_manual.sh
   ```

   This script will:
   - Switch to manual build configuration
   - Build Rust library from source
   - Build Go project
   - Run tests

3. **Verify the build**:
   ```bash
   go test -v
   ```

### Manual Build Steps (Detailed)

If you prefer to run steps manually:

1. **Switch to manual build configuration**:
   ```bash
   ./switch_to_manual_build.sh
   ```

2. **Build Rust library**:
   ```bash
   cargo build --release
   ```

3. **Build Go project**:
   ```bash
   go build
   ```

4. **Run tests**:
   ```bash
   go test -v
   ```

## 📦 Available Build Scripts

### Main Build Scripts

#### `./build_manual.sh` (For Users)
**Complete manual build pipeline**
- ✅ Switches to manual build mode  
- ✅ Builds Rust library from source (`cargo build --release`)
- ✅ Builds Go project using your compiled library
- ✅ Runs tests

#### `./build_prebuilt.sh` (For Maintainers)
**Multi-platform build for publishing**
- 🔧 Switches to prebuilt library mode
- 🔧 Builds Rust libraries for all platforms (via `build_rust.sh`)
- 🔧 Updates prebuilt binaries in `prebuilt/` directory
- 🔧 Builds Go project using prebuilt libraries
- 🔧 Runs tests

### Configuration Scripts

#### `./switch_to_prebuilt.sh`
- Switches `signer.go` to use platform-specific prebuilt libraries
- Only changes configuration, doesn't build

#### `./switch_to_manual_build.sh`
- Switches `signer.go` to use unified manual build library
- Only changes configuration, doesn't build

#### `./build_rust.sh` (For Maintainers)
- Builds Rust libraries for all supported platforms
- Creates prebuilt binaries in `prebuilt/` directory  
- **Used internally by `build_prebuilt.sh`**
- Only needed when publishing new versions

## 🔄 Typical User Workflows

### Scenario 1: Normal Usage (Works out of the box)
```bash
# In your Go project
go mod init myproject
go mod tidy

# Write your Go code with the import
# import "github.com/sidan-lab/cardano-golang-signing-module"

go build  # Should work with prebuilt libraries
```

### Scenario 2: Prebuilt Libraries Don't Work
```bash
# Step 1: Clone and build manually
git clone https://github.com/sidan-lab/cardano-golang-signing-module.git
cd cardano-golang-signing-module
./build_manual.sh

# Step 2: Use in your project
cd /path/to/your/project
go mod edit -replace github.com/sidan-lab/cardano-golang-signing-module=/path/to/cardano-golang-signing-module
go mod tidy
go build
```

### For Project Maintainers
```bash
# When ready to publish new version
./build_prebuilt.sh    # Creates binaries for all platforms
git add prebuilt/      # Commit updated prebuilt libraries
git commit -m "Update prebuilt libraries for v1.x.x"
git tag v1.x.x
git push origin main --tags
```

## 📂 Supported Platforms

### Prebuilt Libraries Available
- **Linux**: `x86_64`, `aarch64` (ARM64)
- **macOS**: `x86_64` (Intel), `aarch64` (Apple Silicon)  
- **Windows**: `x86_64`

### Library Formats
- **Linux/macOS**: Static libraries (`.a`)
- **Windows**: Dynamic libraries (`.dll`)

## 🛠️ Library Locations

### Prebuilt Mode
Uses platform-specific libraries:
- **Linux**: `prebuilt/linux_{amd64,arm64}/libsigner_go.a`
- **macOS**: `prebuilt/darwin_{amd64,arm64}/libsigner_go.a`  
- **Windows**: `prebuilt/windows_amd64/signer_go.dll`

### Manual Mode
Uses your compiled library:
- **Unix (Linux/macOS)**: `target/release/libsigner_go.a`
- **Windows**: `target/release/signer_go.dll` or `libsigner_go.a`

## 📝 Usage

### Complete Example

1. **Create a new Go project**:
```bash
mkdir myproject
cd myproject
go mod init myproject
```

2. **Create main.go**:
```go
package main

import (
    "fmt"
    "log"
    "github.com/sidan-lab/cardano-golang-signing-module"
)

func main() {
    // Create signer from mnemonic phrase
    mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
    derivationPath := "m/44'/118'/0'/0/0"
    
    signer, err := signer.NewMnemonicSigner(mnemonic, derivationPath)
    if err != nil {
        log.Fatalf("Failed to create signer: %v", err)
    }
    defer signer.Close() // Important to free resources!
    
    // Get public key
    publicKey, err := signer.GetPublicKey()
    if err != nil {
        log.Fatalf("Failed to get public key: %v", err)
    }
    
    fmt.Printf("Public Key: %s\n", publicKey)
    
    // Sign transaction
    txHex := "your_transaction_hex_here"
    signature, err := signer.SignTransaction(txHex)
    if err != nil {
        log.Fatalf("Failed to sign transaction: %v", err)
    }
    
    fmt.Printf("Signature: %s\n", signature)
}
```

3. **Try to build normally first**:
```bash
go mod tidy
go build
```

4. **If that fails** → follow manual build instructions above
```

### Available Signer Types

#### 1. Mnemonic Signer
```go
signer, err := signer.NewMnemonicSigner(mnemonicPhrase, derivationPath)
```

#### 2. Bech32 Signer
```go
signer, err := signer.NewBech32Signer(rootPrivateKey, derivationPath)
```

#### 3. CLI Signer
```go
signer, err := signer.NewCLISigner(ed25519Key)
```

### Signer Methods

#### Sign Transaction
```go
signature, err := signer.SignTransaction(txHex)
```

#### Get Public Key
```go
publicKey, err := signer.GetPublicKey()
```

#### Free Resources
```go
signer.Close() // Always call this!
```

## 🔧 Build Optimization

The build is optimized to:
- ✅ **Remove debug symbols** - smaller binary size
- ✅ **Strip toolchain paths** - no personal paths in binaries
- ✅ **Link-time optimization** - better performance
- ✅ **Dead code elimination** - only needed code included

## 🐛 Troubleshooting

### Step 1: Normal Import Issues

#### "Package not found" or "Module not found"
```bash
go mod tidy
go clean -modcache
go mod download
```

#### "CGO linking errors" or "Architecture not supported"
Your platform may not have prebuilt libraries. **→ Go to Manual Build (Step 2)**

### Step 2: Manual Build Issues

#### Prerequisites Missing
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Go
# Download from https://golang.org/dl/

# Install C compiler
# macOS: xcode-select --install
# Linux: sudo apt install build-essential
```

#### Build Errors
```bash
# Clean everything and rebuild
go clean
cargo clean
./build_manual.sh
```

#### "Local module replace not working"
Make sure the path is absolute:
```bash
# Get absolute path
pwd  # Note the full path

# Use absolute path in replace
go mod edit -replace github.com/sidan-lab/cardano-golang-signing-module=/full/absolute/path/to/cardano-golang-signing-module
go mod tidy
```

### "cargo not found"
Install Rust toolchain:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### "go not found"
Install Go from https://golang.org/dl/

### CGO Compilation Errors
1. Make sure you have a C compiler installed
2. Try clean rebuild:
   ```bash
   go clean
   ./build_manual.sh  # or ./build_prebuilt.sh
   ```

### Linking Errors
1. Check that the library was built successfully
2. Try switching build modes:
   ```bash
   ./build_prebuilt.sh  # if manual fails
   # or
   ./build_manual.sh    # if prebuilt fails
   ```

### Runtime Errors
- ❌ Check that `signer.Close()` wasn't called before use
- ❌ Verify input data (mnemonic phrases, keys) is valid
- ❌ Make sure error handling is proper

## 📁 Project Structure

```
├── src/                    # Rust source code
│   ├── lib.rs             # Main Rust library
│   └── c_interface.rs     # C-compatible interface
├── include/
│   └── signer.h           # C header file
├── prebuilt/              # Prebuilt libraries
│   ├── linux_amd64/
│   ├── linux_arm64/
│   ├── darwin_amd64/
│   ├── darwin_arm64/
│   └── windows_amd64/
├── examples/              # Go examples
├── signer.go              # Go interface
├── signer_test.go         # Go tests
├── build_manual.sh        # Manual build script
├── build_prebuilt.sh      # Prebuilt build script
├── build_rust.sh          # Multi-platform Rust build
├── switch_to_manual_build.sh
├── switch_to_prebuilt.sh
├── Cargo.toml             # Rust configuration
└── .cargo/config.toml     # Cargo build config
```

## 🔒 Security Notes

1. **Memory Management**: Always call `signer.Close()` to free Rust resources
2. **Production Safety**: Never use test mnemonic phrases in production
3. **Error Handling**: Always check returned errors
4. **Build Verification**: Manual builds allow you to verify the code yourself

## 📜 License

[Add your license information here]

## 🤝 Contributing

[Add contributing guidelines here] 