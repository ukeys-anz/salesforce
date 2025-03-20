/**
 * @author Hitesh Wasdani
 * @since 07/2024
 * @description This class provide SOQL and DML helper for class related to LeadConversionController and LeadConversionHelper.
 * without sharing: used to bypass lead sharing setting in lead conversion process
 */
public without sharing class LeadConversionActionsRepository {
  /**
   * @description fetch ocv user
   * @name getOCVUser
   * @return User fetching OCV user
   */
  public User getOCVUser() {
    return [
      SELECT Id
      FROM USER
      WHERE Username = :System.Label.OCVIntegrationUsername
      WITH SYSTEM_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description This method to query lead details along with customer details
   * @name getLeadsWithCustomerDetails
   * @param leadId Set of Lead Ids
   * @return Lead
   * @author Ankit Garg
   * @US CC-4429
   */
  public Lead getLeadsWithCustomerDetails(Id leadId) {
    if (leadId == null) {
      return null;
    }
    return [
      SELECT
        Id,
        OwnerId,
        RecordType.DeveloperName,
        FirstName,
        MiddleName,
        LastName,
        Home_Phone__c,
        Work_Phone__c,
        MobilePhone,
        Email,
        Street,
        City,
        State,
        Country,
        PostalCode,
        AdvertisingIndicator__c,
        FinServ__RelatedAccount__c,
        FinServ__RelatedAccount__r.FirstName,
        FinServ__RelatedAccount__r.MiddleName,
        FinServ__RelatedAccount__r.LastName,
        FinServ__RelatedAccount__r.Phone,
        FinServ__RelatedAccount__r.PersonContactId,
        FinServ__RelatedAccount__r.PersonContact.HomePhone,
        FinServ__RelatedAccount__r.PersonContact.OtherPhone,
        FinServ__RelatedAccount__r.PersonContact.Email,
        FinServ__RelatedAccount__r.PersonContact.OtherStreet,
        FinServ__RelatedAccount__r.PersonContact.OtherCity,
        FinServ__RelatedAccount__r.PersonContact.OtherState,
        FinServ__RelatedAccount__r.PersonContact.OtherCountry,
        FinServ__RelatedAccount__r.PersonContact.OtherPostalCode,
        FinServ__RelatedAccount__r.Advertising_Indicator__c,
        FinServ__RelatedAccount__r.OCV_Event_Version__c
      FROM Lead
      WHERE Id = :leadId
      WITH SYSTEM_MODE
    ] ?? null;
  }

  /**
   * @description getContactList method return Contacts related to lead under leadConversion
   * @param contactIds Id of the Contacts related to lead under leadConversion
   * @return List<Contact> Contact List
   */
  public List<Contact> getContactList(Set<ID> contactIds) {
    if (contactIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT id, isPersonAccount
      FROM contact
      WHERE id IN :contactIds
      WITH USER_MODE
    ];
  }

  /**
   * @description getOpportunityContactRole method return OpportunityContactRole related to lead under leadConversion
   * @param personContactsIdSet Id of the Person Contacts related to lead under leadConversion
   * @return List<OpportunityContactRole> OpportunityContactRole List
   */
  public List<OpportunityContactRole> getOpportunityContactRole(
    Set<ID> personContactsIdSet
  ) {
    if (personContactsIdSet.isEmpty()) {
      return new List<OpportunityContactRole>();
    }
    return [
      SELECT id, ContactId
      FROM OpportunityContactRole
      WHERE ContactId IN :personContactsIdSet
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description getLeadRecordForConversion return Lead record using recordId
   * @param recordId recordId of the lead
   * @return Lead returns the Lead record
   */
  public Lead getLeadRecordForConversion(ID recordId) {
    if (recordId == null) {
      return null;
    }
    return [
      SELECT
        Skip_Validations__c,
        Company,
        Name,
        FirstName,
        MiddleName,
        LastName,
        Title__c,
        Email,
        MobilePhone,
        Home_Phone__c,
        Work_Phone__c,
        AdvertisingIndicator__c,
        FinServ__ExpressedInterest__c,
        New_to_Bank__c,
        FinServ__RelatedAccount__c,
        FinServ__PotentialValue__c,
        Registered_Company__c,
        ABN__c,
        ABN_Validation_Status__c,
        ACN__c,
        ACN_Validation_Status__c,
        FinServ__RelatedAccount__r.RecordType.DeveloperName,
        RecordType.DeveloperName,
        RecordTypeId,
        LeadSource,
        OwnerId,
        Salutation,
        Gender__c,
        Address,
        Street,
        City,
        State,
        Country,
        PostalCode,
        Is_Valid_Address__c,
        CPID__c,
        Controlling_Post__c,
        Industry__c,
        Entity_Type__c,
        Lead.Industry__r.Code__c,
        Lead_Originator__c
      FROM LEAD
      WHERE ID = :recordId
      WITH SYSTEM_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description return Accounts using ExternalIds
   * @param externalId ExternalId of Account
   * @return List<Account> Account list
   */
  public Account getAccountUsingExternalId(String externalId) {
    if (String.isBlank(externalId)) {
      return null;
    }
    return [
      SELECT Id, External_Id__c, Name, FinServ__KYCStatus__c, CLG__c
      FROM Account
      WHERE External_Id__c = :externalId
      WITH SYSTEM_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Check whether the user has lead update permission
   * @return Boolean True if the lead is updatable
   */
  public Boolean isLeadCAPCISUpdatable() {
    return (Schema.sObjectType.Lead.isUpdateable() &&
    Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable() &&
    Schema.sObjectType.Lead.fields.FinServ__RelatedAccount__c.isUpdateable() &&
    Schema.sObjectType.Lead.fields.CAPCIS_ID__c.isUpdateable());
  }

  /**
   * @description return Accounts using ExternalIds
   * @param externalIds ExternalIds of Account
   * @return List<Account> Account list
   */
  public List<Account> getAccountUsingExternalIds(Set<String> externalIds) {
    if (externalIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, External_Id__c, Name, FinServ__KYCStatus__c, CLG__c
      FROM Account
      WHERE External_Id__c = :externalIds
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description return Tasks using associated to Lead id
   * @param leadID Id of the Lead
   * @return List<Task> Task List
   */
  public List<Task> getLeadTasks(ID leadID) {
    if (leadID == null) {
      return new List<Task>();
    }
    return [
      SELECT
        ID,
        Response_Type__r.Unica_Lead_SubStatus__c,
        WhoId,
        CreatedDate,
        Skip_Validations__c
      FROM Task
      WHERE WhoId = :leadID
      WITH USER_MODE
      ORDER BY CreatedDate DESC
    ];
  }

  /**
   * @description getLeadStatus method returns Lead Status associate to converted
   * @return LeadStatus Lead Status associate to converted
   */
  public LeadStatus getLeadStatus() {
    return [
      SELECT MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      WITH SYSTEM_MODE
      LIMIT 1
    ];
  }

  /**
   * @description Method to perform database covert
   * @param record lead record to convert
   * @return Database.LeadConvertResult Result of update operation
   */
  public Database.LeadConvertResult convertLeadRecord(
    Database.LeadConvert record
  ) {
    try {
      Database.LeadConvertResult result = Database.convertLead(record);
      return result;
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
    }
    Logger.saveLog();
    return null;
  }

  /**
   * @description getLeadforOpportunityCreation return Lead record using recordId
   * @param mdLeadFields lead fields from the metadata
   * @param leadId recordId of the lead
   * @return Lead returns the Lead records
   */
  public Lead getLeadforOpportunityCreation(String mdLeadFields, Id leadId) {
    if (leadId == null || String.isBlank(mdLeadFields)) {
      return null;
    }
    String defaultleadFields = System.Label.Lead_Conversion_Default_Fields;
    String leadQuery =
      'Select ' +
      String.escapeSingleQuotes(defaultleadFields) +
      String.escapeSingleQuotes(mdLeadFields) +
      ' From Lead WHERE Id = :leadId WITH SYSTEM_MODE LIMIT 1';
    return database.query(leadQuery) ?? null;
  }
}
