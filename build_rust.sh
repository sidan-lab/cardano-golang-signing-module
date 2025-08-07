#!/usr/bin/env bash
# Build signer_go for multiple targets and copy ready-made
# artifacts into prebuilt/GOOS_GOARCH/ so that Go can link them.

set -euo pipefail
ROOT="$(dirname "$(realpath "$0")")/"      # repo root
OUT="$ROOT/prebuilt"

#  GOOS_GOARCH      →  Rust target triple
declare -A TARGETS=(
  [linux_amd64]=x86_64-unknown-linux-gnu
  [linux_arm64]=aarch64-unknown-linux-gnu
  [darwin_amd64]=x86_64-apple-darwin
  [darwin_arm64]=aarch64-apple-darwin
  [windows_amd64]=x86_64-pc-windows-gnu     # change to -msvc if you prefer MSVC
)

export MACOSX_DEPLOYMENT_TARGET=15.0
export CARGO_NET_GIT_FETCH_WITH_CLI=true     # faster CI clones

# Control whether to copy dynamic libraries (.dll, .dylib, .so) and Windows import libraries (*.dll.a, *.dll.lib)
# By default only static libraries (.a, .lib) are copied, excluding Windows import libraries
COPY_DYNAMIC_LIBS="${COPY_DYNAMIC_LIBS:-true}"

CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTFLAGS="--remap-path-prefix=$CARGO_HOME=/cargo --remap-path-prefix=$HOME=/home/user --remap-path-prefix=$ROOT=/build ${RUSTFLAGS:-}"

for key in "${!TARGETS[@]}"; do
  triple="${TARGETS[$key]}"
  echo -e "\n=== Building $key  →  $triple ==="

  # 1) Make sure std for this target is installed
  rustup target add "$triple" || true

  # 2) Build the Rust library
  cargo build --release --manifest-path "$ROOT/Cargo.toml" \
              --target "$triple"

  # 3) Copy result into prebuilt/
  dst="$OUT/$key"
  mkdir -p "$dst"

  # Copy all signer_go and libsigner_go files
  find "target/$triple/release/" -name "signer_go*" -o -name "libsigner_go*" | while read -r file; do
    if [ -f "$file" ]; then
      # Copy static libraries (but exclude Windows import libraries *.dll.a, *.dll.lib)
      if [[ "$file" =~ \.(lib|a)$ ]] && [[ ! "$file" =~ \.dll\.(lib|a)$ ]]; then
        cp "$file" "$dst/"
        echo "  Copied: $(basename "$file")"
      # Copy dynamic libraries and Windows import libraries only if enabled
      elif [[ "$COPY_DYNAMIC_LIBS" == "true" ]] && [[ "$file" =~ \.(dll|dylib|so|dll\.a|dll\.lib)$ ]]; then
        cp "$file" "$dst/"
        echo "  Copied: $(basename "$file")"
      fi
    fi
  done

  # Fix install_name for macOS dylibs AFTER copying (only if dynamic libs are enabled)
  if [[ "$COPY_DYNAMIC_LIBS" == "true" ]] && ([[ "$key" == "darwin_amd64" ]] || [[ "$key" == "darwin_arm64" ]]); then
    if [ -f "$dst/libsigner_go.dylib" ]; then
      install_name_tool -id @rpath/libsigner_go.dylib "$dst/libsigner_go.dylib"
      echo "  Fixed install_name for $dst/libsigner_go.dylib"
    fi
  fi
done

echo -e "\n✅  All artifacts are in  $(realpath "$OUT")"