/**
 * @author Tan Phan
 * @since  09/2022
 * @description CCRMContactActions is the class to handle all the CCRM (Commercial CRM) Actions related to Contact object
 * @runTests CCRMContactActionsTest
 */
public with sharing class CCRMContactActions {
  private static final String MAX_CONTACT_PER_ORG_ERROR = 'Unable to add more than 10 Contacts per Organisation.';
  private static final String INVALID_MOBILE_ERROR = 'Please enter Mobile Number in +61412345678 format.';
  private static final String INVALID_PHONE_ERROR = 'Please enter Work Phone Number in +61212345678 format.';
  private static final String INVALID_EMAIL_ERROR = 'Please enter Email in correct format.';
  private static final String CONTACT_METHOD_ERROR = 'At least one type of contact method must be provided.';

  /**
   * @description extract from a list of contact and return the records that are linked to prospect accounts
   * @param records the list of contacts to check if they're belonged to prospect accounts
   * @return list of records that are linked to prospect accounts
   */
  public static List<Contact> extractProspectContacts(List<Contact> records) {
    Set<Id> accountIds = new Set<Id>();
    for (Contact record : records) {
      if (record.AccountId != null) {
        accountIds.add(record.AccountId);
      }
    }

    Set<Id> prospectIds = CCRMAccountActions.extractProspectIds(accountIds);

    List<Contact> results = new List<Contact>();
    for (Contact record : records) {
      if (
        prospectIds.contains(record.AccountId) &&
        record.RecordTypeId == CCRMConstants.CONTACT_BUSINESS_RT_ID
      ) {
        results.add(record);
      }
    }

    return results;
  }

  /**
   * @description validate prospect's contact phones. This is done instead of Custom Validation Rule since these values will be reverted before Custom Validation kick in.
   * @param records the list of contacts validate
   */
  public static void validateProspectContacts(List<Contact> records) {
    if (CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES) {
      return;
    }
    for (Contact record : records) {
      if (
        !String.isBlank(record.Phone) &&
        !Pattern.matches(Label.Regex_Phone, record.Phone)
      ) {
        record.addError('Phone', INVALID_PHONE_ERROR);
      }
      if (
        !String.isBlank(record.MobilePhone) &&
        !Pattern.matches(Label.Regex_Mobile, record.MobilePhone)
      ) {
        record.addError('MobilePhone', INVALID_MOBILE_ERROR);
      }
      if (
        !String.isBlank(record.Email) &&
        !Pattern.matches(Label.Regex_Email, record.Email)
      ) {
        record.addError('Email', INVALID_EMAIL_ERROR);
      }
      if (
        String.isBlank(record.Phone) &&
        String.isBlank(record.MobilePhone) &&
        String.isBlank(record.Fax)
      ) {
        record.addError(CONTACT_METHOD_ERROR);
      }
    }
  }

  /**
   * @description make sure bankers can only add up to 10 Commercial Contact records per organisation record
   * @name checkMaxContactsPerOrganisation
   * @param records The records to check
   */
  public static void checkMaxContactsPerOrganisation(List<Contact> records) {
    Set<Id> accountIds = new Set<Id>();
    for (Contact record : records) {
      if (record.AccountId != null) {
        accountIds.add(record.AccountId);
      }
    }

    Map<Id, AggregateResult> mapAccountIdToContactCount = new Map<Id, AggregateResult>(
      [
        SELECT AccountId Id, COUNT(Id) Cnt
        FROM Contact
        WHERE AccountId IN :accountIds AND Account.Is_Prospect__c = TRUE
        WITH SECURITY_ENFORCED
        GROUP BY AccountId
      ]
    );

    for (Contact record : records) {
      if (
        mapAccountIdToContactCount.containsKey(record.AccountId) &&
        Integer.valueOf(
          mapAccountIdToContactCount.get(record.AccountId).get('Cnt')
        ) >= 10
      ) {
        record.addError(MAX_CONTACT_PER_ORG_ERROR);
      }
    }
  }
}
