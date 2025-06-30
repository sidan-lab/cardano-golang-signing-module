package signer

import (
	"testing"
)

func TestNewMnemonicSigner(t *testing.T) {
	// Test with valid mnemonic and derivation path
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	derivationPath := "m/44'/118'/0'/0/0"
	
	signer, err := NewMnemonicSigner(mnemonic, derivationPath)
	if err != nil {
		t.Fatalf("Failed to create mnemonic signer: %v", err)
	}
	defer signer.Close()
	
	// Test getting public key
	publicKey, err := signer.GetPublicKey()
	if err != nil {
		t.Fatalf("Failed to get public key: %v", err)
	}
	
	if len(publicKey) == 0 {
		t.Fatal("Public key should not be empty")
	}
	
	t.Logf("Public key: %s", publicKey)
}

func TestNewMnemonicSignerInvalid(t *testing.T) {
	// Test with invalid mnemonic
	_, err := NewMnemonicSigner("invalid mnemonic", "m/44'/118'/0'/0/0")
	if err == nil {
		t.Fatal("Expected error for invalid mnemonic")
	}
}