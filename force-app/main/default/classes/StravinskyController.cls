/**
 * @author Paul Boyington
 * @since 2022
 * @description StravinskyController is used to handle calls to Stravinsky Frontdoor
 */
public with sharing class StravinskyController {
  public static final String MISSING_PACKAGE_ID = 'No package id found. Please ensure a package id has been added to the case. Raise a fault through TechAssist if the problem persists.';
  public static final String MISSING_FIN_ACCOUNT = 'Failed to retrieve financial account data. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String FAILED_CLOSURE = 'Failed to perform account closure. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';

  /**
   * @param recordId Case/Record Id (required)
   * @return PackageClosureModel
   * @description stravinsky package closure api
   */
  @AuraEnabled(cacheable=false)
  public static PackageClosureModel getPackageClosureAura(Id recordId) {
    if (
      !PermissionUtils.canQuery('Case') ||
      !PermissionUtils.canQuery('FinServ__FinancialAccount__c')
    ) {
      CommonUtil.logAndThrowIAE(
        'StravinskyController',
        'getPackageClosureAura',
        'Not enough permissions to query required object.'
      );
    }

    Case caseRecord = [
      SELECT Id, AccountId, Account.OCV_Id__c, Package_Id__c
      FROM Case
      WHERE Id = :recordId
    ];

    if (String.isBlank(caseRecord.Package_Id__c)) {
      Logger.error('Error closing package - ' + MISSING_PACKAGE_ID, recordId);
      Logger.saveLog();
      AuraHandledException e = new AuraHandledException(MISSING_PACKAGE_ID);
      e.setMessage(MISSING_PACKAGE_ID);
      throw e;
    }

    List<FinServ__FinancialAccount__c> financialAccounts = [
      SELECT Id, FinServ__FinancialAccountNumber__c, RecordType.DeveloperName
      FROM FinServ__FinancialAccount__c
      WHERE FinServ__PrimaryOwner__c = :caseRecord.AccountId
    ];

    if (financialAccounts.isEmpty()) {
      Logger.error('Error closing package - ' + MISSING_FIN_ACCOUNT, recordId);
      Logger.saveLog();
      AuraHandledException e = new AuraHandledException(MISSING_FIN_ACCOUNT);
      e.setMessage(MISSING_FIN_ACCOUNT);
      throw e;
    }
    String savingsAccountNumber;
    String checkingAccountNumber;

    for (FinServ__FinancialAccount__c finAccount : financialAccounts) {
      if (
        finAccount.RecordType.DeveloperName ==
        GetHelpConstants.SAVINGS_ACCOUNT_RT_APINAME
      ) {
        savingsAccountNumber = finAccount.FinServ__FinancialAccountNumber__c;
      } else if (
        finAccount.RecordType.DeveloperName ==
        GetHelpConstants.CHECKING_ACCOUNT_RT_APINAME
      ) {
        checkingAccountNumber = finAccount.FinServ__FinancialAccountNumber__c;
      }
    }

    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    PackageClosureModel response;

    try {
      response = stravinskyApi.packageClosure(
        caseRecord,
        checkingAccountNumber,
        savingsAccountNumber
      );
    } catch (Exception e) {
      Logger.error('Error closing package', recordId, e);
      Logger.saveLog();
      AuraHandledException ex = new AuraHandledException(FAILED_CLOSURE);
      ex.setMessage(FAILED_CLOSURE);
      throw e;
    }

    return response;
  }
}
