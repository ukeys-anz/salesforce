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
  public List<SObject> retrievePrivateKey(String publicKeyId) {
    SystemModeActions systemAction = new SystemModeActions(
      'KeyServiceRepository',
      'retrievePrivateKey'
    );

    return systemAction.queryWithBinds(
      'Select Private_Key__c From PrivateKeyStorage__c where Public_Key_Id__c = :publicKeyId',
      new Map<String, Object>{ 'publicKeyId' => publicKeyId }
    );
  }
}
