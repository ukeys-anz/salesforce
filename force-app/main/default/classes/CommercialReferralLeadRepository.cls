/**
 * @author       : Advait Yermalkar
 * @since        : 02-25-2025
 * @description  :  This class containspublic repository for all queries used in InteractionCEController
 **/
public with sharing class CommercialReferralLeadRepository {
  private static final String LEAD_OUTCOME_REFERRED = 'Referred';

  /**
   * @description get Customers data based on Ids
   * @param relatedCustomerIds
   * @return List<Account>
   **/
  public List<Account> getCustomers(Set<id> relatedCustomerIds) {
    if (relatedCustomerIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        Name,
        Source_System_ID__c,
        Source_System_Name__c,
        OCV_ID__c,
        RecordTypeId
      FROM Account
      WHERE Id IN :relatedCustomerIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get the user records based on Ids
   * @param relatedUserIds
   * @return List<User>
   **/
  public List<User> getUsers(Set<Id> relatedUserIds) {
    if (relatedUserIds.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, Email, UserName, Lan_Id__c
      FROM User
      WHERE Id IN :relatedUserIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get the parent lead info
   * @param parentLeadsIdsSet
   * @return List<Lead>
   **/
  public List<Lead> fetchParentLeads(Set<Id> parentLeadsIdsSet) {
    if (parentLeadsIdsSet.isEmpty()) {
      return new List<Lead>();
    }

    return [
      SELECT Id, Status, Lead_Outcome__c
      FROM Lead
      WHERE
        Id IN :parentLeadsIdsSet
        AND RecordTypeId = :RTLead.commercialLead
        AND Lead_Outcome__c != :LEAD_OUTCOME_REFERRED
      WITH USER_MODE
    ];
  }

  /**
   * @description get Manager Info
   * @param ownerIdSet set of Lead owner ids
   * @return List<User> User list
   **/
  public List<User> getManagerInfo(Set<Id> ownerIdSet) {
    if (ownerIdSet.isEmpty()) {
      return new List<User>();
    }

    return [
      SELECT Id, ManagerId, IsActive
      FROM User
      WHERE IsActive = TRUE AND Id IN :ownerIdSet AND ManagerId != NULL
      WITH USER_MODE
    ];
  }

  /**
   * @description get Queue member list
   * @param setOfGroups Set of Groups as lead owners
   * @return List<GroupMember> group member list
   **/
  public List<GroupMember> getQueueMembers(Set<Id> setOfGroups) {
    if (setOfGroups.isEmpty()) {
      return new List<GroupMember>();
    }
    return [
      SELECT Id, GroupId, UserOrGroupId, UserOrGroup.Name, UserOrGroup.IsActive
      FROM GroupMember
      WHERE UserOrGroup.IsActive = TRUE AND GroupId IN :setOfGroups
      WITH USER_MODE
    ];
  }

  /**
   * @description It will fetch the user Profile Id
   * @param customerIds set of Customer Ids
   * @return List<Account> Account List
   */
  public List<Account> getAccountRecords(Set<Id> customerIds) {
    if (customerIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, Finserv__Status__c
      FROM Account
      WHERE Id IN :customerIds AND Finserv__Status__c = 'Prospect'
      WITH USER_MODE
    ];
  }
}
