/**
 *
 * @author Jasmine Nguyen
 * @since 04/2022
 * @description Helper class for AccountCommonActions
 */

public with sharing class AccountCommonActionsHelper {
  /**
   * @description revertAccountFieldChanges checks if a field has been updated and revert its value to the old value
   * @param newRec The account record from Trigger.new()
   * @param oldRec The account record from Trigger.oldMap()
   */
  public static void revertAccountFieldChanges(Account newRec, Account oldRec) {
    Map<String, Object> fieldsToValue = newRec.getPopulatedFieldsAsMap();
    for (String fieldName : fieldsToValue.keySet()) {
      if (
        isFieldUpdateable(fieldName) &&
        isFieldUpdated(fieldName, newRec, oldRec)
      ) {
        newRec.put(fieldName, oldRec.get(fieldName));
      }
    }
  }

  /**
   * @description isFieldUpdateable checks if a field is updateable
   * @param fieldName Name of the field to be check if it's updateable
   * @return Boolean Is the field updateable
   */
  private static Boolean isFieldUpdateable(String fieldName) {
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
    return fieldMap.get(fieldName).getDescribe().isUpdateable();
  }

  /**
   * @description isFieldUpdated checks if a field has been updated
   * @param fieldName Name of the field to be check if it's been updated
   * @param newRec The account record from Trigger.new()
   * @param oldRec The account record from Trigger.oldMap()
   * @return Boolean Is the field updated
   */
  private static Boolean isFieldUpdated(
    String fieldName,
    Account newRec,
    Account oldRec
  ) {
    return (newRec.get(fieldName) != oldRec.get(fieldName));
  }

  /**
   * @description findMatchingLeads finds the leads that have matching details with the newly created account
   * @param newRecs The account records from Trigger.new()
   * @return Map<Id, List<Lead>> A map fo leads to be converted and their corresponding account Ids
   */
  public static Map<Id, List<Lead>> findMatchingLeads(List<Account> newRecs) {
    Map<String, Account> accountByMobileMap = new Map<String, Account>();
    Map<String, Account> accountByEmailMap = new Map<String, Account>();
    for (Account rec : newRecs) {
      if (String.isNotBlank(rec.PersonMobilePhone)) {
        accountByMobileMap.put(rec.PersonMobilePhone, rec);
      }
      if (String.isNotBlank(rec.PersonEmail)) {
        accountByEmailMap.put(rec.PersonEmail, rec);
      }
    }

    Map<Id, List<Lead>> matchingLeadsByAccIdMap = new Map<Id, List<Lead>>();
    LeadRetriever lr = new LeadRetriever();
    for (
      Lead l : lr.getPotentialMatchingLeads(
        accountByMobileMap.keySet(),
        accountByEmailMap.keySet()
      )
    ) {
      if (
        firstNameLastNameEmailMatch(l, accountByMobileMap, accountByEmailMap) ||
        firstNameMobileEmailMatch(l, accountByMobileMap, accountByEmailMap) ||
        lastNameMobileEmailMatch(l, accountByMobileMap, accountByEmailMap)
      ) {
        putLeadsInMapByAccId(
          l,
          matchingLeadsByAccIdMap,
          accountByEmailMap.get(l.Email)
        );
      } else if (
        firstNameLastNameMobileMatch(l, accountByMobileMap, accountByEmailMap)
      ) {
        putLeadsInMapByAccId(
          l,
          matchingLeadsByAccIdMap,
          accountByMobileMap.get(l.MobilePhone)
        );
      }
    }

    return matchingLeadsByAccIdMap;
  }

  /**
   * @description firstNameMobileEmailMatch checks if a lead's firstname, mobile, email matches those of an account
   * @param l A lead record
   * @param accountByMobileMap A map of accounts and their mobile numbers
   * @param accountByEmailMap A map of accounts and their emails
   * @return Boolean If the lead's firstname, mobile, email match with the account's firstname, mobile, email
   */
  private static Boolean firstNameMobileEmailMatch(
    Lead l,
    Map<String, Account> accountByMobileMap,
    Map<String, Account> accountByEmailMap
  ) {
    return (l.FirstName.toLowerCase() ==
    accountByEmailMap.get(l.Email)?.Firstname.toLowerCase() &&
    l.FirstName.toLowerCase() ==
    accountByMobileMap.get(l.MobilePhone)?.Firstname.toLowerCase());
  }

  /**
   * @description lastNameMobileEmailMatch checks if a lead's lastname, mobile, email matches those of an account
   * @param l A lead record
   * @param accountByMobileMap A map of accounts and their mobile numbers
   * @param accountByEmailMap A map of accounts and their emails
   * @return Boolean If the lead's lastname, mobile, email match with the account's lastname, mobile, email
   */
  private static Boolean lastNameMobileEmailMatch(
    Lead l,
    Map<String, Account> accountByMobileMap,
    Map<String, Account> accountByEmailMap
  ) {
    return (l.Lastname.toLowerCase() ==
    accountByEmailMap.get(l.Email)?.Lastname.toLowerCase() &&
    l.Lastname.toLowerCase() ==
    accountByMobileMap.get(l.MobilePhone)?.Lastname.toLowerCase());
  }

  /**
   * @description firstNameLastNameMobileMatch checks if a lead's firstname, lastname, mobile matches those of an account
   * @param l A lead record
   * @param accountByMobileMap A map of accounts and their mobile numbers
   * @param accountByEmailMap A map of accounts and their emails
   * @return Boolean If the lead's firstname, lastname, mobile match with the account's firstname, lastname, mobile
   */
  private static Boolean firstNameLastNameMobileMatch(
    Lead l,
    Map<String, Account> accountByMobileMap,
    Map<String, Account> accountByEmailMap
  ) {
    return (l.FirstName.toLowerCase() ==
    accountByMobileMap.get(l.MobilePhone)?.FirstName.toLowerCase() &&
    l.Lastname.toLowerCase() ==
    accountByMobileMap.get(l.MobilePhone)?.Lastname.toLowerCase());
  }

  /**
   * @description firstNameLastNameEmailMatch checks if a lead's firstname, lastname, email matches those of an account
   * @param l A lead record
   * @param accountByMobileMap A map of accounts and their mobile numbers
   * @param accountByEmailMap A map of accounts and their emails
   * @return Boolean If the lead's firstname, lastname, email match with the account's firstname, lastname, email
   */
  private static Boolean firstNameLastNameEmailMatch(
    Lead l,
    Map<String, Account> accountByMobileMap,
    Map<String, Account> accountByEmailMap
  ) {
    return (l.FirstName.toLowerCase() ==
    accountByEmailMap.get(l.Email)?.FirstName.toLowerCase() &&
    l.Lastname.toLowerCase() ==
    accountByEmailMap.get(l.Email)?.Lastname.toLowerCase());
  }

  /**
   * @description private without sharing class to bypass lead sharing setting in lead conversion process
   */
  public without sharing class LeadRetriever {
    /**
     * @description getPotentialMatchingLeads gets a list of potential matching leads from sets of account mobile numbers and emails
     * @param mobileSet A set of mobile numbers from accounts
     * @param emailSet A set of emails from accounts
     * @return A list of potenital matching leads
     */
    private List<Lead> getPotentialMatchingLeads(
      Set<String> mobileSet,
      Set<String> emailSet
    ) {
      List<Lead> potentialMatchingLeads = [
        SELECT Id, Firstname, Lastname, MobilePhone, Email, RecordTypeId
        FROM Lead
        WHERE
          RecordTypeId = :GetHelpConstants.LEAD_ANZX_RT_ID
          AND (MobilePhone IN :mobileSet
          OR Email IN :emailSet)
          AND IsConverted = FALSE
      ];
      return potentialMatchingLeads;
    }

    /**
     * @description getPotentialMatchingLeads gets a list of potential matching leads from sets of capcis Ids
     * @param capcisIdSet A set of capcis Ids from account trigger
     * @return A list of potenital matching leads
     */
    public List<Lead> getPotentialMatchingCCRMLeads(Set<String> capcisIdSet) {
      List<Lead> potentialMatchingLeads = [
        SELECT Id, CAPCIS_ID__c, RecordTypeId
        FROM Lead
        WHERE
          RecordTypeId = :CCRMConstants.CCRM_LEAD_RT_ID
          AND CAPCIS_ID__c IN :capcisIdSet
          AND IsConverted = FALSE
          AND FinServ__RelatedAccount__c = NULL
      ];
      return potentialMatchingLeads;
    }
  }

  /**
   * @description getLeadsByAccIdMap gets a list of potential matching leads by their corresponding account Id
   * @param l The lead record to be added to the list
   * @param matchingLeadsByAccIdMap A map of leads to be converted and their corresponding account Ids
   * @param account Account record matching the lead
   * @return Map<Id, List<Lead>> A map of leads to be converted and their corresponding account Ids
   */
  public static Map<Id, List<Lead>> putLeadsInMapByAccId(
    Lead l,
    Map<Id, List<Lead>> matchingLeadsByAccIdMap,
    Account account
  ) {
    if (
      // Check if the map already contains this key
      matchingLeadsByAccIdMap.containsKey(account.Id)
    ) {
      // If yes, add the lead to the exist list
      matchingLeadsByAccIdMap.get(account.Id).add(l);
    } else {
      // If no, create a new list of leads and put this in the map by the account Id
      List<Lead> matchingLeads = new List<Lead>();
      matchingLeads.add(l);
      matchingLeadsByAccIdMap.put(account.Id, matchingLeads);
    }
    return matchingLeadsByAccIdMap;
  }

  /**
   * @description Get cases by OCV Ids or Mobile and record type
   * @param ocvIds OCV Ids
   * @param mobilePhones Mobile Phones
   * @param recordTypeId The Case record type Id
   * @return List<Case> List of Cases
   */
  public static List<Case> getCasesByOCVIdsOrMobiles(
    Set<String> ocvIds,
    Set<String> mobilePhones,
    String recordTypeId
  ) {
    if (ocvIds.isEmpty() && mobilePhones.isEmpty()) {
      return new List<Case>();
    }

    if (PermissionUtils.canQuery('Case') == false) {
      return new List<Case>();
    }

    return [
      SELECT Id, OCV_Id__c, CustomerOnboardingApplication__r.SecurityMobile__c
      FROM Case
      WHERE
        (OCV_Id__c IN :ocvIds
        OR CustomerOnboardingApplication__r.SecurityMobile__c IN :mobilePhones)
        AND RecordTypeId = :recordTypeId
        AND AccountId = NULL
    ];
  }
}
