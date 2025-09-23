/**
 * @author MLCRM Developer
 * @since 10/2024
 * @description This class provide SOQL for Contact related queries.
 */
public with sharing class ContactActionsRepository {
  /**
   * @description This method returns map of contacts by taking set of Id as input
   * @name getContactMapById
   * @param contactIds Set of Contact Ids
   * @return Map<Id, Contact> Map of Contacts
   */
  public Map<Id, Contact> getContactMapById(Set<Id> contactIds) {
    if (contactIds.isEmpty()) {
      return new Map<Id, Contact>();
    }
    return new Map<Id, Contact>(
      [
        SELECT Id, Name, Email, MobilePhone
        FROM Contact
        WHERE Id IN :contactIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description This method returns contact by taking set of Emails as input
   * @name getContactsByEmail
   * @param contactEmails Set of Contact Emails
   * @return List of Contacts
   */
  public List<Contact> getContactsByEmail(Set<String> contactEmails) {
    if (contactEmails.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT Id, Name, Email, MobilePhone
      FROM Contact
      WHERE Email IN :contactEmails
      WITH USER_MODE
    ];
  }
}
