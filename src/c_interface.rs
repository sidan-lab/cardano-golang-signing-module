use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use whisky_wallet::{
    derivation_indices::DerivationIndices, Account, MnemonicWallet, RootKeyWallet, Wallet,
    WalletType,
};

/// Opaque handle for Signer instances
pub struct CSigner {
    account: Account,
}

/// Create a new signer from mnemonic phrase
/// Returns null pointer if creation fails
#[no_mangle]
pub extern "C" fn signer_new_mnemonic(
    mnemonic_phrase: *const c_char,
    derivation_path: *const c_char,
) -> *mut CSigner {
    if mnemonic_phrase.is_null() || derivation_path.is_null() {
        return std::ptr::null_mut();
    }

    let mnemonic_str = match unsafe { CStr::from_ptr(mnemonic_phrase) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let derivation_str = match unsafe { CStr::from_ptr(derivation_path) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let wallet = Wallet::new(WalletType::MnemonicWallet(MnemonicWallet {
        mnemonic_phrase: mnemonic_str.to_string(),
        derivation_indices: DerivationIndices::from_str(derivation_str),
    }));

    match wallet.get_account() {
        Ok(account) => Box::into_raw(Box::new(CSigner { account })),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Create a new signer from root private key (bech32)
/// Returns null pointer if creation fails
#[no_mangle]
pub extern "C" fn signer_new_bech32(
    root_private_key: *const c_char,
    derivation_path: *const c_char,
) -> *mut CSigner {
    if root_private_key.is_null() || derivation_path.is_null() {
        return std::ptr::null_mut();
    }

    let key_str = match unsafe { CStr::from_ptr(root_private_key) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let derivation_str = match unsafe { CStr::from_ptr(derivation_path) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let wallet = Wallet::new(WalletType::RootKeyWallet(RootKeyWallet {
        root_key: key_str.to_string(),
        derivation_indices: DerivationIndices::from_str(derivation_str),
    }));

    match wallet.get_account() {
        Ok(account) => Box::into_raw(Box::new(CSigner { account })),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Create a new signer from ED25519 key (CLI style)
/// Returns null pointer if creation fails
#[no_mangle]
pub extern "C" fn signer_new_cli(ed25519_key: *const c_char) -> *mut CSigner {
    if ed25519_key.is_null() {
        return std::ptr::null_mut();
    }

    let key_str = match unsafe { CStr::from_ptr(ed25519_key) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let wallet = Wallet::new_cli(key_str);

    match wallet.get_account() {
        Ok(account) => Box::into_raw(Box::new(CSigner { account })),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Sign a transaction
/// Returns pointer to null-terminated string with signature, or null on error
/// Caller must free the returned string using signer_free_string
#[no_mangle]
pub extern "C" fn signer_sign_transaction(
    signer: *mut CSigner,
    tx_hex: *const c_char,
) -> *mut c_char {
    if signer.is_null() || tx_hex.is_null() {
        return std::ptr::null_mut();
    }

    let signer_ref = unsafe { &*signer };
    let tx_str = match unsafe { CStr::from_ptr(tx_hex) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    match signer_ref.account.sign_transaction(tx_str) {
        Ok(signature) => match CString::new(signature) {
            Ok(c_string) => c_string.into_raw(),
            Err(_) => std::ptr::null_mut(),
        },
        Err(_) => std::ptr::null_mut(),
    }
}

/// Get public key as hex string
/// Returns pointer to null-terminated string with public key, or null on error
/// Caller must free the returned string using signer_free_string
#[no_mangle]
pub extern "C" fn signer_get_public_key(signer: *mut CSigner) -> *mut c_char {
    if signer.is_null() {
        return std::ptr::null_mut();
    }

    let signer_ref = unsafe { &*signer };
    let public_key = signer_ref.account.public_key.to_hex();

    match CString::new(public_key) {
        Ok(c_string) => c_string.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Free a signer instance
#[no_mangle]
pub extern "C" fn signer_free(signer: *mut CSigner) {
    if !signer.is_null() {
        unsafe {
            let _ = Box::from_raw(signer);
        }
    }
}

/// Free a string returned by the library
#[no_mangle]
pub extern "C" fn signer_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
} 