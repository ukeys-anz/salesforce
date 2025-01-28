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
    try {
      return ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCasesForPrecheck(
        new Set<Id>{ parentCaseId }
      );
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description Initiate Account Closure Prechecks by making callout to Fabric Seal and perform after actions based on response for each case
   * @param parentCaseId Parent Case Id for which Precheck Initiated
   * @param eligibleCasesForPrecheck Cases to be sent to Fabric Seal for Precheck
   * @return List<AccountClosurePrecheckResponseModel> fabric seal response for each case
   */
  @AuraEnabled
  public static List<AccountClosurePrecheckResponseModel> initiateAccountClosurePrechecks(
    Id parentCaseId,
    List<Case> eligibleCasesForPrecheck
  ) {
    try {
      Case parentCaseRecord = ACCOUNT_CLOSURE_REPOSITORY.queryCaseDetails(
        parentCaseId
      );

      AccountClosureApiRepository accountClosurePrecheckApi = new AccountClosureApiRepository();

      return accountClosurePrecheckApi.initiateAccountClosurePreChecks(
        parentCaseRecord.Account.OCV_ID__c,
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

      Map<String, String> successCases = new Map<String, String>();
      Map<String, Set<String>> failedCases = new Map<String, Set<String>>();

      AccountClosureControllerHelper.segregrateCasesByResponseStatus(
        successCases,
        failedCases,
        accountClosurePrecheckResponse
      );

      if (successCases.isEmpty() && failedCases.isEmpty()) {
        return new List<Case>();
      }

      Map<String, Id> caseNumberToIdMap = AccountClosureControllerHelper.createCaseNumberToIdMap(
        eligibleCasesForPrecheck
      );

      List<Case> casesToUpdate = AccountClosureControllerHelper.prepareCasesForUpdate(
        successCases,
        failedCases,
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
    try {
      return ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCasesForClosure(
        new Set<Id>{ parentCaseId }
      );
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }
}
