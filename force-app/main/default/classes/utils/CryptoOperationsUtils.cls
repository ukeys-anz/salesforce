/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Class to perform Crypto Operations like encryption, decryption and many more
 */

public with sharing class CryptoOperationsUtils {
    private static final String ENCRYPTION_ALGORITHM = 'AES256';
    private static final VaultServiceRepository VAULT_REPOSITORY = (VaultServiceRepository) Lib_InstanceProvider.forType(
        VaultServiceRepository.class
        );
   /**
   * @param publicKeyId public key from GCP 
   * @param initializationVector IV from GCP used to decrypt
   * @param encryptedData data to be decrypted from GCP
   * @return `String` decrypted data to return
   * @description this method is used to decrypt based on the private key and initialization vector
   */
    public static String decryptDataWithIV(String publicKeyId, String initializationVector, String encryptedData) {
        String privateKey = VAULT_REPOSITORY.retrievePrivateKey(publicKeyId);
        if(String.isBlank(privateKey))
        {
            return '';
        }
        Blob privateKeyBlob =EncodingUtil.base64Decode(privateKey);
        Blob initialisationVectorBlob = Blob.valueOf(initializationVector);
        Blob encryptedDataBlob = EncodingUtil.base64Decode(encryptedData);
  
        Blob decryptedDataBlob = Crypto.decrypt(ENCRYPTION_ALGORITHM, privateKeyBlob, initialisationVectorBlob, encryptedDataBlob);
  
        return decryptedDataBlob.toString();
    }
}