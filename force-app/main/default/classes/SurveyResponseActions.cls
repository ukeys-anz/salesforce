/**
 * @author Jasmine Nguyen
 * @since 03/2022
 * @description SurveyResponseActions class is to handle Survey Response related actions
 */

public with sharing class SurveyResponseActions {
  // Invalid ocvid Error Message
  @TestVisible
  private static final String INVALID_OCV_ID_ERROR = 'Provided OCV ID could not be found in Salesforce';

  /**
   * @description beforeInsertActions is called onBeforeInsert. any logic that needs to be executed on before insert is executed from here
   * @param records The Task record list.
   */
  public static void beforeInsertActions(
    List<qualtrics__Survey_Response__c> records
  ) {
    Map<String, qualtrics__Survey_Response__c> ocvIdToSurveyResponseMap = new Map<String, qualtrics__Survey_Response__c>();
    Set<String> ocvIdSet = new Set<String>();
    for (qualtrics__Survey_Response__c sr : records) {
      if (String.isNotBlank(sr.OCV_ID__c)) {
        ocvIdToSurveyResponseMap.put(sr.OCV_ID__c, sr);
        ocvIdSet.add(sr.OCV_ID__c);
      }
    }

    if (
      ocvIdSet.size() > 0 &&
      Account.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.Account.fields.OCV_ID__c.isAccessible()
    ) {
      Map<String, String> ocvIdToAccountIdMap = new Map<String, String>();
      for (Account acc : [
        SELECT Id, OCV_ID__c
        FROM Account
        WHERE OCV_ID__c IN :ocvidSet
      ]) {
        ocvIdToAccountIdMap.put(acc.OCV_ID__c, acc.Id);
      }

      for (String ocvId : ocvIdToSurveyResponseMap.keySet()) {
        if (String.isNotBlank(ocvIdToAccountIdMap.get(ocvId))) {
          ocvIdToSurveyResponseMap.get(ocvid)
            .qualtrics__Account__c = ocvIdToAccountIdMap.get(ocvId);
        } else {
          ocvIdToSurveyResponseMap.get(ocvid).addError(INVALID_OCV_ID_ERROR);
        }
      }
    }
  }
}
