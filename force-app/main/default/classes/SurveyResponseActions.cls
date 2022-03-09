/**
 * @author Jasmine Nguyen
 * @since 03/2022
 * @description SurveyResponseActions class is to handle Survey Response related actions
 */

public with sharing class SurveyResponseActions {
  // Invalid UUID Error Message
  @TestVisible
  private static final String INVALID_UUID_ERROR = 'Provided UUID could not be found in Salesforce';

  /**
   * @description beforeInsertActions is called onBeforeInsert. any logic that needs to be executed on before insert is executed from here
   * @param records The Task record list.
   */
  public static void beforeInsertActions(
    List<qualtrics__Survey_Response__c> records
  ) {
    Map<String, qualtrics__Survey_Response__c> uuidToSurveyResponseMap = new Map<String, qualtrics__Survey_Response__c>();
    Set<String> uuidSet = new Set<String>();
    for (qualtrics__Survey_Response__c sr : records) {
      if (String.isNotBlank(sr.UUID__c)) {
        uuidToSurveyResponseMap.put(sr.UUID__c, sr);
        uuidSet.add(sr.UUID__c);
      }
    }

    if (
      uuidSet.size() > 0 &&
      Account.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.Account.fields.UUID__c.isAccessible()
    ) {
      Map<String, String> uuidToAccountIdMap = new Map<String, String>();
      for (Account acc : [
        SELECT Id, UUID__c
        FROM Account
        WHERE UUID__c IN :uuidSet
      ]) {
        uuidToAccountIdMap.put(acc.UUID__c, acc.Id);
      }

      for (String uuid : uuidToSurveyResponseMap.keySet()) {
        if (String.isNotBlank(uuidToAccountIdMap.get(uuid))) {
          uuidToSurveyResponseMap.get(uuid)
            .qualtrics__Account__c = uuidToAccountIdMap.get(uuid);
        } else {
          uuidToSurveyResponseMap.get(uuid).addError(INVALID_UUID_ERROR);
        }
      }
    }
  }
}
