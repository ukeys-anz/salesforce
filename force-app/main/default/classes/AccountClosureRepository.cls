/**
 * @author Kopal Goswami
 * @since 11/2024
 * @description  AccountClosureRepository is the repository class for Account Closure Case Actions.
 */
public with sharing class AccountClosureRepository {
  /**
   * @description Get list of Case Group cases associated with the account Ids and status as not closed.
   * @param accountIds set of Account Ids associated to the case
   * @return List<Case> list of Case Group cases
   */
  public List<Case> queryNotClosedCaseGroups(Set<Id> accountIds) {
    if (accountIds.isEmpty() || !SObjectType.Case.isQueryable()) {
      return new List<Case>();
    }

    return [
      SELECT Id, AccountId, OwnerId, CaseNumber, Status, Circumstance__c
      FROM Case
      WHERE
        RecordTypeId = :RTCase.caseGroup
        AND Status != :GetHelpConstants.CLOSED_STATUS
        AND AccountId IN :accountIds
        AND Type = :GetHelpConstants.ACCOUNT_CLOSURE
    ];
  }

  /**
   * @description Queries all the related cases (child cases) to the parent case.
   * @param parentIds set of Case Group ids(Parent Case) for which Owner has changed or status has changed.
   * @return List<Case> List of child cases associated to the parent case.
   */
  public List<Case> queryChildCaseRecords(Set<Id> parentIds) {
    if (parentIds.isEmpty() || !SObjectType.Case.isQueryable()) {
      return new List<Case>();
    }
    return [
      SELECT Id, ParentId
      FROM Case
      WHERE ParentId IN :parentIds AND RecordTypeId = :RTCase.accountClosure
    ];
  }

  /**
   * @description Query Name of the Account
   * @param accountIds set of account Ids
   * @return List<Account> List of accounts with their names
   */
  public List<Account> queryAccountName(Set<Id> accountIds) {
    if (accountIds.isEmpty() || !SObjectType.Account.isQueryable()) {
      return new List<Account>();
    }
    return [
      SELECT Id, Name
      FROM Account
      WHERE Id IN :accountIds
    ];
  }

  /**
   * @description Queries all the related cases (child cases) to the parent case having status as Escalated or Escalated and Failure.
   * @param parentCaseIds Case Group Id(Parent Case) for which Support Coach want to initiate precheck
   * @return List<Case> List of child cases associated to the parent case.
   */
  public List<Case> queryEligibleChildCaseRecords(Set<Id> parentCaseIds) {
    if (parentCaseIds.isEmpty() || !SObjectType.Case.isQueryable()) {
      return new List<Case>();
    }

    return [
      SELECT
        Id,
        Account.OCV_ID__c,
        CaseNumber,
        ParentId,
        Product.Name,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Intended_Account_BSB__c,
        Intended_Account_Name__c,
        Intended_Account_Number__c,
        Sub_Status__c,
        Status,
        Process_Id__c,
        Account_Type__c
      FROM Case
      WHERE
        ParentId IN :parentCaseIds
        AND RecordTypeId = :RTCase.accountClosure
        AND FinServ__FinancialAccount__c != NULL
        AND ProductId != NULL
        AND (Sub_Status__c = 'Failed'
        OR Sub_Status__c = NULL)
    ];
  }

  /**
   * @description Queries all the related cases (child cases) to the parent case having status as Escalated and Substatus as Success
   * @param parentCaseId set of Case Group (Parent Case) Id
   * @return List<Case> List of child cases associated to the parent case.
   */
  public List<Case> queryChildCasesForClosure(Set<Id> parentCaseId) {
    if (parentCaseId == null || !SObjectType.Case.isQueryable()) {
      return new List<Case>();
    }

    return [
      SELECT
        Id,
        CaseNumber,
        ParentId,
        Product.Name,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Account_Type__c,
        Account_Product__c
      FROM Case
      WHERE
        ParentId = :parentCaseId
        AND RecordTypeId = :RTCase.accountClosure
        AND Sub_Status__c = 'Success'
        AND FinServ__FinancialAccount__c != NULL
        AND ProductId != NULL
    ];
  }

  /**
   * @description Queries all the related cases (child cases) to the parent case having status as Escalated and Substatus Success or Failed post precheck
   * @param caseIds set of Case Group (Parent Case) Id
   * @return List<Case> List of child cases associated to the parent case.
   */
  public List<Case> queryChildCasesDetailsPostPrecheck(Map<Id, Case> caseIds) {
    if (caseIds.isEmpty() || !SObjectType.Case.isQueryable()) {
      return new List<Case>();
    }

    return [
      SELECT
        Id,
        CaseNumber,
        ParentId,
        Product.Name,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Account_Type__c,
        Status,
        Sub_Status__c
      FROM Case
      WHERE Id IN :caseIds.keySet()
    ];
  }

  /**
   * @description this method will query the case record details
   * @param recordId Child Case Record raised for closure
   * @return Case record with the details
   */
  public Case queryCaseDetails(Id recordId) {
    return [
      SELECT
        Id,
        Package_Id__c,
        ParentId,
        Process_Status__c,
        Account_Type__c,
        CaseNumber,
        Account.OCV_ID__c,
        Account_Product__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        FinServ__FinancialAccount__r.RecordType.DeveloperName
      FROM Case
      WHERE Id = :recordId
    ];
  }

  /**
   * @description this method will query the case record details
   * @param recordIds Child Case Records raised for closure
   * @return Case records with the details
   */
  public List<Case> queryCaseToUpdateStatusAsClosed(Set<Id> recordIds) {
    return [
      SELECT Id, Status
      FROM Case
      WHERE Id IN :recordIds
    ];
  }

  /**
   * @description Dummy cases are those which are created in Org for that parent Id
   * Find such cases for update with latest data rather creating new one
   * @param parentCaseId Id of the parent case
   * @return List<Case> list of child cases
   */
  public List<Case> queryListOfExistingDummyCases(Id parentCaseId) {
    return [
      SELECT
        Id,
        Status,
        Intended_Account_Name__c,
        Intended_Account_BSB__c,
        Intended_Account_Number__c,
        Closure_Reason__c,
        Account_Type__c,
        AccountId,
        FinServ__FinancialAccount__c,
        ProductId
      FROM Case
      WHERE
        ParentId = :parentCaseId
        AND Status != :GetHelpConstants.CLOSED_STATUS
        AND FinServ__FinancialAccount__c = NULL
        AND RecordTypeId = :RTCase.accountClosure
    ];
  }

  /**
   * @description Inserted or Updated Case data which is requried to show on LWC
   * @param setOfCaseIdsToQuery set of case Ids to query
   * @return List<Case> list of case records
   */
  public List<Case> queryListOfInsertedOrUpdatedCases(
    Set<Id> setOfCaseIdsToQuery
  ) {
    return [
      SELECT
        Id,
        CaseNumber,
        Product__r.Name,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Account_Type__c
      FROM Case
      WHERE Id IN :setOfCaseIdsToQuery
    ];
  }

  /**
   * @description Extracts listOfCases based on accountIds
   * @param accountIds set of account Ids to query
   * @return List<Case> list of case records
   */
  public List<Case> fetchChildCases(Set<Id> accountIds) {
    return [
      SELECT Id, FinServ__FinancialAccount__c
      FROM Case
      WHERE
        FinServ__FinancialAccount__c IN :accountIds
        AND RecordTypeId = :RTCase.accountClosure
    ];
  }

  /**
   * @description Extracts map of account Ids and financial account records
   * @param accountIds set of account Ids to query
   * @return Map<Id, FinServ__FinancialAccount__c> map of account Ids and financial account records
   */
  public Map<Id, FinServ__FinancialAccount__c> fetchFinancialAccounts(
    Set<Id> accountIds
  ) {
    return new Map<Id, FinServ__FinancialAccount__c>(
      [
        SELECT
          Id,
          FinServ__FinancialAccountNumber__c,
          FinServ__ProductName__r.Name,
          FinServ__ProductName__c,
          FinServ__Balance__c,
          FinServ__Ownership__c,
          Marketing_Code__c,
          FinServ__Status__c,
          RecordType.DeveloperName
        FROM FinServ__FinancialAccount__c
        WHERE Id IN :accountIds
      ]
    );
  }

  /**
   * @description Extracts list of failure actions based on failure reason.
   * @param failureReasons set of failure reasons to query
   * @return List<AccountClosureErrorMetadata__mdt> list of failure reasons actions details
   */
  public List<AccountClosureErrorMetadata__mdt> getFailureMetadata(
    Set<String> failureReasons
  ) {
    if (failureReasons.isEmpty()  || !SObjectType.AccountClosureErrorMetadata__mdt.isQueryable()) {
      return new List<AccountClosureErrorMetadata__mdt>();
    }
    
    List<AccountClosureErrorMetadata__mdt> failureReasonActions = 
    [
        SELECT Type__c, Failure_Reason__c, Chatter_Post__c , Label
        FROM AccountClosureErrorMetadata__mdt 
        WHERE Failure_Reason__c IN :failureReasons
    ];

    if(failureReasonActions.isEmpty())
    {
      return new List<AccountClosureErrorMetadata__mdt>();
    }

    List<AccountClosureErrorMetadata__mdt> constantHeader = 
      [
          SELECT Type__c, Failure_Reason__c, Chatter_Post__c , Label
          FROM AccountClosureErrorMetadata__mdt 
          WHERE Type__c = 'Constant'
      ];
     
    List<AccountClosureErrorMetadata__mdt> chatterActions = new List<AccountClosureErrorMetadata__mdt>();
    chatterActions.addAll(failureReasonActions);
    chatterActions.addAll(constantHeader);

    return chatterActions;
  }
}
