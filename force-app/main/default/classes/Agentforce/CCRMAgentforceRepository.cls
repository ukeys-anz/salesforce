/**
 * @author Prasanjeet Dutta
 * @since Dec 12 2025
 * @description Repository class responsible for retrieving Interaction, Opportunity, Lead,
 *              A–Z Review, Survey, Task, Customer Relationship, and Extra Care data for CCRMAgentforce.
 */
public with sharing class CCRMAgentforceRepository {
  private static final String CAP_DIARY_COMMENTS = 'CAP Diary Comments';
  private static final String IDR_USER = 'IDREmailService System User';

  /**
   * @description Returns the count of Interaction records for a CLG Account since a specified date.
   *              Uses Interaction.CLGCustomer__c = :accountId.
   * @param accountId The CLG Account Id (matched against Interaction.CLGCustomer__c).
   * @param sinceDate Only interactions occurring on/after this date are counted.
   * @return Integer The number of Interaction records for the CLG Account.
   */
  public Integer fetchInteractionCountForCLG(Id accountId, Date sinceDate) {
    if (!Schema.sObjectType.Interaction.isAccessible()) {
      return 0;
    }
    return [
      SELECT COUNT()
      FROM Interaction
      WHERE
        StartTime >= :sinceDate
        AND CLGCustomer__c = :accountId
        AND Category__c != :CAP_DIARY_COMMENTS
      WITH USER_MODE
    ];
  }

  /**
   * @description Returns the count of Interaction records for a non-CLG (Other) Account since a specified date.
   *              Uses Interaction.AccountId = :accountId.
   * @param accountId The Account Id (matched against Interaction.AccountId).
   * @param sinceDate Only interactions occurring on/after this date are counted.
   * @return Integer The number of Interaction records for the Account.
   */
  public Integer fetchInteractionCount(Id accountId, Date sinceDate) {
    if (!Schema.sObjectType.Interaction.isAccessible()) {
      return 0;
    }
    return [
      SELECT COUNT()
      FROM Interaction
      WHERE
        StartTime >= :sinceDate
        AND AccountId = :accountId
        AND Category__c != :CAP_DIARY_COMMENTS
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetches the most recent Interaction records for a CLG Account.
   *              Uses Interaction.CLGCustomer__c = :accountId.
   * @param accountId The CLG Account Id (matched against Interaction.CLGCustomer__c).
   * @param sinceDate Only interactions on/after this date are returned.
   * @param limitSize Maximum number of records to return.
   * @return List<Interaction> The most recent interactions for the CLG Account.
   */
  public List<Interaction> fetchLatestInteractionsForCLG(
    Id accountId,
    Date sinceDate,
    Integer limitSize
  ) {
    if (!Schema.sObjectType.Interaction.isAccessible()) {
      return new List<Interaction>();
    }
    return [
      SELECT Id, Name, Optional_Notes__c, Interaction_Type__c, StartTime
      FROM Interaction
      WHERE
        StartTime >= :sinceDate
        AND CLGCustomer__c = :accountId
        AND Category__c != :CAP_DIARY_COMMENTS
      WITH USER_MODE
      ORDER BY CreatedDate DESC
      LIMIT :limitSize
    ];
  }

  /**
   * @description Fetches the most recent Interaction records for a non-CLG (Other) Account.
   *              Uses Interaction.AccountId = :accountId.
   * @param accountId The Account Id (matched against Interaction.AccountId).
   * @param sinceDate Only interactions on/after this date are returned.
   * @param limitSize Maximum number of records to return.
   * @return List<Interaction> The most recent interactions for the Account.
   */
  public List<Interaction> fetchLatestInteractions(
    Id accountId,
    Date sinceDate,
    Integer limitSize
  ) {
    if (!Schema.sObjectType.Interaction.isAccessible()) {
      return new List<Interaction>();
    }
    return [
      SELECT Id, Name, Optional_Notes__c, Interaction_Type__c, StartTime
      FROM Interaction
      WHERE
        StartTime >= :sinceDate
        AND AccountId = :accountId
        AND Category__c != :CAP_DIARY_COMMENTS
      WITH USER_MODE
      ORDER BY CreatedDate DESC
      LIMIT :limitSize
    ];
  }

  /**
   * @description Retrieves Opportunities for a CLG Account created on/after a given date.
   *              Uses Opportunity.CLG__c = :accountId.
   * @param accountId The CLG Account Id (matched against Opportunity.CLG__c).
   * @param sinceDate Only opportunities created on/after this date are returned.
   * @param limitSize Maximum number of records to return.
   * @return List<Opportunity> Matching Opportunity records for the CLG Account.
   */
  // CLG vs Other split: Opportunities
  public List<Opportunity> fetchOpportunitiesForCLG(
    Id accountId,
    Date sinceDate,
    Integer limitSize
  ) {
    if (!Schema.sObjectType.Opportunity.isAccessible()) {
      return new List<Opportunity>();
    }
    return [
      SELECT
        Id,
        Name,
        Owner.Name,
        Amount,
        Approved_Amount__c,
        CloseDate,
        StageName,
        Lost_Reason__c
      FROM Opportunity
      WHERE CreatedDate >= :sinceDate AND CLG__c = :accountId
      WITH USER_MODE
      LIMIT :limitSize
    ];
  }

  /**
   * @description Retrieves Opportunities for a non-CLG (Other) Account created on/after a given date.
   *              Uses Opportunity.AccountId = :accountId.
   * @param accountId The Account Id (matched against Opportunity.AccountId).
   * @param sinceDate Only opportunities created on/after this date are returned.
   * @param limitSize Maximum number of records to return.
   * @return List<Opportunity> Matching Opportunity records for the Account.
   */
  public List<Opportunity> fetchOpportunities(
    Id accountId,
    Date sinceDate,
    Integer limitSize
  ) {
    if (!Schema.sObjectType.Opportunity.isAccessible()) {
      return new List<Opportunity>();
    }
    return [
      SELECT
        Id,
        Name,
        Owner.Name,
        Amount,
        Approved_Amount__c,
        CloseDate,
        StageName,
        Lost_Reason__c
      FROM Opportunity
      WHERE CreatedDate >= :sinceDate AND AccountId = :accountId
      WITH USER_MODE
      LIMIT :limitSize
    ];
  }

  /**
   * @description Returns OpportunityLineItems for a given set of Opportunity Ids.
   * @param oppIds The set of Opportunity Ids.
   * @return List<OpportunityLineItem> Line items associated with the given opportunity Ids.
   */
  public List<OpportunityLineItem> fetchOpportunityLineItems(Set<Id> oppIds) {
    return oppIds.isEmpty()
      ? new List<OpportunityLineItem>()
      : [
          SELECT OpportunityId, Product2.Name, UnitPrice
          FROM OpportunityLineItem
          WHERE OpportunityId IN :oppIds
          WITH USER_MODE
        ];
  }

  /**
   * @description Retrieves Lead records for a CLG Account created on/after a given date.
   *              Uses Lead.CLG_Name__c = :accountId. Excludes Expired and Converted.
   * @param accountId The CLG Account Id (matched against Lead.CLG_Name__c).
   * @param sinceDate Only leads created on/after this date are returned.
   * @param limitSize Maximum number of records to return.
   * @return List<Lead> Matching Lead records for the CLG Account.
   */
  // CLG vs Other split: Leads
  public List<Lead> fetchLeadsForCLG(
    Id accountId,
    Date sinceDate,
    Integer limitSize
  ) {
    if (!Schema.sObjectType.Lead.isAccessible()) {
      return new List<Lead>();
    }
    return [
      SELECT
        Id,
        Name,
        SubStatus__c,
        Status,
        Referral_Status__c,
        Lead_Outcome__c,
        IsConverted,
        CreatedDate
      FROM Lead
      WHERE
        CreatedDate >= :sinceDate
        AND Lead_Outcome__c != 'Expired'
        AND IsConverted = FALSE
        AND CLG_Name__c = :accountId
      WITH USER_MODE
      ORDER BY CreatedDate DESC
      LIMIT :limitSize
    ];
  }

  /**
   * @description Retrieves Lead records for a non-CLG (Other) Account created on/after a given date.
   *              Uses Lead.FinServ__RelatedAccount__c = :accountId. Excludes Expired and Converted.
   * @param accountId The Account Id (matched against Lead.FinServ__RelatedAccount__c).
   * @param sinceDate Only leads created on/after this date are returned.
   * @param limitSize Maximum number of records to return.
   * @return List<Lead> Matching Lead records for the Account.
   */
  public List<Lead> fetchLeads(
    Id accountId,
    Date sinceDate,
    Integer limitSize
  ) {
    if (!Schema.sObjectType.Lead.isAccessible()) {
      return new List<Lead>();
    }
    return [
      SELECT
        Id,
        Name,
        SubStatus__c,
        Status,
        Referral_Status__c,
        Lead_Outcome__c,
        IsConverted,
        CreatedDate
      FROM Lead
      WHERE
        CreatedDate >= :sinceDate
        AND Lead_Outcome__c != 'Expired'
        AND IsConverted = FALSE
        AND FinServ__RelatedAccount__c = :accountId
      WITH USER_MODE
      ORDER BY CreatedDate DESC
      LIMIT :limitSize
    ];
  }

  /**
   * @description Retrieves A–Z Review records for a CLG Account created on/after a given date.
   *              Uses A_Z_Review__c.CLGCustomer__c = :accountId.
   * @param accountId The CLG Account Id (matched against A_Z_Review__c.CLGCustomer__c).
   * @param sinceDate Only reviews created on/after this date are returned.
   * @param limitSize Maximum number of records to return.
   * @return List<A_Z_Review__c> Matching A–Z Review records for the CLG Account.
   */
  // CLG vs Other split: A_Z_Review__c
  public List<A_Z_Review__c> fetchAZReviewsForCLG(
    Id accountId,
    Date sinceDate,
    Integer limitSize
  ) {
    if (!Schema.sObjectType.A_Z_Review__c.isAccessible()) {
      return new List<A_Z_Review__c>();
    }
    return [
      SELECT
        Id,
        Name,
        Business_Details__c,
        Borrowing_OFI_Relationship__c,
        Personal_Banking__c,
        CreatedDate
      FROM A_Z_Review__c
      WHERE CreatedDate >= :sinceDate AND CLGCustomer__c = :accountId
      WITH USER_MODE
      LIMIT :limitSize
    ];
  }

  /**
   * @description Retrieves A–Z Review records for a non-CLG (Other) Account created on/after a given date.
   *              Uses A_Z_Review__c.Customer__c = :accountId.
   * @param accountId The Account Id (matched against A_Z_Review__c.Customer__c).
   * @param sinceDate Only reviews created on/after this date are returned.
   * @param limitSize Maximum number of records to return.
   * @return List<A_Z_Review__c> Matching A–Z Review records for the Account.
   */
  public List<A_Z_Review__c> fetchAZReviews(
    Id accountId,
    Date sinceDate,
    Integer limitSize
  ) {
    if (!Schema.sObjectType.A_Z_Review__c.isAccessible()) {
      return new List<A_Z_Review__c>();
    }
    return [
      SELECT
        Id,
        Name,
        Business_Details__c,
        Borrowing_OFI_Relationship__c,
        Personal_Banking__c,
        CreatedDate
      FROM A_Z_Review__c
      WHERE CreatedDate >= :sinceDate AND Customer__c = :accountId
      WITH USER_MODE
      LIMIT :limitSize
    ];
  }

  /**
   * @description Retrieves Qualtrics Survey Responses linked to the provided A–Z Review Ids.
   * @param reviewIds The set of A–Z Review Ids.
   * @return List<qualtrics__Survey_Response__c> A list of survey response records.
   */
  public List<qualtrics__Survey_Response__c> fetchSurveyResponses(
    Set<Id> reviewIds
  ) {
    if (
      reviewIds.isEmpty() ||
      !Schema.sObjectType.qualtrics__Survey_Response__c.isAccessible()
    ) {
      return new List<qualtrics__Survey_Response__c>();
    }

    return [
      SELECT
        Id,
        Name,
        qualtrics__Date_Responded__c,
        qualtrics__Net_Promoter_Score__c,
        Customer_Feedback__c,
        A_Z_Review__c
      FROM qualtrics__Survey_Response__c
      WHERE A_Z_Review__c IN :reviewIds
      WITH USER_MODE
      ORDER BY CreatedDate DESC
    ];
  }

  /**
   * @description Retrieves open Tasks related to this Account with due dates in the last 3 months or no due date.
   * @param accountId     The Account Id.
   * @param threeMonthsAgo A date 3 months prior.
   * @return List<Task> The list of open Tasks.
   */
  public List<Task> fetchOpenTasks(Id accountId, Date threeMonthsAgo) {
    if (!Schema.sObjectType.Task.isAccessible()) {
      return new List<Task>();
    }
    return [
      SELECT Id, Subject, ActivityDate
      FROM Task
      WHERE
        WhatId = :accountId
        AND Status != 'Completed'
        AND (ActivityDate = NULL
        OR ActivityDate >= :threeMonthsAgo)
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves Customer Relationship records for this Account.
   * @param accountId The Account Id.
   * @return List<Customer_Relationship__c> A list of Customer Relationship records.
   */
  public List<Customer_Relationship__c> fetchCustomerRelationships(
    Id accountId
  ) {
    if (!Schema.sObjectType.Customer_Relationship__c.isAccessible()) {
      return new List<Customer_Relationship__c>();
    }
    return [
      SELECT
        Id,
        Name,
        Private_Banker_Advisor__r.Name,
        Customer_Areas_of_Interest__c,
        Priorities_and_Objectives__c,
        Other_Account_Plan_Information__c,
        ANZ_Opportunities__c,
        Competitive_Landscape_and_ANZ_Relative__c,
        Notes__c,
        Personal_Background__c,
        Financial_Wealth_Background__c,
        Business_Investment_Background__c,
        Additional_Details__c,
        Status__c,
        LastModifiedDate
      FROM Customer_Relationship__c
      WHERE Customer__c = :accountId
      WITH USER_MODE
      ORDER BY LastModifiedDate DESC
    ];
  }

  /**
   * @description Returns the number of Extra Care relationships between this Account and other accounts.
   * @param accountId The Account Id.
   * @return Integer The count of Extra Care account relations.
   */
  public Integer fetchAccountAccountRelationsForExtraCare(Id accountId) {
    if (!Schema.sObjectType.FinServ__AccountAccountRelation__c.isAccessible()) {
      return 0;
    }
    return [
      SELECT COUNT()
      FROM FinServ__AccountAccountRelation__c
      WHERE FinServ__Account__c = :accountId AND extraCare__c = TRUE
      WITH USER_MODE
    ];
  }
  /**
   * @description Returns diary comments for the given External Account Id.
   * @param externalAccountId The External Id of the Account.
   * @return List<Diary_Comment__x> List of diary comments associated
   *         with the external account. Returns an empty list if none exist.
   */
  public List<Diary_Comment__x> fetchDiaryCommentsForExternalId(
    String externalAccountId
  ) {
    if (String.isBlank(externalAccountId)) {
      return new List<Diary_Comment__x>();
    }
    if (!Schema.sObjectType.Diary_Comment__x.isAccessible()) {
      return new List<Diary_Comment__x>();
    }

    return [
      SELECT
        Id,
        Account__r.Name,
        Expiry_Date__c,
        Description__c,
        Date_Placed__c,
        Permanent__c,
        Account__r.External_Id__c
      FROM Diary_Comment__x
      WHERE Account__r.External_Id__c = :externalAccountId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetches Account-Account relations for a CLG Account.
   * @param accountId The Id of the CLG Account
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> fetchAccountRelationsForCLG(
    Id accountId
  ) {
    if (!Schema.sObjectType.FinServ__AccountAccountRelation__c.isAccessible()) {
      return new List<FinServ__AccountAccountRelation__c>();
    }
    return [
      SELECT FinServ__RelatedAccount__c
      FROM FinServ__AccountAccountRelation__c
      WHERE FinServ__Account__c = :accountId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetches Customer Complaint Cases for the provided Account Ids.
   * @param accountIds Set of Account Ids used in the IN clause
   * @return List<Case> List of Case records (customer complaints)
   */
  public List<Case> fetchCustomerComplaints(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Case>();
    }
    if (!Schema.sObjectType.Case.isAccessible()) {
      return new List<Case>();
    }
    return [
      SELECT
        Id,
        AccountId,
        CaseNumber,
        CreatedDate,
        ClosedDate,
        RecordType.DeveloperName
      FROM Case
      WHERE
        AccountId IN :accountIds
        AND CreatedDate >= N_MONTHS_AGO:24
        AND (RecordTypeId = :RTCase.customerComplaint
        OR (RecordTypeId = :RTCasE.generalInquiryCmos
        AND CreatedBy.Name = :IDR_USER))
      WITH USER_MODE
      ORDER BY CreatedDate DESC
    ];
  }
  /**
   * @description Fetch Application Form Products related to the provided Opportunity Ids via OpportunityLineItem.
   *              One AFP per OLI is expected.
   * @param oppIds Set of Opportunity Ids to filter AFPs by (through Opportunity_Product__r.OpportunityId).
   * @return List<ApplicationFormProduct__c> List of AFPs with related fields.
   */
  public List<ApplicationFormProduct> fetchApplicationFormProductsByOppIds(
    Set<Id> oppIds
  ) {
    if (oppIds.isEmpty()) {
      return new List<ApplicationFormProduct>();
    }
    if (!Schema.sObjectType.ApplicationFormProduct.isAccessible()) {
      return new List<ApplicationFormProduct>();
    }
    return [
      SELECT
        Id,
        Product.Name,
        Stage,
        Opportunity_Product__c,
        Opportunity_Product__r.OpportunityId
      FROM ApplicationFormProduct
      WHERE Opportunity_Product__r.OpportunityId IN :oppIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Account by Id.
   * @param accountId Salesforce Account Id
   * @return List<Account> List containing the account or empty if not found
   */
  public List<Account> fetchAccountById(Id accountId) {
    return [
      SELECT
        Id,
        Name,
        Controlling_Post__c,
        Controlling_Post__r.CPID_Type__c,
        RecordTypeId,
        Source_System_ID__c
      FROM Account
      WHERE Id = :accountId
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description Fetch Controlling Post by Lan Id.
   * @param lanId user's Lan Id
   * @return List<Controlling_Post__c> List of Controlling_Post__c records
   */
  public List<Controlling_Post__c> fetchControllingPostByLanId(String lanId) {
    return [
      SELECT Id, Name, CPID_LanID__c, CPID_Type__c
      FROM Controlling_Post__c
      WHERE CPID_LanID__c = :lanId
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description Fetch CLG accounts under a Controlling Post.
   * @param cpid controlling post id
   * @return List<Account> List of Account records
   */
  public List<Account> fetchCLGAccountsByCPID(Id cpid) {
    return [
      SELECT Name, Source_System_ID__c
      FROM Account
      WHERE Controlling_Post__c = :cpid AND RecordTypeId = :RTAccount.clgAccount
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch accounts by customer numbers.
   * @param custNums set of customer numbers
   * @return List<Account> List of Account records
   */
  public List<Account> fetchAccountsByCustomerNumbers(Set<String> custNums) {
    return [
      SELECT Id, Name, Source_System_ID__c
      FROM Account
      WHERE Source_System_ID__c IN :custNums
      WITH USER_MODE
    ];
  }
}
