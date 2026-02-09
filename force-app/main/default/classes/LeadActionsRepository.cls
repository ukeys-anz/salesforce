/**
 * @author MLCRM Developer
 * @since 07/2024
 * @description This class provide SOQL,DML and mocking helper for class related to MobileLendingLeadActions.
 */
public with sharing class LeadActionsRepository {
  private static final String CLG = 'Customer Lending Group';
  private static List<CCRM_Lead_to_Platform_Event_Mapping__mdt> leadToPlatformEventMappingMetadata = CCRM_Lead_to_Platform_Event_Mapping__mdt.getAll()
    .values();
  private static List<CCRM_Lead_Response_Event_Mapping__mdt> leadResponseToPlatformEventMappingMetadata = CCRM_Lead_Response_Event_Mapping__mdt.getAll()
    .values();

  /**
   * @description to check if the user have 'ML_Allow_Lead_Creation' custom permission
   * @name isAllowLeadCreationCustomPermission
   * @return Boolean true if the user have 'ML_Allow_Lead_Creation' custom permission
   */
  public Boolean isAllowLeadCreationCustomPermission() {
    return FeatureManagement.checkPermission('ML_Allow_Lead_Creation');
  }

  /**
   * @description to get Lead to Platform Event Mapping metadata
   * @return List<CCRM_Lead_to_Platform_Event_Mapping__mdt>
   */
  public List<CCRM_Lead_to_Platform_Event_Mapping__mdt> getLeadToPlatformEventMappingMetadata() {
    return leadToPlatformEventMappingMetadata;
  }
  /**
   * @description to get Lead Response to Platform Event Mapping metadata
   * @return List<CCRM_Lead_Response_Event_Mapping__mdt>
   */
  public List<CCRM_Lead_Response_Event_Mapping__mdt> getLeadResponseToPlatformEventMappingMetadata() {
    return leadResponseToPlatformEventMappingMetadata;
  }

  /**
   * @description It will fetch the user Profile Id
   * @param customerIds set of Customer Ids
   * @param status Finserv_Status value
   * @return Id Profile Id of the current user
   */
  public List<Account> getAccountRecords(Set<Id> customerIds, String status) {
    if (customerIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, Finserv__Status__c
      FROM Account
      WHERE Id IN :customerIds AND Finserv__Status__c = :status
      WITH USER_MODE
    ];
  }

  /**
   * @description Query Lead using Ids
   * @param leadQuery lead query
   * @param previousLeadIds set of leadIds
   * @return List of Leads
   */
  public List<Lead> getLeadRecords(String leadQuery, Set<Id> previousLeadIds) {
    if (previousLeadIds.isEmpty()) {
      return new List<Lead>();
    }
    return Database.query(String.escapeSingleQuotes(leadQuery));
  }

  /**
   * @description Query task records using leadids
   * @param taskFieldsList list of task fields
   * @param leadIds set of leadIds
   * @return List of Task
   */
  public List<Task> getTaskRecords(
    List<String> taskFieldsList,
    set<Id> leadIds
  ) {
    if (leadIds.isEmpty()) {
      return new List<Task>();
    }
    String leadResponseDevName = 'Lead_Response';
    string taskQuery =
      'SELECT ' +
      String.join(taskFieldsList, ',') +
      ', WhoId, Response_Type__r.Unica_Lead_SubStatus__c FROM Task WHERE WhoId IN :leadIds AND RecordType.DeveloperName =:leadResponseDevName order by createdDate desc LIMIT 1';
    return Database.queryWithBinds(
      String.escapeSingleQuotes(taskQuery),
      new Map<String, Object>{
        'leadIds' => leadIds,
        'leadResponseDevName' => leadResponseDevName
      },
      AccessLevel.SYSTEM_MODE
    );
  }

  /**
   * @description getlead records using Leadids
   * @param leadFields list of lead fields
   * @param leadIds leads ids
   * @return list of lead records
   */
  public List<Lead> getLeadData(List<String> leadFields, Set<Id> leadIds) {
    if (leadIds.isEmpty()) {
      return new List<Lead>();
    }
    String leadQuery =
      'SELECT Id, ' +
      String.join(leadFields, ', ') +
      ' FROM Lead WHERE Id IN :leadIds';
    return Database.query(
      String.escapeSingleQuotes(leadQuery),
      AccessLevel.SYSTEM_MODE
    );
  }

  /**
   * @description to query campaigns
   * @name getCampaignRecords
   * @param campaignCodes set of campaign codes
   * @return List<Campaign>
   */
  public List<Campaign> getCampaignRecords(Set<String> campaignCodes) {
    if (campaignCodes.isEmpty()) {
      return new List<Campaign>();
    }
    return [
      SELECT Id, Code__c, Priority__c, Description, Description__c, Name
      FROM Campaign
      WHERE Code__c IN :campaignCodes AND EndDate >= TODAY
      WITH USER_MODE
    ];
  }

  /**
   * @description to query lead records
   * @name getLeads
   * @param leadId set of Account Ids
   * @return List<Lead>
   */
  public Lead getLead(Id leadId) {
    return [
      SELECT
        Id,
        Name,
        Registered_Company__c,
        ABN__c,
        ACN__c,
        Skip_Validations__c
      FROM Lead
      WHERE Id = :leadId
      WITH USER_MODE
    ] ?? null;
  }

  /**
   * @description to query accounts
   * @name getRelatedAccounts
   * @param accountIds set of Account Ids
   * @return List<Account>
   */
  public List<Account> getRelatedAccounts(Set<String> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        Source_System_ID__c,
        Source_System_Name__c,
        Name,
        FinServ__CustomerType__c,
        RecordTypeId
      FROM Account
      WHERE
        Source_System_Name__c = :System.Label.CCRM_Source_System_Name
        AND Source_System_ID__c IN :accountIds
      WITH USER_MODE
    ];
  }

  /**
   * @description to query account account relationship records
   * @name getAccountAccountRelations
   * @param accountIdsSet set of Account Ids
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> getAccountAccountRelations(
    Set<Id> accountIdsSet
  ) {
    if (accountIdsSet.isEmpty()) {
      return new List<FinServ__AccountAccountRelation__c>();
    }

    return [
      SELECT
        Id,
        Name,
        Relationship__c,
        FinServ__Account__c,
        FinServ__RelatedAccount__c,
        FinServ__Account__r.RecordTypeId,
        FinServ__RelatedAccount__r.CLG__c,
        FinServ__RelatedAccount__r.CPID__c,
        FinServ__RelatedAccount__r.RecordTypeId,
        FinServ__RelatedAccount__r.Controlling_Post__r.OwnerId
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__c IN :accountIdsSet
        AND Relationship__c = :CLG
        AND FinServ__RelatedAccount__r.RecordTypeId = :RTAccount.clgAccount
      WITH USER_MODE
    ];
  }

  /**
   * @description getlead records using Leadid
   * @param leadIdsSet Id of Lead
   * @return List<Lead> lead records
   */
  public List<Lead> getLeadData(Set<Id> leadIdsSet) {
    if (leadIdsSet.isEmpty()) {
      return new List<Lead>();
    }
    return [
      SELECT
        Id,
        Account_Number__c,
        Business_ID__c,
        CLG_ID__c,
        Campaign_Code__c,
        City,
        Company,
        Country,
        Customer_ID__c,
        Note__c,
        Email,
        Expiry_Date__c,
        FinServ__ExpressedInterest__c,
        FirstName,
        Followup_Date__c,
        Home_Phone__c,
        New_to_Bank__c,
        LastModifiedDate,
        LastName,
        Lead_Auto_Number__c,
        Lead_Originator__c,
        Lead_Quality__c,
        LeadSource,
        MobilePhone,
        PostalCode,
        FinServ__PotentialValue__c,
        Prospect_Id__c,
        State,
        Status,
        Street,
        Title__c,
        UNICA_Treatment_Code__c,
        Work_Phone__c,
        OwnerId,
        FinServ__RelatedAccount__c,
        FinServ__ReferredByUser__c,
        Lead_Outcome__c,
        RecordTypeId,
        LastModifiedById
      FROM Lead
      WHERE Id IN :leadIdsSet
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description to query account records related to leads
   * @name getAccountRecords
   * @param accountIdsSet set of Account Ids
   * @return Map<Id, Account> Account Map
   */
  public Map<Id, Account> getAccountRecords(Set<Id> accountIdsSet) {
    if (accountIdsSet.isEmpty()) {
      return new Map<Id, Account>();
    }

    return new Map<Id, Account>(
      [
        SELECT
          Id,
          Source_System_ID__c,
          Source_System_Name__c,
          Name,
          RecordTypeId
        FROM Account
        WHERE
          Source_System_Name__c = :System.Label.CCRM_Source_System_Name
          AND Id IN :accountIdsSet
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description to query accounts
   * @name getAccountsByRelatedPartyIds
   * @param relatedPartyIds set of related party Ids
   * @return Map<Id, Account>
   */
  public Map<Id, Account> getAccountsByRelatedPartyIds(
    Set<String> relatedPartyIds
  ) {
    if (relatedPartyIds.isEmpty()) {
      return new Map<Id, Account>();
    }

    return new Map<Id, Account>(
      [
        SELECT Id, RecordTypeId
        FROM Account
        WHERE Id IN :relatedPartyIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description to query accounts
   * @name getAccounts
   * @param query string containing field to query
   * @param relatedPartyIds Related party Ids set
   * @return List<Account> List of account records
   */
  public List<Account> getAccounts(String query, Set<String> relatedPartyIds) {
    if (String.isBlank(query)) {
      return new List<Account>();
    }
    return Database.queryWithBinds(
      query,
      new Map<String, Object>{ 'relatedPartyIds' => relatedPartyIds },
      AccessLevel.SYSTEM_MODE
    );
  }

  /**
   * @description to query Industry__c records
   * @name getIndustries
   * @return List<Industry__c> Industry records
   */
  public List<Industry__c> getIndustries() {
    return [
      SELECT Id, Name, Code__c
      FROM Industry__c
      WHERE IsActive__c = TRUE
      WITH USER_MODE
    ];
  }

  /**
   * @description this is used to fetch the AAR records
   * @param relatedPartyIds
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> getAccountAccountRelationsRecords(
    Set<String> relatedPartyIds
  ) {
    if (relatedPartyIds.isEmpty()) {
      return new List<FinServ__AccountAccountRelation__c>();
    }

    return [
      SELECT
        FinServ__Account__c,
        FinServ__Account__r.RecordTypeId,
        FinServ__RelatedAccount__c,
        FinServ__RelatedAccount__r.Id,
        FinServ__RelatedAccount__r.RecordTypeId,
        FinServ__RelatedAccount__r.Industry
      FROM FinServ__AccountAccountRelation__c
      WHERE FinServ__Account__c = :relatedPartyIds
      WITH USER_MODE
    ];
  }

  /**
   * @description to query accounts & related contacts
   * @name getAccountsAndRelatedContacts
   * @param accountFields string containing account fields
   * @param contactFields string containing contact fields
   * @param relatedPartyIds set of related party Ids
   * @return List<Account> List of account records
   */
  public List<Account> getAccountsAndRelatedContacts(
    String accountFields,
    String contactFields,
    Set<String> relatedPartyIds
  ) {
    if (relatedPartyIds.isEmpty()) {
      return new List<Account>();
    }
    String queryRecords =
      'SELECT ' +
      accountFields +
      ' (SELECT ' +
      contactFields +
      ' Id FROM Contacts ORDER BY createddate DESC) FROM Account WHERE Id IN :relatedPartyIds';
    return Database.queryWithBinds(
      queryRecords,
      new Map<String, Object>{ 'relatedPartyIds' => relatedPartyIds },
      AccessLevel.SYSTEM_MODE
    );
  }
  /**
   * @description to query account records
   * @name getAccountList
   * @param accountIdsSet set of Account Ids
   * @return List<Account>
   */
  public List<Account> getAccountList(Set<Id> accountIdsSet) {
    if (accountIdsSet.isEmpty()) {
      return new List<Account>();
    }

    return [
      SELECT
        Id,
        CLG__c,
        CPID__c,
        Controlling_Post__c,
        Controlling_Post__r.OwnerId,
        Controlling_Post__r.CPID_LanID__c,
        Controlling_Post__r.CPID_User__c,
        RecordType.Name,
        RecordTypeId
      FROM Account
      WHERE Id IN :accountIdsSet
      WITH USER_MODE
    ];
  }

  /**
   * @description to query Lead records
   * @name getLeadList
   * @param leadIdIdsSet set of Lead Ids
   * @return List<Lead>
   */
  public List<Lead> getLeadList(Set<Id> leadIdIdsSet) {
    if (leadIdIdsSet.isEmpty()) {
      return new List<Lead>();
    }

    return [
      SELECT Id, Territory__c, OwnerId
      FROM Lead
      WHERE Id IN :leadIdIdsSet
      WITH USER_MODE
    ];
  }

  /**
   * @description to query account records related to leads
   * @name getIndividualAccRecords
   * @param accountIdsSet set of Account Ids
   * @return Map<Id, Account> Account Map
   */
  public Map<Id, Account> getIndividualAccRecords(Set<Id> accountIdsSet) {
    if (accountIdsSet.isEmpty()) {
      return new Map<Id, Account>();
    }

    return new Map<Id, Account>(
      [
        SELECT
          Id,
          PersonOtherPhone,
          Phone,
          PersonHomePhone,
          Other_Email__c,
          Source_System_Name__c,
          RecordTypeId
        FROM Account
        WHERE
          Source_System_Name__c = :System.Label.CCRM_Source_System_Name
          AND Id IN :accountIdsSet
          AND FinServ__Status__c IN ('Active', 'Inactive')
          AND RecordTypeId = :RTAccount.personAccount
        WITH USER_MODE
      ]
    );
  }
  /**
   * @description Retrieves a list of controlling posts based on cpids
   * @param cpids A set of LAN CPIDs from leads
   * @return List<Controlling_Post__c> A list of Controlling post records based on cpids.
   */
  public List<Controlling_Post__c> getControllingPostsByCPIDs(
    Set<String> cpids
  ) {
    if (cpids.isEmpty()) {
      return new List<Controlling_Post__c>();
    }
    return [
      SELECT Id, CPID_LanId__c, CPID__c, CPID_User__c
      FROM Controlling_Post__c
      WHERE CPID__c IN :cpids
      WITH USER_MODE
    ];
  }
}
