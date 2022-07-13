/**
 * @author Emmanuel Yap
 * @since  05/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMControllingPostActions is class to handle all the CCRM Controlling Post Actions
 */
public with sharing class CCRMControllingPostActions {
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
}
