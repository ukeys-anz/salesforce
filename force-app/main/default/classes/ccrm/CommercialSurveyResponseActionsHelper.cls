/**
 *
 * @author Nabia Nadir
 * @since 08/2024
 * @description Helper class for commercialSurveyResponseActions
 */

public with sharing class CommercialSurveyResponseActionsHelper {
  private static final string INVALID_OCV_ID_ERROR = 'Provided Customer number could not be found in Salesforce';

  /**
   * @description setSurveyResponseFields set fields on survey response
   * @param custIdWithAccRecordMap map of string
   * @param surveyResponses list of survey response.
   */
  public static void setSurveyResponseFields(
    Map<String, Account> custIdWithAccRecordMap,
    List<qualtrics__Survey_Response__c> surveyResponses
  ) {
    for (qualtrics__Survey_Response__c response : surveyResponses) {
      response.Name =
        response.Survey_Name__c +
        ' - ' +
        response.Survey_Trigger__c;
      response.RecordTypeId = QueryRT.of(
          qualtrics__Survey_Response__c.SObjectType
        )
        .getId('Commercial_A_Z_Review_Survey_Response');
      response.qualtrics__Account__c = custIdWithAccRecordMap
        ?.get(response.customer_number__c)
        .Id;
    }
  }

  /**
   * @description validateSurveyFields validate for errors whether customer number exists in system or not and returns surveyresponse valid for update.
   * @param custNumbers set of string
   * @param surveyResponses list of survey response.
   * @return list of survey response.
   */
  public static List<qualtrics__Survey_Response__c> validateSurveyFields(
    Set<string> custNumbers,
    List<qualtrics__Survey_Response__c> surveyResponses
  ) {
    List<qualtrics__Survey_Response__c> validRecords = new List<qualtrics__Survey_Response__c>();
    for (qualtrics__Survey_Response__c response : surveyResponses) {
      if (!custNumbers.contains(response.customer_number__c)) {
        response.addError(INVALID_OCV_ID_ERROR);
        Logger.info(
          'A-Z Review: ' +
            response.A_Z_Review__c +
            '; Customer Number: ' +
            response.customer_number__c
        );
        continue;
      }
      validRecords.add(response);
    }
    Logger.saveLog();
    return validRecords;
  }
}
