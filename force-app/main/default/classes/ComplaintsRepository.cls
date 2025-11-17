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
    return [
      SELECT
        Id,
        AccountId,
        IDR_Customer_Number__c,
        IDR_Customer_Identifier__c,
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
    ] ?? null;
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

  /**
   * @description find accounts based on a set of Ids
   * @param accountIds Set of account ids to search
   * @return List<Account> the result of accounts
   */
  public List<Account> findAccountsByAccountIds(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        FirstName,
        LastName,
        MiddleName,
        CPID__c,
        Source_System_ID__c,
        OCV_ID__c,
        PersonBirthdate,
        Gender__pc,
        PersonOtherPostalCode,
        PersonOtherCountry,
        ShippingCountry,
        ShippingPostalCode,
        BillingCountry,
        BillingPostalCode,
        RecordTypeId
      FROM Account
      WHERE Id IN :accountIds
    ];
  }

  /**
   * @description Get user's last Lightning app logged in app
   * @param userId userId
   * @return UserAppInfo
   */
  public UserAppInfo getUserAppInfoForUser(Id userId) {
    List<UserAppInfo> appInfos = [
      SELECT Id, AppDefinitionId
      FROM UserAppInfo
      WHERE UserId = :userId
      LIMIT 1
    ];
    if (appInfos.isEmpty()) {
      return null;
    }
    return appInfos[0];
  }
  /**
   * @description Get list of RecordTypes
   * @param recordTypeIds Recordtype Ids
   * @return List<RecordType>
   */
  public List<RecordType> getRecordTypes(Set<Id> recordTypeIds) {
    return [
      SELECT Id, Name, Description, DeveloperName
      FROM RecordType
      WHERE Id IN :recordTypeIds
      WITH USER_MODE
    ];
  }
  /**
   * @description Get getComplaintHistory of complaint
   * @param caseId Case Id of Complaint
   * @param fieldName Feild Name
   * @return CaseHistory
   */
  public CaseHistory getComplaintHistory(Id caseId, String fieldName) {
    return [
      SELECT CreatedDate
      FROM CaseHistory
      WHERE Field = :fieldName AND CaseId = :caseId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ] ?? null;
  }
  /**
   * @description Get the complaint
   * @param caseId caseId of Complaint
   * @return Case
   */
  public Case getCreatedDate(Id caseId) {
    return [SELECT CreatedDate FROM Case WHERE ID = :caseId] ?? null;
  }
}
