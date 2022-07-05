/**
 * @author Adam Smith
 * @since 20220624
 * @description Class to help DML Operations for Contact Requests
 */
public with sharing class ContactRequestDMLHelper {
  /**
   * @description gets a list of contact requests based on a set of Ids
   * @param requestIds Set of Request Ids
   * @return List<ContactRequest> list of contact requests found.
   */
  public static List<ContactRequest> getContactRequest(Set<Id> requestIds) {
    List<ContactRequest> requests = new List<ContactRequest>();
    if (ContactRequest.SObjectType.getDescribe().isQueryable()) {
      requests = [
        SELECT Id, Interaction__c
        FROM ContactRequest
        WHERE Id IN :requestIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestDMLHelper',
        'getContactRequest',
        'Not enough permissions to query Contact Request.'
      );
    }
    return requests;
  }

  /**
   * @description updates a list of contact requests
   * @param requests List of Request
   */
  public static void updateContactRequests(List<ContactRequest> requests) {
    if (ContactRequest.SObjectType.getDescribe().isUpdateable()) {
      update requests;
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestDMLHelper',
        'updateContactRequests',
        'Not enough permissions to update Contact Request.'
      );
    }
  }
}
