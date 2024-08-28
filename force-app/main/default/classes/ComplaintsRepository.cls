/**
 * @author Hrushikesh Pathak
 * @since 08/2024
 * @description ComplaintsRepository is the repository class for Comaplaints Case Actions.
 */
public with sharing class ComplaintsRepository {
  /**
   * @description getCaseDetailsById is to query case based on Id
   * @param caseId the id to be queried
   * @return Case the Case deatils
   */
  public Case getCaseDetailsById(Id caseId) {
    if (
      Case.sObjectType.getDescribe().isQueryable() == false ||
      caseId == null
    ) {
      return null;
    }

    Case caseRecord = [
      SELECT
        Id,
        IDR_AFCA_Status__c,
        Origin,
        IDR_Subsequent_Issue__c,
        IDR_Is_Written_Resp_Requested__c,
        IDR_Is_Written_Resp_Required__c,
        IDR_Is_Common__c,
        IDR_Escalation_Reason__c,
        IDR_Complainant_Type__c,
        IDR_Product_Category__c,
        RecordType.DeveloperName,
        RecordTypeId,
        Type,
        Priority,
        CaseNumber,
        IDR_Complainant_Desired_Outcome__c,
        Description,
        ANZx_Customer__c
      FROM Case
      WHERE Id = :caseId
      LIMIT 1
    ];
    return caseRecord;
  }

  /**
   * @description getAccountById is to query accounts based on Id
   * @param accountId the id to be queried
   * @return List<Account> the queried account list
   */
  public Account getAccountById(Id accountId) {
    if (SObjectType.Account.isQueryable() == false || accountId == null) {
      return null;
    }
    Account account = [
      SELECT OCV_ID__c
      FROM Account
      WHERE Id = :accountId
    ];
    return account;
  }

  /**
   * @description getCaseById is to query case based on Id
   * @param caseId the id to be queried
   * @return Case the Case deatils
   */
  public Case getCaseById(Id caseId) {
    if (
      Case.sObjectType.getDescribe().isQueryable() == false ||
      caseId == null
    ) {
      return null;
    }

    Case caseRecord = [
      SELECT
        Id,
        RecordType.DeveloperName,
        RecordTypeId,
        Origin,
        ANZx_Customer__c
      FROM Case
      WHERE Id = :caseId
      LIMIT 1
    ];
    return caseRecord;
  }
}
