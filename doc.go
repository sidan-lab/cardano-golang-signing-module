// Package signer provides cryptographic signing functionality for blockchain transactions.
//
// This package offers a Go interface to a Rust-based signing library through CGO,
// supporting multiple signer types including mnemonic phrase, bech32 private keys,
// and ED25519 CLI-style keys.
//
// # Basic Usage
//
//	import "github.com/sidan-lab/cardano-golang-signing-module"
//
//	// Create a signer from mnemonic phrase
//	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
//	derivationPath := "m/44'/118'/0'/0/0"
//	signer, err := signer.NewMnemonicSigner(mnemonic, derivationPath)
//	if err != nil {
//	    log.Fatal(err)
//	}
//	defer signer.Close() // Important: always close to free resources
//
//	// Get public key
//	publicKey, err := signer.GetPublicKey()
//	if err != nil {
//	    log.Fatal(err)
//	}
//
//	// Sign transaction
//	signature, err := signer.SignTransaction(transactionHex)
//	if err != nil {
//	    log.Fatal(err)
//	}
//
// # Supported Signer Types
//
// - Mnemonic: Create signers from BIP39 mnemonic phrases
// - Bech32: Create signers from bech32-encoded private keys
// - CLI: Create signers from ED25519 keys in CLI format
//
// # Requirements
//
// This package requires CGO to be enabled and the following dependencies:
// - Rust toolchain (for building the underlying library)
// - C compiler (GCC or Clang)
// - Go 1.19 or higher
//
// # Memory Management
//
// Always call Close() on signer instances to properly free underlying Rust resources:
//
//	signer, err := signer.NewMnemonicSigner(mnemonic, path)
//	if err != nil {
//	    return err
//	}
//	defer signer.Close() // Essential for proper cleanup
//
// # Security Notes
//
// - Never use test mnemonic phrases in production
// - Always validate input data before signing
// - Store private keys securely
//
// For more examples and documentation, see: https://github.com/sidan-lab/cardano-golang-signing-module
package signer
