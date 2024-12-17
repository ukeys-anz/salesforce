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
      SELECT Id, AccountId, OwnerId, CaseNumber
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
      WHERE ParentId IN :parentIds
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
   * @param parentCaseId set of Case Group ids(Parent Case) for which Owner has changed or status has changed.
   * @return List<Case> List of child cases associated to the parent case.
   */
  public List<Case> queryEligibleChildCaseRecords(Set<Id> parentCaseId) {
    if (parentCaseId == null || !SObjectType.Case.isQueryable()) {
      return new List<Case>();
    }

    return [
      SELECT
        Id,
        Account.OCV_ID__c,
        CaseNumber,
        ParentId,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Intended_Account_BSB__c,
        Intended_Account_Name__c,
        Intended_Account_Number__c,
        Sub_Status__c,
        Status,
        Process_Status__c
      FROM Case
      WHERE
        ParentId = :parentCaseId
        AND RecordTypeId = :RTCase.accountClosure
        AND Status = 'Escalated'
        AND (Sub_Status__c = 'Failure'
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
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Account_Type__c,
        Account_Product__c
      FROM Case
      WHERE
        ParentId = :parentCaseId
        AND RecordTypeId = :RTCase.accountClosure
        AND Status = 'Escalated'
        AND Sub_Status__c = 'Success'
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
   * @param recordId Child Case Record raised for closure
   * @return Case record with the details
   */
  public Case queryCase(Id recordId) {
    return [
      SELECT Id, Status
      FROM Case
      WHERE Id = :recordId
    ];
  }
  // /**
  //  * @description this method will query the sibling case record details
  //  * @param parentCaseId Parent case record id
  //  * @param packageId package id associated with the child case
  //  * @param complementaryRecordType if the current case is with recordtype checking then check the case details with complementary record type saving
  //  * @return Sibling Case record with the details
  //  */
  // private static Case querySiblingCaseDetails(Id parentCaseId,String packageId,String complementaryRecordType) {
  //   return [
  //     SELECT
  //       Id,
  //       Status
  //     FROM Case
  //     WHERE
  //     ParentId = :parentCaseId
  //       AND Package_Id__c = :packageId
  //       AND Status = 'Closed'
  //       AND FinServ__FinancialAccount__r.RecordType.DeveloperName =: complementaryRecordType

  //   ];
  // }

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
        AND Status != 'Closed'
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
        FinServ_Product_Name__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Account_Type__c
      FROM Case
      WHERE Id IN :setOfCaseIdsToQuery
    ];
  }
}
