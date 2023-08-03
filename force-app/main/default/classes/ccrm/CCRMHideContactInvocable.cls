/**
 * @author Tan Phan
 * @since 03/2023
 * @description Invocable action class to check and hide expired commercial contacts and related contact point records
 * - without sharing: running user is "Automated Process" which needs to access all contacts and contact point object records
 * @runTests CCRMHideContactInvocableTest
 */
public without sharing class CCRMHideContactInvocable {
  private static final Set<String> CONTACT_POINT_OBJECTS = new Set<String>{
    Schema.SObjectType.ContactPointAddress.Name,
    Schema.SObjectType.ContactPointEmail.Name,
    Schema.SObjectType.ContactPointPhone.Name
  };

  /**
   * @description Invocable action method to check and hide expired commercial contacts and related contact point records
   */
  @InvocableMethod(
    label='Hide contacts / contact point records'
    description='Hide contacts / contact point records by setting record type to "Hidden"'
  )
  public static void hideContactsInvocable() {
    hideExpiredContacts();
    hideExpiredContactPoints();
  }

  private static void hideExpiredContacts() {
    List<Contact> contactsToUpdate = getExpiredContacts();

    if (!contactsToUpdate.isEmpty()) {
      CCRMContactActions.hideContacts(contactsToUpdate);
      DMLUtil.updateRecords(contactsToUpdate, true, false);
    }
  }

  private static void hideExpiredContactPoints() {
    List<SObject> contactPointsToUpdate = new List<SObject>();
    contactPointsToUpdate.addAll(getExpiredContactPointAddresses());
    contactPointsToUpdate.addAll(getExpiredContactPointEmails());
    contactPointsToUpdate.addAll(getExpiredContactPointPhones());

    if (!contactPointsToUpdate.isEmpty()) {
      CCRMContactPointActions.hideContactPoints(contactPointsToUpdate);
      DMLUtil.updateRecords(contactPointsToUpdate, true, false);
    }
  }

  private static List<Contact> getExpiredContacts() {
    return [
      SELECT Id, RecordTypeId
      FROM Contact
      WHERE
        Active_To__c < TODAY
        AND RecordTypeId = :CCRMConstants.CONTACT_BUSINESS_RT_ID
    ];
  }

  private static List<ContactPointAddress> getExpiredContactPointAddresses() {
    return [
      SELECT Id, ParentId
      FROM ContactPointAddress
      WHERE ParentId != NULL AND ActiveToDate < TODAY
    ];
  }

  private static List<ContactPointEmail> getExpiredContactPointEmails() {
    return [
      SELECT Id, ParentId
      FROM ContactPointEmail
      WHERE ParentId != NULL AND ActiveToDate < TODAY
    ];
  }

  private static List<ContactPointPhone> getExpiredContactPointPhones() {
    return [
      SELECT Id, ParentId
      FROM ContactPointPhone
      WHERE ParentId != NULL AND ActiveToDate < TODAY
    ];
  }
}
