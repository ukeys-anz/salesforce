/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Class to perform Crypto Operations like encryption, decryption and many more
 */

public with sharing class CryptoOperationsUtils {
  private static final String ENCRYPTION_ALGORITHM = 'AES256';
  private static final KeyServiceRepository PRIVATE_KEY_REPOSITORY = (KeyServiceRepository) Lib_InstanceProvider.forType(
    KeyServiceRepository.class
  );
  private static final String NO_PRIVATE_KEY_FOUND_ERROR = 'No Private Key Found With Provided Public Key Id';
  /**
   * @param publicKeyId public key from GCP
   * @param initializationVector IV from GCP used to decrypt
   * @param encryptedData data to be decrypted from GCP
   * @return `String` decrypted data to return
   * @description this method is used to decrypt based on the private key and initialization vector
   */
  public static String decryptDataWithIV(
    String publicKeyId,
    String initializationVector,
    String encryptedData
  ) {
    List<PrivateKeyStorage__c> privateKeyList = PRIVATE_KEY_REPOSITORY.retrievePrivateKey(
      publicKeyId
    );
    if (privateKeyList.isEmpty()) {
      throw CommonUtil.logException(
        new VaultApiRepository.NoPrivateKeyFoundException(
          NO_PRIVATE_KEY_FOUND_ERROR
        )
      );
    }
    Blob privateKeyBlob = Blob.valueOf(
      privateKeyList[0].Private_Key__c
    );
    Blob initialisationVectorBlob = EncodingUtil.convertFromHex(initializationVector);
    Blob encryptedDataBlob = EncodingUtil.convertFromHex(encryptedData);

    Blob decryptedDataBlob = Crypto.decrypt(
      ENCRYPTION_ALGORITHM,
      privateKeyBlob,
      initialisationVectorBlob,
      encryptedDataBlob
    );

    return decryptedDataBlob.toString();
  }
}
