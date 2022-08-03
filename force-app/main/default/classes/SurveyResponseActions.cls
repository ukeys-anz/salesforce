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
   * @param records The Survey Response record list.
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
        WHERE OCV_ID__c IN :ocvidSet AND ANZx_Customer__c = TRUE
      ]) {
        ocvIdToAccountIdMap.put(acc.OCV_ID__c, acc.Id);
      }
      mapSurveyResToAccount(ocvIdToSurveyResponseMap, ocvIdToAccountIdMap);
    }
  }

  /**
   * @description mapSurveyResToAccount maps Survey Responses to Accounts using OCV ID
   * @param ocvIdToSurveyResponseMap  A map of OCV ID's to Survey Responses
   * @param ocvIdToAccountIdMap A map of OCV ID's to Accounts
   */
  public static void mapSurveyResToAccount(
    Map<String, qualtrics__Survey_Response__c> ocvIdToSurveyResponseMap,
    Map<String, String> ocvIdToAccountIdMap
  ) {
    for (String ocvId : ocvIdToSurveyResponseMap.keySet()) {
      qualtrics__Survey_Response__c sr = ocvIdToSurveyResponseMap.get(ocvid);
      if (String.isNotBlank(ocvIdToAccountIdMap.get(ocvId))) {
        sr.qualtrics__Account__c = ocvIdToAccountIdMap.get(ocvId);
      } else {
        sr.addError(INVALID_OCV_ID_ERROR);
        lib_systemLog log = new lib_systemLog(
          'SurveyResponseActions',
          'beforeInsertActions'
        );
        log.info(
          'OCV ID: ' +
          ocvId +
          '; Q_SurveyID: ' +
          sr.qualtrics__Q_SurveyID__c +
          '; Q_Recipient ID: ' +
          sr.qualtrics__Q_Recipient_ID__c
        );
        log.publishEvent();
      }
    }
  }

  /**
   * @description createCaseForSurveyResponse creates cases for Survey Responses which have Create_Case__c == true
   * @param records The Survey Response record list.
   */
  public static void createCaseForSurveyResponse(
    List<qualtrics__Survey_Response__c> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    List<Case> casesToCreate = new List<Case>();
    List<qualtrics__Survey_Response__c> responsesRequireCase = new List<qualtrics__Survey_Response__c>();
    for (qualtrics__Survey_Response__c record : records) {
      if (record.Create_Case__c) {
        accountIds.add(record.qualtrics__Account__c);
        responsesRequireCase.add(record);
      }
    }

    if (accountIds.size() > 0 && responsesRequireCase.size() > 0) {
      Map<Id, Account> accountsMap = new Map<Id, Account>(
        [SELECT Id, PersonContactId FROM Account WHERE Id IN :accountIds]
      );

      casesToCreate = SurveyResponseActionsHelper.buildCaseList(
        accountsMap,
        responsesRequireCase
      );

      List<Database.SaveResult> results = Database.Insert(casesToCreate, false);
      lib_systemLog log = new lib_systemLog(
        'SurveyResponseActions',
        'createCaseForSurveyResponse'
      );
      log.addDatabaseSaveResult('Case', results, new List<Case>());
      log.insertLog();
    }
  }

  /**
   * @description setSurveyReponseName to set the subject to the Survey Name with Survey Trigger if present
   * @param surveyResponses The Survey Response record list.
   */
  public static void setSurveyResponseName(
    List<qualtrics__Survey_Response__c> surveyResponses
  ) {
    for (qualtrics__Survey_Response__c response : surveyResponses) {
      if (String.isNotBlank(response.Survey_Trigger__c)) {
        response.Name =
          response.Survey_Name__c +
          ' - ' +
          response.Survey_Trigger__c;
      } else {
        response.Name = response.Survey_Name__c;
      }
    }
  }
}
