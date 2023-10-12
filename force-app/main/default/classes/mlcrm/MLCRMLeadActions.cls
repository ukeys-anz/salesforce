/**
 * @author Ashish Kumar
 * @since  05/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMLeadActions is class to handle all the MLCRM (Mobile Lending CRM) Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class MLCRMLeadActions {
  /**
   * @description This method to update is new flag checkbox to false during implicit update while lead creation
   * @name noLongerNewLeads
   * @param oldMap Map of old map
   * @param records List of Lead records
   * @author Ashish Kumar
   * @US CC-1609
   */
  public static void noLongerNewLeads(
    Map<Id, Lead> oldMap,
    List<Lead> records
  ) {
    for (Lead record : records) {
      if (
        record.Skip_Validations__c == oldMap.get(record.Id).Skip_Validations__c
      ) {
        record.isNewLead__c = false;
      }
    }
  }

  /**
   * @description This method to set the default value of expiry date for Manually created ML Lead
   * @name setDefaultValue
   * @param records List of Lead records
   * @author Ashish Kumar
   * @US CC-1057
   */
  public static void setDefaultValue(List<Lead> records) {
    for (Lead objLead : records) {
      if (
        CCRMLeadUtil.isMLCRMLeadType(objLead) &&
        objLead.Lead_Originator__c == 'MLCRM'
      ) {
        String dayName = DateTimeUtils.getDay(
          System.today()
            .addDays(Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate))
        );
        switch on dayName {
          when 'Sat' {
            objLead.Expiry_Date__c = System.today()
              .addDays(
                Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate) + 2
              );
          }
          when 'Sun' {
            objLead.Expiry_Date__c = System.today()
              .addDays(
                Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate) + 1
              );
          }
          when else {
            objLead.Expiry_Date__c = System.today()
              .addDays(Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate));
          }
        }
      }
    }
  }

  /**
   * @description This method prefill Referrer when Referrer Email is populated or changed
   * @name externalReferrerPrefill
   * @param records List of lead records
   * @param oldMap Mao of old lead records
   * author Ankit Garg
   * @US CC-3672
   */
  public static void externalReferrerPrefill(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    Set<String> extReferrerEmails = new Set<String>();
    Set<Id> extReferrerIds = new Set<Id>();
    List<Lead> referredEmailLeads = new List<Lead>();
    List<Lead> referredLeads = new List<Lead>();
    Map<String, Contact> contactEmailMap = new Map<String, Contact>();
    Map<Id, Contact> contactMap = new Map<Id, Contact>();

    //filter all the ML leads for which Internal Referral or Referrer Email is changed
    for (Lead record : records) {
      if (
        CCRMLeadUtil.isMLCRMLeadType(record) &&
        String.isNotBlank(record.FinServ__ReferredByContact__c) &&
        (oldMap == null ||
        record.FinServ__ReferredByContact__c !=
        oldMap.get(record.id).FinServ__ReferredByContact__c)
      ) {
        extReferrerIds.add(record.FinServ__ReferredByContact__c);
        referredLeads.add(record);
      } else if (
        CCRMLeadUtil.isMLCRMLeadType(record) &&
        String.isNotBlank(record.Referrer_Email__c) &&
        record.LeadSource.equals(MLCRMConstants.EXTERNAL_REFERRAL) &&
        (oldMap == null ||
        record.Referrer_Email__c != oldMap.get(record.id).Referrer_Email__c)
      ) {
        extReferrerEmails.add(record.Referrer_Email__c);
        referredEmailLeads.add(record);
      }
    }

    if (
      !extReferrerEmails.isEmpty() && Schema.sObjectType.Contact.isQueryable()
    ) {
      contactEmailMap = getExternalReferrerContacts(extReferrerEmails);
    }
    if (!extReferrerIds.isEmpty() && Schema.sObjectType.Contact.isQueryable()) {
      contactMap = getExternalReferrerContacts(extReferrerIds);
    }
    if (
      !referredLeads.isEmpty() &&
      Schema.sObjectType.Lead.fields.Referrer_Email__c.isUpdateable()
    ) {
      populateExternalReferrerDetails(referredLeads, contactMap);
    }
    if (
      !referredEmailLeads.isEmpty() &&
      Schema.sObjectType.Lead.fields.FinServ__ReferredByContact__c.isUpdateable()
    ) {
      populateExternalReferrer(referredEmailLeads, contactEmailMap);
    }
  }
  /**
   * @description This method to query contacts matching with Referrer Emails
   * @name getExternalReferrerContacts
   * @param referrerEmails Set of Email Ids
   * @return contactEmailMap Map<String,Contact>()
   * @author Ankit Garg
   * @US CC-3672
   */
  private static Map<String, Contact> getExternalReferrerContacts(
    Set<String> referrerEmails
  ) {
    Map<String, Contact> contactEmailMap = new Map<String, Contact>();
    //query contacts matching with Referrer Emails
    for (Contact refContact : [
      SELECT Id, Name, Email, MobilePhone
      FROM Contact
      WHERE Email = :referrerEmails
    ]) {
      if (!contactEmailMap.containsKey(refContact.Email)) {
        contactEmailMap.put(refContact.Email, refContact);
      }
    }
    return contactEmailMap;
  }

  /**
   * @description This method to query contacts matching with Referrer Contact Ids
   * @name getExternalReferrerContacts
   * @param referrerIds Set of Contact Ids
   * @return contactMap Map<Id,Contact>()
   * @author Ankit Garg
   * @US CC-3672
   */
  private static Map<Id, Contact> getExternalReferrerContacts(
    Set<Id> referrerIds
  ) {
    //query contacts matching with Internal Referrer Ids
    Map<Id, Contact> contactMap = new Map<Id, Contact>(
      [SELECT Id, Name, Email, MobilePhone FROM Contact WHERE Id = :referrerIds]
    );
    return contactMap;
  }

  /**
   * @description This method to populate Referrer Email and Referrer Name
   * @name populateExternalReferrerDetails
   * @param referredLeads List of Lead records
   * @param contactMap Map of Contacts
   * @author Ankit Garg
   * @US CC-3672
   */
  private static void populateExternalReferrerDetails(
    List<Lead> referredLeads,
    Map<Id, Contact> contactMap
  ) {
    for (Lead record : referredLeads) {
      if (
        record.FinServ__ReferredByContact__c != null &&
        !contactMap.isEmpty() &&
        contactMap.containsKey(record.FinServ__ReferredByContact__c)
      ) {
        record.Referrer_Email__c = contactMap.get(
            record.FinServ__ReferredByContact__c
          )
          .Email;
        record.Referrer_Name__c = contactMap.get(
            record.FinServ__ReferredByContact__c
          )
          .Name;
        record.Referrer_Phone__c = contactMap.get(
            record.FinServ__ReferredByContact__c
          )
          .MobilePhone;
      }
    }
  }
  /**
   * @description This method to populate Internal Referrer and Referrer Name
   * @name populateReferrer
   * @param referredLeads List of Lead records
   * @param contactEmailMap Map of email with Contacts
   * @author Ankit Garg
   * @US CC-3672
   */
  private static void populateExternalReferrer(
    List<Lead> referredLeads,
    Map<String, Contact> contactEmailMap
  ) {
    for (Lead record : referredLeads) {
      if (
        record.Referrer_Email__c != null &&
        !contactEmailMap.isEmpty() &&
        contactEmailMap.containsKey(record.Referrer_Email__c)
      ) {
        record.FinServ__ReferredByContact__c = contactEmailMap.get(
            record.Referrer_Email__c
          )
          .Id;
        record.Referrer_Name__c = contactEmailMap.get(record.Referrer_Email__c)
          .Name;
        record.Referrer_Phone__c = contactEmailMap.get(record.Referrer_Email__c)
          .MobilePhone;
      } else {
        record.FinServ__ReferredByContact__c = null;
      }
    }
  }

  /**
   * @description This method to set the primary franchise owner on lead
   * @name populatePrimaryFranchise
   * @param lstOfLead List of Lead records
   * @param oldMap old Map of Lead records
   * @author Ashish Kumar
   * @US CC-1550
   */
  public static void populatePrimaryFranchise(
    List<Lead> lstOfLead,
    Map<Id, Lead> oldMap
  ) {
    Set<Id> idsOfTerritory = new Set<Id>();
    for (Lead objLead : lstOfLead) {
      if (
        objLead.RecordTypeId == MLCRMConstants.MLCRM_LEAD_RT_ID &&
        oldMap != null &&
        objLead.Territory__c != oldMap.get(objLead.Id).Territory__c
      ) {
        idsOfTerritory.add(objLead.Territory__c);
      }
    }
    if (!idsOfTerritory.isEmpty()) {
      Map<Id, Territory__c> mapOfUserToTerritory;
      //getting list of territory records
      List<Territory__c> lstOfTerritory = [
        SELECT Primary_Franchise_Owner__c
        FROM Territory__c
        WHERE Id IN :idsOfTerritory
      ];
      if (!lstOfTerritory.isEmpty()) {
        mapOfUserToTerritory = new Map<Id, Territory__c>();
        for (Territory__c objTerritory : lstOfTerritory) {
          mapOfUserToTerritory.put(objTerritory.Id, objTerritory);
        }
      }

      for (Lead objLead : lstOfLead) {
        if (
          objLead.RecordTypeId == MLCRMConstants.MLCRM_LEAD_RT_ID &&
          mapOfUserToTerritory.containsKey(objLead.Territory__c)
        ) {
          objLead.Primary_Franchise_Owner__c = mapOfUserToTerritory.get(
              objLead.Territory__c
            )
            .Primary_Franchise_Owner__c;
        }
      }
    }
  }
}
