package signer

/*
#cgo CFLAGS: -I${SRCDIR}/include
#cgo linux,amd64  LDFLAGS: -L${SRCDIR}/prebuilt/linux_amd64  -lsigner_go -ldl -lpthread
#cgo linux,arm64  LDFLAGS: -L${SRCDIR}/prebuilt/linux_arm64  -lsigner_go -ldl -lpthread

#cgo darwin,amd64 LDFLAGS: -L${SRCDIR}/prebuilt/darwin_amd64 -lsigner_go -framework Security -framework CoreFoundation
#cgo darwin,arm64 LDFLAGS: -L${SRCDIR}/prebuilt/darwin_arm64 -lsigner_go -framework Security -framework CoreFoundation

#cgo windows,amd64 LDFLAGS: -L${SRCDIR}/prebuilt/windows_amd64 -lsigner_go -lws2_32 -lbcrypt



#include <stdlib.h>
#include "signer.h"
*/
import "C"
import (
	"errors"
	"unsafe"
)

// Signer represents a cryptographic signer
type Signer struct {
	ptr *C.CSigner
}

// NewMnemonicSigner creates a new signer from a mnemonic phrase
func NewMnemonicSigner(mnemonicPhrase, derivationPath string) (*Signer, error) {
	cMnemonic := C.CString(mnemonicPhrase)
	defer C.free(unsafe.Pointer(cMnemonic))

	cDerivationPath := C.CString(derivationPath)
	defer C.free(unsafe.Pointer(cDerivationPath))

	ptr := C.signer_new_mnemonic(cMnemonic, cDerivationPath)
	if ptr == nil {
		return nil, errors.New("failed to create mnemonic signer")
	}

	return &Signer{ptr: ptr}, nil
}

// NewBech32Signer creates a new signer from a root private key (bech32)
func NewBech32Signer(rootPrivateKey, derivationPath string) (*Signer, error) {
	cRootPrivateKey := C.CString(rootPrivateKey)
	defer C.free(unsafe.Pointer(cRootPrivateKey))

	cDerivationPath := C.CString(derivationPath)
	defer C.free(unsafe.Pointer(cDerivationPath))

	ptr := C.signer_new_bech32(cRootPrivateKey, cDerivationPath)
	if ptr == nil {
		return nil, errors.New("failed to create bech32 signer")
	}

	return &Signer{ptr: ptr}, nil
}

// NewCLISigner creates a new signer from an ED25519 key (CLI style)
func NewCLISigner(ed25519Key string) (*Signer, error) {
	cED25519Key := C.CString(ed25519Key)
	defer C.free(unsafe.Pointer(cED25519Key))

	ptr := C.signer_new_cli(cED25519Key)
	if ptr == nil {
		return nil, errors.New("failed to create CLI signer")
	}

	return &Signer{ptr: ptr}, nil
}

// SignTransaction signs a transaction and returns the signature
func (s *Signer) SignTransaction(txHex string) (string, error) {
	if s.ptr == nil {
		return "", errors.New("signer is nil")
	}

	cTxHex := C.CString(txHex)
	defer C.free(unsafe.Pointer(cTxHex))

	cSignature := C.signer_sign_transaction(s.ptr, cTxHex)
	if cSignature == nil {
		return "", errors.New("failed to sign transaction")
	}
	defer C.signer_free_string(cSignature)

	return C.GoString(cSignature), nil
}

// GetPublicKey returns the public key as a hex string
func (s *Signer) GetPublicKey() (string, error) {
	if s.ptr == nil {
		return "", errors.New("signer is nil")
	}

	cPublicKey := C.signer_get_public_key(s.ptr)
	if cPublicKey == nil {
		return "", errors.New("failed to get public key")
	}
	defer C.signer_free_string(cPublicKey)

	return C.GoString(cPublicKey), nil
}

// Close frees the signer resources
func (s *Signer) Close() {
	if s.ptr != nil {
		C.signer_free(s.ptr)
		s.ptr = nil
	}
}
