/**
 * @author Nabia Nadir
 * @since 08/2024
 * @description  CommercialSurveyResponseActions is the orchestrator class for commercial Survey Response Trigger handler.
 */
public with sharing class CommercialSurveyResponseActions {
  private static final String SOURCE_SYSTEM_NAME = 'CAP-CIS';

  private static final CommercialSurveyResponseActionsRepo SR_REPOSITORY = (CommercialSurveyResponseActionsRepo) Lib_InstanceProvider.forType(
    CommercialSurveyResponseActionsRepo.class
  );
  /**
   * @description setFieldsForSurveyResponseOnInsert to set fields of survey response
   * @param surveyResponses The Survey Response record list.
   */
  public static void setFieldsForSurveyResponseOnInsert(
    List<qualtrics__Survey_Response__c> surveyResponses
  ) {
    Set<String> custNumbers = ListUtil.getStrings(
      surveyResponses,
      qualtrics__Survey_Response__c.customer_number__c
    );
    List<Account> filteredAccList = SR_REPOSITORY.filterAccounts(
      custNumbers,
      SOURCE_SYSTEM_NAME
    );
    Map<String, Account> custNumWithAccRecordMap = (Map<String, Account>) ListUtil.mapBy(
      filteredAccList,
      Account.Source_System_ID__c
    );
    List<qualtrics__Survey_Response__c> validRecords = CommercialSurveyResponseActionsHelper.validateSurveyFields(
      custNumWithAccRecordMap.keySet(),
      surveyResponses
    );
    CommercialSurveyResponseActionsHelper.setSurveyResponseFields(
      custNumWithAccRecordMap,
      validRecords
    );
  }
}
