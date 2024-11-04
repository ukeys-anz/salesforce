/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached Profile records
 */
public with sharing class QueryProfile {
  private static Map<String, Profile> profiles = new Map<String, Profile>();
  static {
    for (Profile prof : [SELECT Id, Name FROM Profile WITH SYSTEM_MODE]) {
      profiles.put(prof.Name, prof);
    }
  }

  public static Profile systemAdmin = get('System Administrator');
  public static Profile anzUser = get('ANZ Standard User');
  public static Profile anzxUser = get('ANZx Standard User');
  public static Profile minimumAccessExternalApps = get(
    'Minimum Access - External Apps'
  );
  public static Profile anzCCRMStandardUser = get('ANZ CCRM Standard User');
  public static Profile integrationUser = get('Integration User');
  public static Profile minimumAccessSalesforce = get(
    'Minimum Access - Salesforce'
  );

  /**
   * @description Get Profile by Profile Name
   * @param profileName name of the Profile
   * @return Profile
   */
  public static Profile get(String profileName) {
    return profiles.get(profileName);
  }
}
