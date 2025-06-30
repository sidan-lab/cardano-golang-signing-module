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

  if [ "$triple" == "darwin_amd64" ] || [ "$triple" == "darwin_arm64" ]; then
    install_name_tool -id @rpath/libsigner_go.dylib \
    target/$triple/release/deps/libsigner_go.dylib
  fi

  # Copy all signer_go and libsigner_go files (.lib, .dll, .a)
  find "target/$triple/release/" -name "signer_go*" -o -name "libsigner_go*" | while read -r file; do
    if [ -f "$file" ] && [[ "$file" =~ \.(lib|dll|a|dylib|so)$ ]]; then
      cp "$file" "$dst/"
      echo "  Copied: $(basename "$file")"
    fi
  done
done

echo -e "\n✅  All artifacts are in  $(realpath "$OUT")"