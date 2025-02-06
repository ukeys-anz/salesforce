/**
 * @author Kopal Goswami
 * @since 2024
 * @description AccountClosureStravinskyController is used to handle calls to Stravinsky for closing accounts and package
 */
public with sharing class AccountClosureStravinskyController {
  public static final String FAILED_CLOSURE = 'Failed to perform account closure. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String SUCCESS_CLOSURE = 'Account closed - ACCOUNT NOT ACTIVE';

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
    if (recordId == null) {
      return null;
    }

    try {
      Set<String> ocvIds = new Set<String>();
      Case caseRecord = ACCOUNT_CLOSURE_REPOSITORY.queryCaseDetails(recordId);

      Set<String> accountNumbersToBeClosed = new Set<String>{
        'accounts/' +
        caseRecord.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      };

      List<String> customerOCVIds = new List<String>{
        caseRecord.Account.OCV_ID__c
      };
      for (
        FinServ__FinancialAccountRole__c finAccountRole : ACCOUNT_CLOSURE_REPOSITORY.queryFinancialAccountRoles(
          caseRecord.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
        )
      ) {
        ocvIds.add(finAccountRole.FinServ__RelatedAccount__r.OCV_ID__c);
      }

      List<String> customerOCVIds = new List<String>(ocvIds);

      StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();

      return stravinskyApi.packageClosure(
        caseRecord,
        accountNumbersToBeClosed,
        customerOCVIds
      );
    } catch (Exception e) {
      Logger.error('Error to perform account closure', recordId, e);
      Logger.saveLog();
      AuraHandledException ex = new AuraHandledException(FAILED_CLOSURE);
      ex.setMessage(FAILED_CLOSURE);
      throw e;
    }
  }
  /**
   * @description This method close the case records if the accounts are succesfully closed
   * @param records The Id of the cases for which Staus should be updated to Closed
   */

  @AuraEnabled
  public static void updateCaseStatusAndPostChatterMessage(List<Id> records) {
    try {
      if (records == null || records.isEmpty()) {
        return;
      }

      List<Case> caseRecords = ACCOUNT_CLOSURE_REPOSITORY.queryCaseToUpdateStatusAsClosed(
        new Set<Id>(records)
      );

      for (Case caseRecord : caseRecords) {
        caseRecord.Status = GetHelpConstants.CLOSED_STATUS;
      }

      List<Database.SaveResult> results = DML_REPOSITORY.doUpdate(
        caseRecords,
        new DmlConfig().allowPartial()
      );

      postChatterMessage(results);
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  @TestVisible
  private static void postChatterMessage(List<Database.SaveResult> results) {
    for (Database.SaveResult result : results) {
      if (result.isSuccess()) {
        ConnectApiHelper.postFeedItemWithRichText(
          null,
          result.getId(),
          SUCCESS_CLOSURE
        );
      }
    }
  }
}
