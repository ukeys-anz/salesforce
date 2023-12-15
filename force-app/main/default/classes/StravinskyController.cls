/**
 * @author Paul Boyington
 * @since 2022
 * @description StravinskyController is used to handle calls to Stravinsky Frontdoor
 */
public with sharing class StravinskyController {
  public static final String MISSING_PACKAGE_ID = 'No package id found. Please ensure a package id has been added to the case. Raise a fault through TechAssist if the problem persists.';
  public static final String MISSING_FIN_ACCOUNT = 'Failed to retrieve financial account data. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  public static final String FAILED_CLOSURE = 'Failed to perform account closure. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  //Added this error message if more than one joint account found
  public static final String MORE_THAN_ONE_JOINT_ACCOUNT = System.Label.MoreThanOneJointAccountFoundError;

  /**
   * @param recordId Case/Record Id (required)
   * @return PackageClosureModel
   * @description stravinsky package closure api
   */
  @AuraEnabled(cacheable=false)
  public static PackageClosureModel getPackageClosureAura(Id recordId) {
    List<String> customerOcvIdsList = new List<String>();
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    //Converting this into List of Account Numbers
    List<String> checkingAccountNumbers = new List<String>();
    List<String> savingsAccountNumbers = new List<String>();

    if (
      !PermissionUtils.canQuery('Case') ||
      !PermissionUtils.canQuery('FinServ__FinancialAccount__c') ||
      !PermissionUtils.canQuery('FinServ__FinancialAccountRole__c')
    ) {
      CommonUtil.logAndThrowIAE(
        'StravinskyController',
        'getPackageClosureAura',
        'Not enough permissions to query required object.'
      );
    }

    Case caseRecord = [
      SELECT Id, AccountId, Account_Type__c, Account.OCV_Id__c, Package_Id__c
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

    //Added to Fetch Financial Accounts Details based on the Case Record Account Type
    financialAccounts = checkAccountTypeAndReturnFinancialAccounts(
      caseRecord,
      customerOcvIdsList
    );

    if (financialAccounts.isEmpty()) {
      Logger.error('Error closing package - ' + MISSING_FIN_ACCOUNT, recordId);
      Logger.saveLog();
      AuraHandledException e = new AuraHandledException(MISSING_FIN_ACCOUNT);
      e.setMessage(MISSING_FIN_ACCOUNT);
      throw e;
    }

    for (FinServ__FinancialAccount__c finAccount : financialAccounts) {
      //This is added in order to resolve duplication and run only when Individual Account Type present
      if (
        finAccount.OCV_ID__c != null &&
        !customerOcvIdsList.contains(finAccount.OCV_ID__c)
      ) {
        customerOcvIdsList.add(finAccount.OCV_ID__c);
      }
      if (
        finAccount.RecordType.DeveloperName ==
        GetHelpConstants.SAVINGS_ACCOUNT_RT_APINAME &&
        !savingsAccountNumbers.contains(
          finAccount.FinServ__FinancialAccountNumber__c
        )
      ) {
        savingsAccountNumbers.add(
          finAccount.FinServ__FinancialAccountNumber__c
        );
      } else if (
        finAccount.RecordType.DeveloperName ==
        GetHelpConstants.CHECKING_ACCOUNT_RT_APINAME &&
        !checkingAccountNumbers.contains(
          finAccount.FinServ__FinancialAccountNumber__c
        )
      ) {
        checkingAccountNumbers.add(
          finAccount.FinServ__FinancialAccountNumber__c
        );
      }
    }

    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    PackageClosureModel response;

    try {
      //Adding list of OCV Ids to be sent to Mule
      response = stravinskyApi.packageClosure(
        caseRecord,
        checkingAccountNumbers,
        savingsAccountNumbers,
        customerOcvIdsList
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

  /**
   * @description this method is used to fetch List of Financial Joint Accounts based on the Account_Type__c of the Case Record
   * @param caseRecord case record which is raised by Coach
   * @param customerOcvIdsList used as pass by reference for storing ocvids of the customers
   * @return List<FinServ__FinancialAccount__c>
   */
  private static List<FinServ__FinancialAccount__c> checkAccountTypeAndReturnFinancialAccounts(
    Case caseRecord,
    List<String> customerOcvIdsList
  ) {
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    List<FinServ__FinancialAccountRole__c> financialAccountsRole = new List<FinServ__FinancialAccountRole__c>();

    //Added AccountType check in order to segregate the Individual and Joint Scenario.
    switch on caseRecord.Account_Type__c {
      when 'Individual' {
        financialAccounts = [
          SELECT
            Id,
            FinServ__FinancialAccountNumber__c,
            Ownership__c,
            OCV_ID__c,
            RecordType.DeveloperName
          FROM FinServ__FinancialAccount__c
          WHERE
            FinServ__PrimaryOwner__c = :caseRecord.AccountId
            AND Ownership__c = :GetHelpConstants.SINGLE
            AND FinServ__Status__c != :GetHelpConstants.CLOSED_STATUS
        ];
      }
      when 'Joint' {
        financialAccountsRole = [
          SELECT FinServ__FinancialAccount__c, FinServ__RelatedAccount__c
          FROM FinServ__FinancialAccountRole__c
          WHERE
            FinServ__RelatedAccount__r.OCV_ID__c = :caseRecord.Account.OCV_Id__c
            AND FinServ__Active__c = TRUE
            AND FinServ__FinancialAccount__r.Ownership__c = :GetHelpConstants.MULTI_PARTY
            AND FinServ__FinancialAccount__r.FinServ__Status__c != :GetHelpConstants.CLOSED_STATUS
            AND (FinServ__FinancialAccount__r.RecordType.DeveloperName = :GetHelpConstants.SAVINGS_ACCOUNT_RT_APINAME
            OR FinServ__FinancialAccount__r.RecordType.DeveloperName = :GetHelpConstants.CHECKING_ACCOUNT_RT_APINAME)
        ];

        //Added to throw exception if more than 1 Joint Account(One Savings and One Transactions) found. A Joint Account will always have one Savings and one Transactions financial account at Salesforce end.
        if (financialAccountsRole.size() > 2) {
          Logger.error(
            'Error closing package - ' + MORE_THAN_ONE_JOINT_ACCOUNT,
            caseRecord.Id
          );
          Logger.saveLog();
          AuraHandledException e = new AuraHandledException(
            MORE_THAN_ONE_JOINT_ACCOUNT
          );
          e.setMessage(MORE_THAN_ONE_JOINT_ACCOUNT);
          throw e;
        } else {
          //Creating List Of Financial Accounts based on Financial Account Roles found
          financialAccounts = getJointFinancialAccountsDetails(
            financialAccountsRole,
            customerOcvIdsList
          );
        }
      }
    }

    return financialAccounts;
  }

  /**
   * @description this method is used to fetch List of Financial Joint Accounts based on the Financial Account Role
   * @param financialAccountsRole contains list of financial account roles created for the joint account
   * @param customerOcvIdsList used as pass by reference for storing ocvids of the customers
   * @return List<FinServ__FinancialAccount__c>
   */
  private static List<FinServ__FinancialAccount__c> getJointFinancialAccountsDetails(
    List<FinServ__FinancialAccountRole__c> financialAccountsRole,
    List<String> customerOcvIdsList
  ) {
    List<String> financialJointAccounts = new List<String>();
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    List<FinServ__FinancialAccountRole__c> financialAccountJointRoles = new List<FinServ__FinancialAccountRole__c>();
    for (FinServ__FinancialAccountRole__c finAcc : financialAccountsRole) {
      financialJointAccounts.add(finAcc.FinServ__FinancialAccount__c);
    }
    financialAccountJointRoles = [
      SELECT
        FinServ__RelatedAccount__r.OCV_ID__c,
        FinServ__FinancialAccount__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        FinServ__FinancialAccount__r.RecordType.DeveloperName
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__FinancialAccount__c IN :financialJointAccounts
        AND FinServ__Active__c = TRUE
    ];

    for (
      FinServ__FinancialAccountRole__c finAccRole : financialAccountJointRoles
    ) {
      customerOcvIdsList.add(finAccRole.FinServ__RelatedAccount__r.OCV_ID__c);
      FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c();
      finAcc.Id = finAccRole.FinServ__FinancialAccount__c;
      finAcc.FinServ__FinancialAccountNumber__c = finAccRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c;
      finAcc.RecordType = finAccRole.FinServ__FinancialAccount__r.RecordType;
      financialAccounts.add(finAcc);
    }

    return financialAccounts;
  }
}
