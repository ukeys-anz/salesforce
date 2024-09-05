/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Provides DML and Queries helpers for VaultService class
 */
public with sharing class VaultServiceRepository {
    
     /**
   * @description Returns the private key stored in Salesforce based on the public key received
   * @param publicKeyId public key received from GCP
   * @return String | The Private Key stored in Salesforce based on the public key
   */
  public String retrievePrivateKey(String publicKeyId) {
      SystemModeActions systemAction = new SystemModeActions(
      'VaultServiceRepository',
      'retrievePrivateKey'
      );

      List<PrivateKeyStorage__c> privateKeyStorage = systemAction.query('Select Private_Key__c From PrivateKeyStorage__c where Public_Key_Id__c = \'' +
      publicKeyId +
      '\' LIMIT 1'
      );

      if (privateKeyStorage.isEmpty()) {
        return null;
      }
  
      return privateKeyStorage[0].Private_Key__c;
  }
}