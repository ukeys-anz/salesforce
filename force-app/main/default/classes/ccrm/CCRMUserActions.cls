/**
 * @author Mairaj H
 * @since  10/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMUserActions is class to handle all the User Actions
 */
public with sharing class CCRMUserActions {
  /**
   * @description This method gets the Lan Ids of lead owner and lead last modified user
   * @name getMapOfLanIds
   * @param leadList List of lead
   * @param isLastModifiedUser Is Last Modified User required
   * @return Map<Id, User> Return map of user with Lan Ids
   */
  public static Map<Id, User> getMapOfLanIds(
    List<Lead> leadList,
    Boolean isLastModifiedUser
  ) {
    Set<Id> leadOwnerIds = new Set<Id>();
    for (Lead record : leadList) {
      leadOwnerIds.add(
        isLastModifiedUser ? record.LastModifiedById : record.OwnerId
      );
    }
    Map<Id, User> mapOfLanId = new Map<Id, User>(
      [SELECT ID, Lan_Id__c FROM User WHERE Id IN :leadOwnerIds]
    );
    return mapOfLanId;
  }
}
