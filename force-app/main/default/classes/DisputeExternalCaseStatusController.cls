/**
 * @author Tan Phan
 * @since 04/2024
 * @description This class provides methods for LWC to handle Case and related External_Case_Status__c actions
 * @runTests DisputeExternalCaseStatusActionsTest
 */
public with sharing class DisputeExternalCaseStatusController {
  private static final String ERROR_CASE_ASSIGNMENT = 'An error occurred while assigning the case to queue.';

  private static final DisputeExternalCaseStatusRepository DECS_REPOSITORY = (DisputeExternalCaseStatusRepository) Lib_InstanceProvider.forType(
    DisputeExternalCaseStatusRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Assigns a case to the original queue.
   * @param caseId The ID of the case to be assigned.
   */
  @AuraEnabled
  public static void assignCaseToOriginalQueue(Id caseId) {
    List<Case> cases = DECS_REPOSITORY.queryCasesWithLatestStatus(
      new Set<Id>{ caseId }
    );
    cases = DisputeExternalCaseStatusActions.setCaseStatusAndOwner(cases);
    List<Database.SaveResult> saveResults = DML_REPOSITORY.updateRecords(
      cases,
      DmlRepository.ALL_OR_NONE,
      DmlRepository.USER_MODE
    );
    if (saveResults.isEmpty()) {
      throw new AuraHandledException(ERROR_CASE_ASSIGNMENT);
    }
  }
}
