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
}
