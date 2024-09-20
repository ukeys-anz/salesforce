/**
 * @author Sanskriti Routray
 * @since  08/2024
 * @description Repository Class for the disputes related queries
 */
public with sharing class CaseDisputesRepository {
  private static final Set<Id> VALID_DISPUTE_RT_IDS_TO_UPDATE_CASE = new Set<Id>{
    RTCase.atmDispute,
    RTCase.cardDispute,
    RTCase.nppDispute
  };

  /**
   * @description Get Map of Account details By account Ids
   * @param accountIds set of account Ids
   * @return Map<Id, Account> Map of Account details
   */
  public Map<Id, Account> getAccountDetailsFromId(Set<Id> accountIds) {
    if (
      accountIds == null ||
      accountIds.isEmpty() ||
      !SObjectType.Account.isQueryable()
    ) {
      return new Map<Id, Account>();
    }
    return new Map<Id, Account>(
      [
        SELECT
          Id,
          FirstName,
          LastName,
          OCV_ID__c,
          Source_System_ID__c,
          Source_System_Name__c,
          PersonEmail,
          PersonMobilePhone
        FROM Account
        WHERE Id IN :accountIds
      ]
    );
  }

  /**
   * @description Get Map of User details By user Ids
   * @param relatedUserIds set of user Ids
   * @return Map<Id, User> Map of user details
   */
  public Map<Id, User> getUserDetailsFromId(Set<Id> relatedUserIds) {
    if (relatedUserIds.isEmpty() || !SObjectType.User.isQueryable()) {
      return new Map<Id, User>();
    }
    return new Map<Id, User>(
      [SELECT Id, Email, UserName FROM User WHERE Id IN :relatedUserIds]
    );
  }

  /**
   * @description Get list of Groups By user Ids
   * @param relatedUserOrQueueIds set of user Ids
   * @return List<Group> list of Users
   */
  public List<Group> getGroupDetails(Set<Id> relatedUserOrQueueIds) {
    if (relatedUserOrQueueIds.isEmpty() || !SObjectType.Group.isQueryable()) {
      return new List<Group>();
    }
    return [
      SELECT Id, Email, Name
      FROM Group
      WHERE Id IN :relatedUserOrQueueIds
    ];
  }

  /**
   * @description to get the NPP Cases
   * @param casesIds Set of Case Ids
   * @return List<Case> Npp case list
   */
  public List<Case> getOpenCases(List<Id> casesIds) {
    if (Schema.SObjectType.Case.isQueryable() == false || casesIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT
        Id,
        Status,
        RecordTypeId,
        RecordType.DeveloperName,
        Dispute_Reason__c
      FROM Case
      WHERE
        Id IN :casesIds
        AND Status != :GetHelpConstants.CLOSED_STATUS
        AND RecordTypeId IN :VALID_DISPUTE_RT_IDS_TO_UPDATE_CASE
    ];
  }

  /**
   * @description to get the Cases
   * @param casesIds List of Case Ids
   * @return List<Case> case list
   */
  public List<Case> getCases(Set<Id> casesIds) {
    if (Schema.SObjectType.Case.isQueryable() == false || casesIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT
        Id,
        Status,
        RecordTypeId,
        RecordType.DeveloperName,
        Dispute_Reason__c
      FROM Case
      WHERE
        Id IN :casesIds
        AND RecordTypeId IN :VALID_DISPUTE_RT_IDS_TO_UPDATE_CASE
    ];
  }
}
