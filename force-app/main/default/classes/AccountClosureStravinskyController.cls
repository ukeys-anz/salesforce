/**
 * @author Kopal Goswami
 * @since 2024
 * @description AccountClosureStravinskyController is used to handle calls to Stravinsky for closing accounts and package
 */
public with sharing class AccountClosureStravinskyController {
  public static final String FAILED_CLOSURE = 'Failed to perform account closure. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';

  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description This method send the parameteres for forming Stravinsky request.
   *              Calls Stravinsky Api for closing the Account / Package
   * @param recordId Holds Id of Child Account closure account requested for closure
   * @return stravinsky api response in GenesisPackageClosureModel form
   */
  @AuraEnabled(cacheable=true)
  public static GenesisPackageClosureModel getPackageClosureAura(Id recordId) {
    Set<String> setOfAccountNumberToBeClosed = new Set<String>();
    List<String> customerOcvIdsList = new List<String>();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    GenesisPackageClosureModel response;

    PermissionUtils.canQuery('Case');
    try {
      Case caseRecord = ACCOUNT_CLOSURE_REPOSITORY.queryCaseDetails(recordId);

      setOfAccountNumberToBeClosed.add(
        'accounts/' +
        caseRecord.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      );

      customerOcvIdsList.add(caseRecord.Account.OCV_ID__c);

      response = stravinskyApi.packageClosure(
        caseRecord,
        setOfAccountNumberToBeClosed,
        customerOcvIdsList
      );
    } catch (Exception e) {
      Logger.error('Error to perform account closure', recordId, e);
      Logger.saveLog();
      AuraHandledException ex = new AuraHandledException(FAILED_CLOSURE);
      ex.setMessage(FAILED_CLOSURE);
      throw e;
    }
    return response;
  }
  /**
   * @description This method close the case records if the accounts are succesfully closed
   * @param records The Id of the cases for which Staus should be updated to Closed
   */
  @AuraEnabled
  public static void updateCaseStatus(List<Id> records) {
    try {
      Set<Id> caseIds = new Set<Id>(records);
      if (caseIds == null || caseIds.isEmpty()) {
        return;
      }
      List<Case> caseRecords = ACCOUNT_CLOSURE_REPOSITORY.queryCaseToUpdateStatusAsClosed(
        caseIds
      );
      List<Case> caseRecordsToBeUpdated = setStatusToClosed(caseRecords);
      DML_REPOSITORY.doUpdate(caseRecordsToBeUpdated);
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  @TestVisible
  private static List<Case> setStatusToClosed(List<Case> caseRecords) {
    List<Case> caseRecordsToBeUpdated = new List<Case>();
    for (Case caseRecord : caseRecords) {
      caseRecord.Status = 'Closed';
      caseRecordsToBeUpdated.add(caseRecord);
    }

    return caseRecordsToBeUpdated;
  }
}
