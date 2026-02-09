/**
 * @author Sanskriti
 * @since May 2025
 * @description Contains query for ForgeRock metadata
 */
public with sharing class QueryForgeRockAuth {
  @testVisible
  private static Map<String, Forgerock_Auth__mdt> configByName = new Map<String, Forgerock_Auth__mdt>();
  static {
    for (Forgerock_Auth__mdt config : [
      SELECT
        Encrypted_forge_client_id__c,
        Encrypted_forge_client_secret__c,
        RequestedScopes__c,
        Forgev2_subject_token_type__c,
        CacheStaffToken__c,
        developername,
        Audience__c,
        IsJWEToken__c
      FROM Forgerock_Auth__mdt
      WITH SYSTEM_MODE
    ]) {
      configByName.put(config.developerName, config);
    }
  }

  /**
   * @description Returns metadata records by requested metadata name.
   * @param requestedName developername of Forgerock_Auth__mdt record
   * @return metadata record of the requested name.
   */
  public static Forgerock_Auth__mdt getByDevName(String requestedName) {
    return configByName.get(requestedName);
  }
}
