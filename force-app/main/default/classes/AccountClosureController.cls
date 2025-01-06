/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Account Closure Controller for Account Closure Prechecks
 */
public with sharing class AccountClosureController {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Queries all the related cases (child cases) to the parent case having status as Escalated and Substatus as Success
   * @param parentCaseId set of Case Group (Parent Case) Id
   * @return List<Case> List of child cases associated to the parent case.
   */
  @AuraEnabled(cacheable=true)
  public static List<Case> fetchChildCasesForClosure(Id parentCaseId) {
    try {
      Set<Id> parentCaseIds = new Set<Id>();
      parentCaseIds.add(parentCaseId);
      return ACCOUNT_CLOSURE_REPOSITORY.queryChildCasesForClosure(
        parentCaseIds
      );
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }
}
