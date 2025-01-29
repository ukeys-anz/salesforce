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
   * @description Fetch Eligible Cases for Fabric Seal Precheck
   * @param parentCaseId Input Date from LWC
   * @return List<Case> eligible case list
   */
  @AuraEnabled(cacheable=true)
  public static List<Case> fetchEligibleCasesForPrecheck(Id parentCaseId) {
    return ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCasesForPrecheck(
      new Set<Id>{ parentCaseId }
    );
  }

  /**
   * @description Initiate Account Closure Prechecks by making callout to Fabric Seal and perform after actions based on response for each case
   * @param customerOcvId customerOcvId from Parent Case for which Precheck Initiated
   * @param eligibleCasesForPrecheck Cases to be sent to Fabric Seal for Precheck
   * @return List<AccountClosurePrecheckResponseModel> fabric seal response for each case
   */
  @AuraEnabled
  public static List<AccountClosurePrecheckResponseModel> initiateAccountClosurePrechecks(
    String customerOcvId,
    List<Case> eligibleCasesForPrecheck
  ) {
    try {
      AccountClosureApiRepository accountClosurePrecheckApi = new AccountClosureApiRepository();

      return accountClosurePrecheckApi.initiateAccountClosurePreChecks(
        customerOcvId,
        eligibleCasesForPrecheck
      );
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description method to process response and segregrate success and failure cases and update
   * @param accountClosurePrecheckResponse response received from fabric seal api
   * @param eligibleCasesForPrecheck eligibleCasesForPrecheck
   * @return List<Case> list of cases updated successfully
   */
  @AuraEnabled
  public static List<Case> processResponsesAndUpdateCases(
    List<CaseInputWrapper> accountClosurePrecheckResponse,
    List<Case> eligibleCasesForPrecheck
  ) {
    try {
      if (
        accountClosurePrecheckResponse == null ||
        eligibleCasesForPrecheck == null
      ) {
        return new List<Case>();
      }

      Map<String, Case> caseNumberToIdMap = (Map<String, Case>) ListUtil.mapBy(
        eligibleCasesForPrecheck,
        Case.CaseNumber
      );

      List<Case> casesToUpdate = AccountClosureControllerHelper.prepareCasesForUpdate(
        accountClosurePrecheckResponse,
        caseNumberToIdMap
      );

      DML_REPOSITORY.doUpdate(casesToUpdate, new DmlConfig().allowPartial());

      return ACCOUNT_CLOSURE_REPOSITORY.queryChildCasesDetailsPostPrecheck(
        new Map<Id, Case>(casesToUpdate)
      );
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description Queries all the related cases (child cases) to the parent case having status as Escalated and Substatus as Success
   * @param parentCaseId set of Case Group (Parent Case) Id
   * @return List<Case> List of child cases associated to the parent case.
   */
  @AuraEnabled(cacheable=true)
  public static List<Case> fetchChildCasesForClosure(Id parentCaseId) {
    return ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCasesForClosure(
      new Set<Id>{ parentCaseId }
    );
  }
}
