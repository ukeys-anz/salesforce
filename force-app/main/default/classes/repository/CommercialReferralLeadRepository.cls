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
      SELECT Id, Email, UserName, Lan_Id__c, FirstName, LastName
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

  /**
   * @description It will fetch all permission set Ids having custom permission assigned
   * @param customPermission name of custom permission
   * @return List<SetupEntityAccess>
   */
  public List<SetupEntityAccess> getPermissionSetWithCustomPermission(
    String customPermission
  ) {
    if (customPermission == null) {
      return new List<SetupEntityAccess>();
    }
    return [
      SELECT ParentId
      FROM SetupEntityAccess
      WHERE
        SetupEntityId IN (
          SELECT Id
          FROM CustomPermission
          WHERE DeveloperName = :customPermission
        )
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description It will fetch all permission set groups containing mentioned permission sets
   * @param permissionSetWithCustomPermission permission set Ids having custom permission assigned
   * @return List<PermissionSetGroupComponent>
   */
  public List<PermissionSetGroupComponent> getPermissionSetGroupFromPS(
    Set<Id> permissionSetWithCustomPermission
  ) {
    if (permissionSetWithCustomPermission.isEmpty()) {
      return new List<PermissionSetGroupComponent>();
    }
    return [
      SELECT PermissionSetGroupId
      FROM PermissionSetGroupComponent
      WHERE PermissionSetId IN :permissionSetWithCustomPermission
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description It will fetch all users having assinged to permission set groups
   * @param userIdSet set of ownerIds of lead
   * @param permissionSetWithCustomPermission permission set Ids having custom permission assigned
   * @param permissionSetGroupFromPS permission set groups containing mentioned permission sets
   * @return List<PermissionSetAssignment>
   */
  public List<PermissionSetAssignment> listOfUsersHavingCustomPermission(
    Set<Id> userIdSet,
    Set<Id> permissionSetWithCustomPermission,
    Set<Id> permissionSetGroupFromPS
  ) {
    if (
      permissionSetGroupFromPS.isEmpty() ||
      userIdSet.isEmpty() ||
      permissionSetWithCustomPermission.isEmpty()
    ) {
      return new List<PermissionSetAssignment>();
    }
    return [
      SELECT AssigneeId
      FROM PermissionSetAssignment
      WHERE
        IsActive = TRUE
        AND (PermissionSetId IN :permissionSetWithCustomPermission
        OR PermissionSetGroupId IN :permissionSetGroupFromPS)
        AND AssigneeId IN :userIdSet
      WITH SYSTEM_MODE
    ] ?? new List<PermissionSetAssignment>();
  }

  /**
   * @description It will fetch all the ccrm users
   * @param userIds set of user ids
   * @return List<User>
   */
  public List<User> getCCRMUsers(Set<Id> userIds) {
    if (userIds.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, Profile.Name
      FROM User
      WHERE Id IN :userIds AND Profile.Name = 'ANZ CCRM Standard User'
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description Fetch leads by Id for reprocessing logic
   * @param leadIds Set of Lead Ids
   * @return List<Lead>
   **/
  public List<Lead> getLeadsById(Set<Id> leadIds) {
    if (leadIds.isEmpty()) {
      return new List<Lead>();
    }
    return [
      SELECT
        Id,
        RecordTypeId,
        Referral_Status__c,
        External_Referral_Status__c,
        OwnerId,
        FinServ__ReferredByUser__c,
        Note__c,
        Channel__c,
        Referral_Category__c,
        FinServ__ExpressedInterest__c,
        FinServ__RelatedAccount__c,
        Customer_ID__c,
        Email,
        Work_Phone__c,
        Primary_Contact_Method__c,
        Lead_Auto_Number__c,
        LastName,
        MiddleName,
        FirstName,
        Company,
        LastModifiedDate,
        Referral_Customer_Needs__c,
        MobilePhone,
        Home_Phone__c,
        FinServ__PotentialValue__c
      FROM Lead
      WHERE Id IN :leadIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch existing lead shares for given leads Ids and referred users Ids
   * @param leadIds Set of Lead Ids
   * @param intRefIdsSet Set of Internal referred user Ids
   * @return List<LeadShare>
   */
  public List<LeadShare> getExistingLeadShare(
    Set<Id> leadIds,
    Set<Id> intRefIdsSet
  ) {
    if (intRefIdsSet.isEmpty() || leadIds.isEmpty()) {
      return new List<LeadShare>();
    }
    return [
      SELECT Id, LeadId, UserOrGroupId, LeadAccessLevel
      FROM LeadShare
      WHERE
        LeadId IN :leadIds
        AND UserOrGroupId IN :intRefIdsSet
        AND RowCause = 'Manual'
      WITH SYSTEM_MODE
    ];
  }
}
