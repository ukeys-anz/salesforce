/**
 * @author CMOS
 * @since AUG 2025
 * @description Holds cached QueryUserProvisioningSetting records
 */
public with sharing class QueryUserProvisioningSetting {
  private static List<User_Provisioning_Setting__mdt> businessFunctionList = [
    SELECT
      Id,
      Label,
      DeveloperName,
      Call_Center_Name__c,
      Profile_Name__c,
      Role_Name__c,
      Permission_Sets__c,
      Permission_Set_Groups__c,
      Public_Groups__c,
      Permission_Set_Licences__c
    FROM User_Provisioning_Setting__mdt
    WITH SYSTEM_MODE
  ];
  private static Map<String, User_Provisioning_Setting__mdt> businessFunctionMap = new Map<String, User_Provisioning_Setting__mdt>();
  static {
    for (User_Provisioning_Setting__mdt mdtRecord : businessFunctionList) {
      businessFunctionMap.put(mdtRecord.DeveloperName, mdtRecord);
    }
  }
  /**
   * @description Get User_Provisioning_Setting__mdt by  Name
   * @param name name of the User_Provisioning_Setting__mdt
   * @return User_Provisioning_Setting__mdt
   */
  public static User_Provisioning_Setting__mdt getByName(String name) {
    return businessFunctionMap.get(name);
  }
}
