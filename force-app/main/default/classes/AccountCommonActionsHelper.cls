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
   * @return Map<Id, Lead> A map fo leads to be converted and their corresponding account Ids
   */
  @SuppressWarnings('PMD.CyclomaticComplexity, PMD.ApexCRUDViolation')
  public static Map<Id, Lead> findMatchingLeads(List<Account> newRecs) {
    Map<String, Account> accountByMobileMap = new Map<String, Account>();
    Map<String, Account> accountByEmailMap = new Map<String, Account>();
    for (Account rec : newRecs) {
      accountByMobileMap.put(rec.PersonMobilePhone, rec);
      accountByEmailMap.put(rec.PersonEmail, rec);
    }

    Map<Id, Lead> matchingLeadByAccIdMap = new Map<Id, Lead>();
    LeadRetriever lr = new LeadRetriever();
    for (
      Lead l : lr.getPotentialMatchingLeads(
        accountByMobileMap.keySet(),
        accountByEmailMap.keySet()
      )
    ) {
      if (
        firstNameLastNameEmailMatch(l, accountByMobileMap, accountByEmailMap) ||
        firstnameMobileEmailMatch(l, accountByMobileMap, accountByEmailMap) ||
        lastnameMobileEmailMatch(l, accountByMobileMap, accountByEmailMap)
      ) {
        matchingLeadByAccIdMap.put(accountByEmailMap.get(l.Email).Id, l);
      } else if (
        firstNameLastNameMobileMatch(l, accountByMobileMap, accountByEmailMap)
      ) {
        matchingLeadByAccIdMap.put(accountByMobileMap.get(l.MobilePhone).Id, l);
      }
    }

    return matchingLeadByAccIdMap;
  }

  /**
   * @description firstnameMobileEmailMatch checks if a lead's firstname, mobile, email matches those of an account
   * @param l A lead record
   * @param accountByMobileMap A map of accounts and their mobile numbers
   * @param accountByEmailMap A map of accounts and their emails
   * @return Boolean If the lead's firstname, mobile, email match with the account's firstname, mobile, email
   */
  private static Boolean firstnameMobileEmailMatch(
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
   * @description lastnameMobileEmailMatch checks if a lead's lastname, mobile, email matches those of an account
   * @param l A lead record
   * @param accountByMobileMap A map of accounts and their mobile numbers
   * @param accountByEmailMap A map of accounts and their emails
   * @return Boolean If the lead's lastname, mobile, email match with the account's lastname, mobile, email
   */
  private static Boolean lastnameMobileEmailMatch(
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
  private without sharing class LeadRetriever {
    /**
     * @description getPotentialMatchingLeads gets a list of potential matching leads from sets of account mobile numbers and emails
     * @param mobileSet A set of mobile numbers from accounts
     * @param emailSet A set of emails from accounts
     * @return A list of potenital matching leads
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private List<Lead> getPotentialMatchingLeads(
      Set<String> mobileSet,
      Set<String> emailSet
    ) {
      List<Lead> potentialMatchingLeads = [
        SELECT Id, Firstname, Lastname, MobilePhone, Email
        FROM Lead
        WHERE
          RecordTypeId = :GetHelpConstants.LEAD_ANZX_RT_ID
          AND (MobilePhone IN :mobileSet
          OR Email IN :emailSet)
      ];
      return potentialMatchingLeads;
    }
  }
}
