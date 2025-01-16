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
  private static final String NO_ELIGIBLE_CASES_FOUND = 'No Eligible Cases Found';
  /**
   * @description Fetch Eligible Cases for Fabric Seal Precheck
   * @param parentCaseId Input Date from LWC
   * @return List<Case> eligible case list
   */
  @AuraEnabled(cacheable=true)
  public static List<Case> fetchEligibleCasesForPrecheck(Id parentCaseId) {
    try {
      List<Case> eligibleCases =  ACCOUNT_CLOSURE_REPOSITORY.queryEligibleChildCaseRecords(
        new Set<Id>{ parentCaseId }
      );
      if(eligibleCases.isEmpty())
      {
          throw CommonUtil.logException(
          new AccountClosureApiRepository.NoEligibleCasesFoundException(
            NO_ELIGIBLE_CASES_FOUND
          )
        );
      }
      return eligibleCases;
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description Initiate Account Closure Prechecks by making callout to Fabric Seal and perform after actions based on response for each case
   * @param parentCaseId Parent Case Id for which Precheck Initiated
   * @param eligibleCasesForPrecheck Cases to be sent to Fabric Seal for Precheck
   * @return List<FabricSealResponseModel> fabric seal response for each case
   */
  @AuraEnabled
  public static List<FabricSealResponseModel> initiateAccountClosurePrecheck(
    Id parentCaseId,
    List<Case> eligibleCasesForPrecheck
  ) {
    try {
      
      Case parentCaseRecord = ACCOUNT_CLOSURE_REPOSITORY.queryCaseDetails(
        parentCaseId
        );

      AccountClosureApiRepository fabricSealApi = new AccountClosureApiRepository();
      return fabricSealApi.initiateAccountClosurePreChecks(
        parentCaseRecord.Account.OCV_ID__c,
        eligibleCasesForPrecheck
      );

    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description method to process response and segregrate success and failure cases and update
   * @param fabricSealResponseList response received from fabric seal api
   * @param eligibleCasesForPrecheck eligibleCasesForPrecheck
   * @return List<Case> list of cases updated successfully
   */
  @AuraEnabled
  public static List<Case> processResponsesAndUpdateCases(List<Object> fabricSealResponseList,
  List<Case> eligibleCasesForPrecheck) {
    try
    {
      return AccountClosureControllerHelper.processResponsesAndUpdateCases(
        fabricSealResponseList,
        eligibleCasesForPrecheck
      );
    }
    catch (Exception objException) {
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
      return ACCOUNT_CLOSURE_REPOSITORY.queryChildCasesForClosure(
        new Set<Id>{ parentCaseId }
      );
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }
}