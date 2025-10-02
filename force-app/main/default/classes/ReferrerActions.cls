/**
 * @author Ashwin Mohan
 * @since  10/2024
 * @description Class to populate referrer details while updating lead or opportunity
 */
public with sharing class ReferrerActions {
  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );
  private static final ContactActionsRepository CONTACT_REPOSITORY = (ContactActionsRepository) Lib_InstanceProvider.forType(
    ContactActionsRepository.class
  );
  private static final String INTERNAL_REFERRAL = 'Internal Referral';
  private static final String EXTERNAL_REFERRAL = 'External Referral';

  /**
   * @description This method prefill Referrer when Referrer Email is populated or changed
   * @name referrerPrefill
   * @param records List of sObject records
   * @param oldMap Map of old sObject records
   */
  public static void referrerPrefill(
    List<sObject> records,
    Map<Id, sObject> oldMap
  ) {
    List<SObject> filteredRecords = filterRecords(records, oldMap);
    Set<Id> internalReferrerIds = getReferrerIds(
      filteredRecords,
      oldMap,
      'FinServ__ReferredByUser__c'
    );
    Set<Id> externalReferrerIds = getReferrerIds(
      filteredRecords,
      oldMap,
      'FinServ__ReferredByContact__c'
    );
    List<SObject> emailUpdRecords = getUpdatedEmailRecords(
      filteredRecords,
      oldMap
    );
    Set<String> internalReferrerEmails = getReferrerEmails(
      emailUpdRecords,
      INTERNAL_REFERRAL
    );
    Set<String> externalReferrerEmails = getReferrerEmails(
      emailUpdRecords,
      EXTERNAL_REFERRAL
    );
    populateInternalReferrerByEmail(internalReferrerEmails, emailUpdRecords);
    populateExternalReferrerByEmail(externalReferrerEmails, emailUpdRecords);
    populateInternalReferrerByLookupId(internalReferrerIds, filteredRecords);
    populateExternalReferrerByLookupId(externalReferrerIds, filteredRecords);
  }

  /**
   * @description This method to filter ML Leads and opportunities
   * @name filterRecords
   * @param records List of sObject records
   * @param oldMap Map of old records in trigger
   * @return List<SObject> set of leads and opportunity of ML Recordtype
   */
  @TestVisible
  private static List<SObject> filterRecords(
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    Map<SObjectField, ID> recordTypeIdMap = new Map<SObjectField, ID>{
      Lead.RecordTypeId => RTLead.mlcrmLead,
      Opportunity.RecordTypeId => RTOpportunity.mlOpportunity
    };
    SObjectField recordTypeIdfield = CommonUtil.getSObjectField(
      records[0],
      'RecordTypeId'
    );
    List<SObject> filteredRecords = ListUtil.filter(records)
      .equals(recordTypeIdfield, recordTypeIdMap.get(recordTypeIdfield))
      .toList();
    if (
      oldMap != null ||
      filteredRecords.getSObjectType().toString() == 'Lead'
    ) {
      return filteredRecords;
    }
    // filtering out newly converted opportunities as they should have referrer details same as lead
    return ListUtil.filter(filteredRecords)
      .equals(Opportunity.Lead_Converted__c, false)
      .toList();
  }

  /**
   * @description This method to get Referrer Ids either internal or external
   * @name getReferrerIds
   * @param records List of sObject records
   * @param oldMap Map of old sObject records
   * @param fieldName Lookup Field Name
   * @return Set<Id> set of internal or external referrer Ids
   */
  @TestVisible
  private static Set<Id> getReferrerIds(
    List<SObject> records,
    Map<Id, SObject> oldMap,
    String fieldName
  ) {
    if (records.isEmpty()) {
      return new Set<Id>();
    }
    SObjectField referrerField = CommonUtil.getSObjectField(
      records[0],
      fieldName
    );
    List<SObject> referrerSobjects = ListUtil.filter(records, oldMap)
      .notEquals(referrerField, null)
      .changed(referrerField)
      .toList();
    return ListUtil.getIds(referrerSobjects, referrerField);
  }

  /**
   * @description This method to get records whose email has been updated
   * @name getUpdatedEmailRecords
   * @param records List of sObject records
   * @param oldMap Map of old sObject records
   * @return List<SObject> List of leads/opportunities
   */
  @TestVisible
  private static List<SObject> getUpdatedEmailRecords(
    List<SObject> records,
    Map<Id, SObject> oldMap
  ) {
    if (records.isEmpty()) {
      return new List<SObject>();
    }
    SObjectField referrerEmailfield = CommonUtil.getSObjectField(
      records[0],
      'Referrer_Email__c'
    );
    return ListUtil.filter(records, oldMap)
      .notEquals(referrerEmailfield, null)
      .changed(referrerEmailfield)
      .toList();
  }

  /**
   * @description This method to get referrer emails whose lead source is either internal or external
   * @name getReferrerEmails
   * @param emailUpdRecords List of sObject records
   * @param referralType String of Referral Type
   * @return Set<String> Set of emails
   */
  @TestVisible
  private static Set<String> getReferrerEmails(
    List<SObject> emailUpdRecords,
    String referralType
  ) {
    if (emailUpdRecords.isEmpty()) {
      return new Set<String>();
    }
    SObjectField leadSourceField = CommonUtil.getSObjectField(
      emailUpdRecords[0],
      'LeadSource'
    );
    SObjectField referrerEmailField = CommonUtil.getSObjectField(
      emailUpdRecords[0],
      'Referrer_Email__c'
    );
    List<SObject> getReferrerEmails = ListUtil.filter(emailUpdRecords)
      .equals(leadSourceField, referralType)
      .toList();
    return ListUtil.getStrings(getReferrerEmails, referrerEmailField);
  }

  /**
   * @description This method to populate internal referrer using referrer email
   * @name populateInternalReferrerByEmail
   * @param internalReferrerEmails Set of referrer emails
   * @param referrerEmailSobject List of sObject records
   */
  @TestVisible
  private static void populateInternalReferrerByEmail(
    Set<String> internalReferrerEmails,
    List<sObject> referrerEmailSobject
  ) {
    if (internalReferrerEmails.isEmpty()) {
      return;
    }
    Map<String, SObject> userEmailMap = (Map<String, SObject>) ListUtil.mapBy(
      USER_REPOSITORY.getUsersFromEmailIds(internalReferrerEmails),
      User.Email
    );
    for (SObject objSobject : referrerEmailSobject) {
      String userEmail = (String) objSobject.get('Referrer_Email__c');
      if (userEmail == null || !userEmailMap.containsKey(userEmail)) {
        continue;
      }
      objSobject.put(
        'FinServ__ReferredByUser__c',
        userEmailMap.get(userEmail).get('Id')
      );
      objSobject.put(
        'Referrer_Name__c',
        userEmailMap.get(userEmail).get('Name')
      );
    }
  }

  /**
   * @description This method to populate external referrer using referrer email
   * @name populateExternalReferrerByEmail
   * @param externalReferrerEmails Set of referrer emails
   * @param referrerEmailSobject List of sObject records
   */
  @TestVisible
  private static void populateExternalReferrerByEmail(
    Set<String> externalReferrerEmails,
    List<sObject> referrerEmailSobject
  ) {
    if (externalReferrerEmails.isEmpty()) {
      return;
    }
    Map<String, SObject> contactEmailMap = (Map<String, SObject>) ListUtil.mapBy(
      CONTACT_REPOSITORY.getContactsByEmail(externalReferrerEmails),
      Contact.Email
    );
    for (SObject objSobject : referrerEmailSobject) {
      String conEmail = (String) objSobject.get('Referrer_Email__c');
      if (conEmail == null || !contactEmailMap.containsKey(conEmail)) {
        continue;
      }
      objSobject.put(
        'FinServ__ReferredByContact__c',
        contactEmailMap.get(conEmail).get('Id')
      );
      objSobject.put(
        'Referrer_Name__c',
        contactEmailMap.get(conEmail).get('Name')
      );
      objSobject.put(
        'Referrer_Phone__c',
        contactEmailMap.get(conEmail).get('MobilePhone')
      );
    }
  }

  /**
   * @description This method to populate internal referrer using lookup Ids
   * @name populateInternalReferrerByLookupId
   * @param internalReferrerIds Set of referrer lookup Ids
   * @param referrerEmailSobject List of sObject records
   */
  @TestVisible
  private static void populateInternalReferrerByLookupId(
    Set<Id> internalReferrerIds,
    List<sObject> referrerEmailSobject
  ) {
    if (internalReferrerIds.isEmpty()) {
      return;
    }
    Map<Id, User> userMap = USER_REPOSITORY.getUserMapFromUserIds(
      internalReferrerIds
    );
    for (SObject objSobject : referrerEmailSobject) {
      String userId = (String) objSobject.get('FinServ__ReferredByUser__c');
      if (userId == null || !userMap.containsKey(userId)) {
        continue;
      }
      objSobject.put('Referrer_Email__c', userMap.get(userId).get('Email'));
      objSobject.put('Referrer_Name__c', userMap.get(userId).get('Name'));
    }
  }

  /**
   * @description This method to populate external referrer using lookup Ids
   * @name populateExternalReferrerByLookupId
   * @param externalReferrerIds Set of referrer lookup Ids
   * @param referrerEmailSobject List of sObject records
   */
  @TestVisible
  private static void populateExternalReferrerByLookupId(
    Set<Id> externalReferrerIds,
    List<sObject> referrerEmailSobject
  ) {
    if (externalReferrerIds.isEmpty()) {
      return;
    }
    Map<Id, Contact> contactMap = CONTACT_REPOSITORY.getContactMapById(
      externalReferrerIds
    );
    for (SObject objSobject : referrerEmailSobject) {
      String conId = (String) objSobject.get('FinServ__ReferredByContact__c');
      if (conId == null || !contactMap.containsKey(conId)) {
        continue;
      }
      objSobject.put('Referrer_Email__c', contactMap.get(conId).get('Email'));
      objSobject.put('Referrer_Name__c', contactMap.get(conId).get('Name'));
      objSobject.put(
        'Referrer_Phone__c',
        contactMap.get(conId).get('MobilePhone')
      );
    }
  }
}
