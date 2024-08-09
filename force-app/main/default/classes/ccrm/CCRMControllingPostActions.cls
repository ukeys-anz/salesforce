/**
 * @author Emmanuel Yap
 * @since  05/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMControllingPostActions is class to handle all the CCRM Controlling Post Actions
 */
public with sharing class CCRMControllingPostActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CCRMControllingPostRepository CP_REPOSITORY = (CCRMControllingPostRepository) Lib_InstanceProvider.forType(
    CCRMControllingPostRepository.class
  );

  /**
   * @description Before Update Automated actions of a completed Lead.
   * @name setResponsibleEmployee
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void setResponsibleEmployee(
    List<Controlling_Post__c> records,
    Map<Id, Controlling_Post__c> oldMap
  ) {
    Map<String, List<Controlling_Post__c>> mappedCP = mapEmployeeIDToControllingPost(
      records,
      oldMap
    );
    Set<String> employeeIds = mappedCP.keySet();
    for (User user : [
      SELECT Id, Employee_Id__c
      FROM User
      WHERE Employee_Id__c IN :employeeIds
      WITH SECURITY_ENFORCED
    ]) {
      if (mappedCP.containsKey(user.Employee_Id__c)) {
        List<Controlling_Post__c> cps = mappedCP.get(user.Employee_Id__c);
        for (Controlling_Post__c cp : cps) {
          cp.Responsible_Employee__c = user.id;
        }
      }
    }
  }

  /**
   * @description Before Update Automated actions of a completed Lead.
   * @name mapEmployeeIDToControllingPost
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @return `Map<String, List<Account>>` Return map of Controlling Posts with Employee ID as key
   */
  public static Map<String, List<Controlling_Post__c>> mapEmployeeIDToControllingPost(
    List<Controlling_Post__c> records,
    Map<Id, Controlling_Post__c> oldMap
  ) {
    Map<String, List<Controlling_Post__c>> mappedCP = new Map<String, List<Controlling_Post__c>>();
    for (Controlling_Post__c record : records) {
      Controlling_Post__c oldRec = oldMap != null
        ? oldMap.get(record.id)
        : null;
      if (
        oldMap == null ||
        (record.Responsible_Employee_Id__c != null &&
        isEmployeeIdChanged(record, oldRec))
      ) {
        if (mappedCP.containsKey(record.Responsible_Employee_Id__c)) {
          mappedCP.get(record.Responsible_Employee_Id__c).add(record);
        } else {
          mappedCP.put(
            record.Responsible_Employee_Id__c,
            new List<Controlling_Post__c>{ record }
          );
        }
      }
    }
    return mappedCP;
  }

  /**
   * @description Check if this Controlling Post record has updated Employee Id
   * @name isEmployeeIdChanged
   * @param record Controlling Post record
   * @param oldRec old Controlling Post record from trigger
   * @return `Boolean` True if the Employee Id is updated otherwise false.
   */
  public static Boolean isEmployeeIdChanged(
    Controlling_Post__c record,
    Controlling_Post__c oldRec
  ) {
    if (
      oldRec != null &&
      record.Responsible_Employee_Id__c != oldRec.Responsible_Employee_Id__c
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Get a List of Controlling Posts
   * @name getControllingPosts
   * @param employeeIds A Set of User.Employee_Id__c
   * @return `List<Controlling_Post__c>` Returns List of Controlling Posts of Users
   */
  public static List<Controlling_Post__c> getControllingPosts(
    Set<String> employeeIds
  ) {
    if (
      !Schema.sObjectType.Controlling_Post__c.isQueryable() &&
      !Schema.sObjectType.Controlling_Post__c.fields.CPID__c.isAccessible() &&
      !Schema.sObjectType.Controlling_Post__c.fields.Responsible_Employee_Id__c.isAccessible()
    ) {
      return new List<Controlling_Post__c>();
    }
    return [
      SELECT Id, CPID__c, Responsible_Employee_Id__c
      FROM Controlling_Post__c
      WHERE Responsible_Employee_Id__c IN :employeeIds AND Is_Active__c = TRUE
      WITH SECURITY_ENFORCED
    ];
  }

  /**
   * @description Updates Leads if the User has a Controlling Post with CPID
   * @name updateCPIDs
   * @param leadOwners Map of Leads with Owner ID as key
   * @param users Map of Employee Users with Employee ID as key
   * @param controllingPosts List of Controlling Posts from employeer
   */
  public static void updateCPIDs(
    Map<Id, List<Lead>> leadOwners,
    Map<String, User> users,
    List<Controlling_Post__c> controllingPosts
  ) {
    for (Controlling_Post__c controllingPost : controllingPosts) {
      if (controllingPost.CPID__c == null) {
        continue;
      }
      User user = users.get(controllingPost.Responsible_Employee_Id__c);
      List<Lead> mappedLeads = leadOwners.get(user?.id);

      if (mappedLeads == null) {
        continue;
      }
      for (Lead mappedLead : mappedLeads) {
        if (mappedLead.CPID__c == null) {
          mappedLead.Controlling_Post__c = controllingPost.Id;
          mappedLead.CPID__c = controllingPost.CPID__c;
          mappedLead.CPID_Owner__c = user.id;
        }
      }
    }
  }

  /**
   * @description Set Controlling Post information on Leads
   * @name retrieveControllingPost
   * @param records List of lead NEW records.
   * @param oldMap  Map of old records with Id as key
   */
  public static void retrieveControllingPost(
    List<Lead> records,
    Map<Id, SObject> oldMap
  ) {
    Map<Id, List<Lead>> leadOwners = new Map<Id, List<Lead>>();

    for (Lead lead : records) {
      if (CCRMLeadUtil.isCCRMLeadType(lead)) {
        if (
          oldMap != null &&
          CCRMLeadUtil.isLeadOwnerChanged(lead, (Lead) oldMap.get(lead.id))
        ) {
          lead.CPID__c = null;
          lead.CPID_Owner__c = null;
          lead.Controlling_Post__c = null;
        }
        if (leadOwners.containsKey(lead.OwnerId)) {
          leadOwners.get(lead.OwnerId).add(lead);
        } else {
          List<Lead> newLeads = new List<Lead>();
          newLeads.add(lead);
          leadOwners.put(lead.OwnerId, newLeads);
        }
      }
    }

    if (leadOwners.isEmpty()) {
      return;
    }

    Set<Id> leadOwnerIds = leadOwners.keySet();

    Set<Id> managerIds = new Set<Id>();
    Map<String, User> employeeUsers = new Map<String, User>();
    Map<Id, List<Lead>> mappedLeadOwners = new Map<Id, List<Lead>>();

    for (User user : [
      SELECT Id, ManagerId, Employee_Id__c
      FROM User
      WHERE Id IN :leadOwnerIds
      WITH SECURITY_ENFORCED
    ]) {
      if (user.Employee_Id__c != null) {
        employeeUsers.put(user.Employee_Id__c, user);
      }
      mappedLeadOwners.put(user.ManagerId, leadOwners.get(user.Id));
      managerIds.add(user.ManagerId);
    }

    updateCPIDs(
      leadOwners,
      employeeUsers,
      CCRMControllingPostActions.getControllingPosts(employeeUsers.keySet())
    );

    Map<String, User> managerUsers = new Map<String, User>();
    for (User user : [
      SELECT Id, Employee_Id__c
      FROM User
      WHERE Id IN :managerIds
      WITH SECURITY_ENFORCED
    ]) {
      if (user.Employee_Id__c != null) {
        managerUsers.put(user.Employee_Id__c, user);
      }
    }

    updateCPIDs(
      mappedLeadOwners,
      managerUsers,
      CCRMControllingPostActions.getControllingPosts(managerUsers.keySet())
    );
  }

  /**
   * @description This is to update the CPID User Id on Controlling Post based on CPID Lan Id on Insert/Update
   * @name setCPIDUser
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values
   */
  public static void setCPIDUser(
    List<Controlling_Post__c> records,
    Map<Id, Controlling_Post__c> oldMap
  ) {
    try {
      ControllingPostWrapper cpWrapper = getFilterCpRecords(records, oldMap);
      List<User> userList = CP_REPOSITORY.getActiveLanIdUser(
        cpWrapper.lanIdsSet
      );
      Map<String, User> lanIdUserMap = formLanIdToUserMap(userList);
      updateUserLookupOnCpRecords(cpWrapper.filteredCpList, lanIdUserMap);
    } catch (Exception e) {
      Logger.error(
        'Error while udpating the Controlling post records in before insert',
        e
      );
      Logger.saveLog();
      throw e;
    }
  }

  /**
   * @description This is to get the list of records for which CPID Lan Id changes
   * @name getFilterCpRecords
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the old values.
   * @return ControllingPostWrapper Wrapper containing the filtered CP records and Set of Lan Ids
   */
  @TestVisible
  private static ControllingPostWrapper getFilterCpRecords(
    List<Controlling_Post__c> records,
    Map<Id, Controlling_Post__c> oldMap
  ) {
    ControllingPostWrapper cpWrapper = new ControllingPostWrapper();
    for (Controlling_Post__c record : records) {
      Controlling_Post__c oldRec = oldMap.get(record.Id);
      if (record.CPID_LanID__c != oldRec?.CPID_LanID__c) {
        cpWrapper.filteredCpList.add(record);
        cpWrapper.lanIdsSet.add(record.CPID_LanID__c);
      }
    }
    cpWrapper.lanIdsSet.removeAll(new Set<String>{ null });
    return cpWrapper;
  }

  /**
   * @description This is used to form the User Map
   * @name formLanIdToUserMap
   * @param userList List of active user
   * @return Map<String, User> Map of Lan Id and User record
   */
  @TestVisible
  private static Map<String, User> formLanIdToUserMap(List<User> userList) {
    Map<String, User> lanIdUserMap = new Map<String, User>();
    for (User userItr : userList) {
      lanIdUserMap.put(userItr.Lan_Id__c.toLowerCase(), userItr);
    }
    return lanIdUserMap;
  }

  /**
   * @description This is to update the CPID User Id on Controlling Post based on CPID Lan Id.
   * @name updateUserLookupOnCpRecords
   * @param filteredCpList List of filter controlling post records
   * @param lanIdUserMap Map of Lan Id and UserId
   */
  @TestVisible
  private static void updateUserLookupOnCpRecords(
    List<Controlling_Post__c> filteredCpList,
    Map<String, User> lanIdUserMap
  ) {
    for (Controlling_Post__c cpRec : filteredCpList) {
      cpRec.CPID_User__c = lanIdUserMap.containsKey(
          cpRec.CPID_LanID__c.toLowerCase()
        )
        ? lanIdUserMap.get(cpRec.CPID_LanID__c.toLowerCase()).Id
        : null;
    }
  }

  /**
   * @description This is the wrapper class for Controlling Post
   * @param filteredCpList list of fileter cp records for which CPID Lan Id changed
   * @param lanIdsSet Set of Lan Ids
   */
  public class ControllingPostWrapper {
    @TestVisible
    List<Controlling_Post__c> filteredCpList = new List<Controlling_Post__c>();
    @TestVisible
    Set<String> lanIdsSet = new Set<String>();
  }
}
