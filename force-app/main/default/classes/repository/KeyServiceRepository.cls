/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Provides DML and Queries helpers for VaultService class
 */
public with sharing class KeyServiceRepository {
  /**
   * @description Returns the private key stored in Salesforce based on the public key received
   * @param publicKeyId public key received from GCP
   * @return String | The Private Key stored in Salesforce based on the public key
   */
  public List<PrivateKeyStorage__c> retrievePrivateKey(String publicKeyId) {
    if (String.isBlank(publicKeyId)) {
      return new List<PrivateKeyStorage__c>();
    }
    SystemModeActions systemAction = new SystemModeActions(
      'KeyServiceRepository',
      'retrievePrivateKey'
    );

    return (List<PrivateKeyStorage__c>) systemAction.queryWithBinds(
      'Select Private_Key__c From PrivateKeyStorage__c where Public_Key_Id__c = :publicKeyId',
      new Map<String, Object>{ 'publicKeyId' => publicKeyId }
    );
  }
}
