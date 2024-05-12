/**
 * @author Tan Phan
 * @since 04/2024
 * @description This class provides methods for LWC to handle Case and related External_Case_Status__c actions
 * @runTests DisputeExternalCaseStatusActionsTest
 */
public with sharing class DisputeExternalCaseStatusController {
  private static final String ERROR_CASE_ASSIGNMENT = 'An error occurred while assigning the case to queue.';

  /**
   * @description Assigns a case to the original queue.
   * @param caseId The ID of the case to be assigned.
   */
  @AuraEnabled
  public static void assignCaseToOriginalQueue(Id caseId) {
    Case theCase = DisputeExternalCaseStatusActions.queryCasesWithLatestStatus(
      new Set<Id>{ caseId }
    )[0];
    theCase = DisputeExternalCaseStatusActions.setCaseStatusAndOwner(theCase);
    if (theCase == null) {
      throw new AuraHandledException(ERROR_CASE_ASSIGNMENT);
    }
    try {
      update as user theCase;
    } catch (Exception ex) {
      Logger.error(ERROR_CASE_ASSIGNMENT, ex);
      Logger.saveLog();

      throw new AuraHandledException(ERROR_CASE_ASSIGNMENT);
    }
  }
}
