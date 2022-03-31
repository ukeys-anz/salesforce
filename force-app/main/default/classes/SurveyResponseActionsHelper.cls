/**
 *
 * @author Jasmine Nguyen
 * @since 03/2022
 * @description Helper class for @link SurveyResponseActions
 */

public with sharing class SurveyResponseActionsHelper {
  @testVisible
  private static Group coachQueue = CommonUtil.getQueueByName(
    GetHelpConstants.COACH_QUEUE
  );
  public static String feedbackType = 'Survey';

  /**
   * @description Build a case record with information from a survey response record
   * @param surveyResponse The survey response record of which the data is used to build the case
   * @param personContactId The account's contact Id
   * @return Case The case record that is built from the survey response's data
   */
  private static Case buildCaseFromSurveyResponse(
    qualtrics__Survey_Response__c surveyResponse,
    String personContactId
  ) {
    Case newCase = new Case();
    newCase.AccountId = surveyResponse.qualtrics__Account__c;
    newCase.Advocacy_Score__c = surveyResponse.qualtrics__Net_Promoter_Score__c;
    newCase.Alerting_Reason__c = surveyResponse.Alerting_Reason__c;
    newCase.ContactId = personContactId;
    newCase.Description = surveyResponse.Customer_Feedback__c;
    newCase.OwnerId = coachQueue.Id;
    newCase.Priority = 'Medium';
    newCase.RecordTypeId = GetHelpConstants.CUSTOMER_FEEDBACK_RT_ID;
    newCase.Subject = surveyResponse.Alerting_Reason__c + ' - ' + feedbackType;
    newCase.Survey_Response__c = surveyResponse.Id;

    return newCase;
  }

  /**
   * @description Build a list of case records with information from survey responses and an account map
   * @param accountsMap A map of accounts and their Ids
   * @param responsesRequireCase A list of survey responses that require cases
   * @return List<Case> List of cases to insert
   */
  public static List<Case> buildCaseList(
    Map<Id, Account> accountsMap,
    List<qualtrics__Survey_Response__c> responsesRequireCase
  ) {
    List<Case> casesToCreate = new List<Case>();
    for (qualtrics__Survey_Response__c record : responsesRequireCase) {
      Case newCase = buildCaseFromSurveyResponse(
        record,
        accountsMap.get(record.qualtrics__Account__c)?.PersonContactId
      );
      casesToCreate.add(newCase);
    }
    return casesToCreate;
  }
}
