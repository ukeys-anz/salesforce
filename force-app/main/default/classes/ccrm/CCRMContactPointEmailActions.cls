/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description CCRMContactPointEmailActions related to handling ContactPointEmailActions object.
 * @runTests CCRMContactPointEmailActionsTest
 */
public with sharing class CCRMContactPointEmailActions {
  private static final String EMAIL_EXISTS_ERROR = 'An email record is already available for this customer. Please edit the email below.';
  private static final String INVALID_EMAIL_ERROR = 'Please enter Email in correct format.';

  /**
   * @description Copy ParentId to Customer_Name__c field.
   * @name copyParentIdToCustomerName
   * @param records from the trigger
   */
  public static void copyParentIdToCustomerName(
    List<ContactPointEmail> records
  ) {
    for (ContactPointEmail record : records) {
      if (record.ParentId != null && record.Customer_Name__c == null) {
        record.Customer_Name__c = record.ParentId;
      }
    }
  }

  /**
   * @description Unlink parent prospect account when ActiveToDate value is set
   * @name unlinkProspectParentOnDeactivation
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in beforUpdate.
   */
  public static void unlinkProspectParentOnDeactivation(
    List<ContactPointEmail> records,
    Map<Id, ContactPointEmail> oldMap
  ) {
    for (ContactPointEmail cpe : records) {
      if (oldMap.get(cpe.id).ActiveToDate == null && cpe.ActiveToDate != null) {
        cpe.ParentId = null;
      }
    }
  }

  /**
   * @description extract from a list of ContactPointEmail and return the records that are linked to prospect accounts
   * @param records the list of ContactPointEmail to check if they're belonged to prospect accounts
   * @return list of records that are linked to prospect accounts
   */
  public static List<ContactPointEmail> extractProspectCpe(
    List<ContactPointEmail> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (ContactPointEmail record : records) {
      if (record.Customer_Name__c != null) {
        accountIds.add(record.Customer_Name__c);
      }
    }

    Set<Id> prospectIds = CCRMAccountActions.extractProspectIds(accountIds);

    List<ContactPointEmail> results = new List<ContactPointEmail>();
    for (ContactPointEmail record : records) {
      if (prospectIds.contains(record.Customer_Name__c)) {
        results.add(record);
      }
    }

    return results;
  }

  /**
   * @description make sure bankers should only be able to add a new email if there is no existing email available for that Prospect
   * @param records the list of records to check
   */
  public static void checkExistingEmailOnProspect(
    List<ContactPointEmail> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (ContactPointEmail record : records) {
      if (record.Customer_Name__c != null) {
        accountIds.add(record.Customer_Name__c);
      }
    }

    Map<Id, AggregateResult> mapAccountIdToEmailCount = new Map<Id, AggregateResult>(
      [
        SELECT Customer_Name__c Id, COUNT(Id) Cnt
        FROM ContactPointEmail
        WHERE
          Customer_Name__c IN :accountIds
          AND ActiveToDate = NULL
          AND Customer_Name__r.Is_Prospect__c = TRUE
        WITH SECURITY_ENFORCED
        GROUP BY Customer_Name__c
      ]
    );

    for (ContactPointEmail record : records) {
      if (mapAccountIdToEmailCount.containsKey(record.Customer_Name__c)) {
        record.addError(EMAIL_EXISTS_ERROR);
      }
    }
  }

  /**
   * @description validate prospect's emails. This is done instead of Custom Validation Rule since these values will be reverted before Custom Validation kick in.
   * @param records the list of email record to validate
   */
  public static void validateProspectEmails(List<ContactPointEmail> records) {
    if (CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES) {
      return;
    }
    for (ContactPointEmail record : records) {
      if (
        !String.isBlank(record.EmailAddress) &&
        !Pattern.matches(Label.Regex_Email, record.EmailAddress)
      ) {
        record.addError(
          Schema.SObjectType.ContactPointEmail.fields.EmailAddress.Name,
          INVALID_EMAIL_ERROR
        );
      }
    }
  }
}
