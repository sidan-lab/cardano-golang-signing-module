#!/bin/bash

# Script to switch back from manually built library to prebuilt libraries

echo "Switching back to prebuilt libraries..."

# Backup the current file
cp signer.go signer.go.manual_backup

# Replace unified LDFLAGS with platform-specific ones
sed -i.tmp \
    -e 's|#cgo LDFLAGS: -L${SRCDIR}/target/release -lsigner_go|#cgo linux,amd64  LDFLAGS: -L${SRCDIR}/prebuilt/linux_amd64  -lsigner_go -ldl -lpthread\
#cgo linux,arm64  LDFLAGS: -L${SRCDIR}/prebuilt/linux_arm64  -lsigner_go -ldl -lpthread\
\
#cgo darwin,amd64 LDFLAGS: -L${SRCDIR}/prebuilt/darwin_amd64 -lsigner_go -framework Security -framework CoreFoundation\
#cgo darwin,arm64 LDFLAGS: -L${SRCDIR}/prebuilt/darwin_arm64 -lsigner_go -framework Security -framework CoreFoundation\
\
#cgo windows,amd64 LDFLAGS: -L${SRCDIR}/prebuilt/windows_amd64 -lsigner_go -lws2_32 -lbcrypt|' \
    signer.go

# Remove the temporary file created by sed
rm -f signer.go.tmp

echo "✅ Switched back to prebuilt libraries"
echo "📁 Manual build version backed up as signer.go.manual_backup" 