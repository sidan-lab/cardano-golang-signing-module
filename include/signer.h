#ifndef SIGNER_H
#define SIGNER_H

#ifdef __cplusplus
extern "C" {
#endif

// Opaque handle for Signer instances
typedef struct CSigner CSigner;

/**
 * Create a new signer from mnemonic phrase
 * @param mnemonic_phrase - null-terminated mnemonic phrase string
 * @param derivation_path - null-terminated derivation path string
 * @return pointer to CSigner or NULL on error
 */
CSigner* signer_new_mnemonic(const char* mnemonic_phrase, const char* derivation_path);

/**
 * Create a new signer from root private key (bech32)
 * @param root_private_key - null-terminated root private key string
 * @param derivation_path - null-terminated derivation path string  
 * @return pointer to CSigner or NULL on error
 */
CSigner* signer_new_bech32(const char* root_private_key, const char* derivation_path);

/**
 * Create a new signer from ED25519 key (CLI style)
 * @param ed25519_key - null-terminated ED25519 key string
 * @return pointer to CSigner or NULL on error
 */
CSigner* signer_new_cli(const char* ed25519_key);

/**
 * Sign a transaction
 * @param signer - pointer to CSigner instance
 * @param tx_hex - null-terminated transaction hex string
 * @return pointer to signature string or NULL on error (must be freed with signer_free_string)
 */
char* signer_sign_transaction(CSigner* signer, const char* tx_hex);

/**
 * Get public key as hex string
 * @param signer - pointer to CSigner instance
 * @return pointer to public key string or NULL on error (must be freed with signer_free_string)
 */
char* signer_get_public_key(CSigner* signer);

/**
 * Free a signer instance
 * @param signer - pointer to CSigner instance to free
 */
void signer_free(CSigner* signer);

/**
 * Free a string returned by the library
 * @param s - pointer to string to free
 */
void signer_free_string(char* s);

#ifdef __cplusplus
}
#endif

#endif // SIGNER_H 