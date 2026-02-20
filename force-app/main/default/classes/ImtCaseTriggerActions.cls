/**
 * @author Vaibhav.Joshi
 * @since  11/2025
 * @description IMT Case Trigger Actions class containing static methods to be called from ImtDisputesCaseTriggerHandler
 */
public with sharing class ImtCaseTriggerActions {
  public static final Map<String, String> PREFIX_MAP = new Map<String, String>{
    'Suspected fraud' => 'Payment Recall ',
    'Cancel transfer' => 'Payment Recall ',
    'Payee has not received funds' => 'Beneficiary Claims Non Receipt '
  };
  public static final Set<String> PREFIXES = new Set<String>(
    PREFIX_MAP.values()
  );

  /**
   * @description Update Case description to add a prefix value based on Reason code beforeInsert and beforeUpdate
   * @param records List of Case records from Trigger.new
   */
  public static void updateDescription(List<Case> records) {
    for (Case c : records) {
      if (String.isEmpty(c.Description)) {
        continue;
      }
      String rawDescription = removePrefix(c.Description);
      String newPrefix = PREFIX_MAP.get(c.Dispute_Reason__c) ?? '';
      c.Description = newPrefix + rawDescription;
    }
  }

  /**
   * @description removes prefix on description if any
   * @param inputDescription existing case description
   * @return String description without prefix
   */
  public static String removePrefix(String inputDescription) {
    for (String prefix : PREFIXES) {
      if (inputDescription.startsWith(prefix)) {
        return inputDescription.substring(prefix.length());
      }
    }
    return inputDescription;
  }
}
