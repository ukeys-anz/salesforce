/**
 * @author Hitesh Wasdani
 * @since 07/2024
 * @description This class provide SOQL and DML helper for class related to CCRMLeadConversionActions and CCRMLeadConversionActionsHelper.
 * without sharing: used to bypass lead sharing setting in lead conversion process
 */
public without sharing class LeadConversionActionsRepository {
  /**
   * @description getContactList method return Contacts related to lead under leadConversion
   * @param contactIds Id of the Contacts related to lead under leadConversion
   * @return List<Contact> Contact List
   */
  public List<Contact> getContactList(Set<ID> contactIds) {
    if (!Schema.sObjectType.Contact.isQueryable()) {
      return new List<Contact>();
    }
    if (contactIds.isEmpty()) {
      return new List<Contact>();
    }
    return [SELECT id, isPersonAccount FROM contact WHERE id IN :contactIds];
  }

  /**
   * @description getOpportunityContactRole method return OpportunityContactRole related to lead under leadConversion
   * @param personContactsIdSet Id of the Person Contacts related to lead under leadConversion
   * @return List<OpportunityContactRole> OpportunityContactRole List
   */
  public List<OpportunityContactRole> getOpportunityContactRole(
    Set<ID> personContactsIdSet
  ) {
    if (!Schema.sObjectType.OpportunityContactRole.isQueryable()) {
      return new List<OpportunityContactRole>();
    }
    if (personContactsIdSet.isEmpty()) {
      return new List<OpportunityContactRole>();
    }
    return [
      SELECT id, ContactId
      FROM OpportunityContactRole
      WHERE ContactId IN :personContactsIdSet
    ];
  }

  /**
   * @description getLeadRecordForConversion return Lead record using recordId
   * @param recordId recordId of the lead
   * @return Lead returns the Lead record
   */
  public Lead getLeadRecordForConversion(ID recordId) {
    if (!Schema.sObjectType.Lead.isQueryable()) {
      return null;
    }
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
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description return Accounts using ExternalIds
   * @param externalId ExternalId of Account
   * @return List<Account> Account list
   */
  public List<Account> getAccountUsingExternalId(String externalId) {
    if (
      !Schema.sObjectType.Account.isQueryable() || String.isBlank(externalId)
    ) {
      return null;
    }
    return [
      SELECT Id, External_Id__c, Name, FinServ__KYCStatus__c, CLG__c
      FROM Account
      WHERE External_Id__c = :externalId
      LIMIT 1
    ];
  }

  /**
   * @description This method to query lead details along with customer details
   * @name getLeadsWithCustomerDetails
   * @param leadId Set of Lead Ids
   * @return Lead
   * @US CC-4429
   */
  public Lead getLeadsWithCustomerDetails(Id leadId) {
    if (!Schema.sObjectType.Lead.isQueryable() || leadId == null) {
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
        FinServ__RelatedAccount__r.PersonContact.MobilePhone,
        FinServ__RelatedAccount__r.PersonContact.Email,
        FinServ__RelatedAccount__r.PersonContact.OtherStreet,
        FinServ__RelatedAccount__r.PersonContact.OtherCity,
        FinServ__RelatedAccount__r.PersonContact.OtherState,
        FinServ__RelatedAccount__r.PersonContact.OtherCountry,
        FinServ__RelatedAccount__r.PersonContact.OtherPostalCode,
        FinServ__RelatedAccount__r.Advertising_Indicator__c
      FROM Lead
      WHERE Id = :leadId
    ];
  }
}
