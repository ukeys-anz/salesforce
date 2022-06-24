/**
 * @author Boobalakrishnan Duraisamy
 * @since  02/2020
 * @description UserProvisioningCommonActions class contains the common set of methods used for User Provisioning.
 */
public with sharing class UserProvisioningCommonActions {
  /**
   * @description This function is to check if the user business function and business role is not empty.
   * @param record User record from trigger
   * @return `Boolean` True if the User business function and role is not empty. Otherwise return false.
   */
  public static Boolean isValidRecordForProcessing(User record) {
    if (
      String.isNotBlank(record.Business_Function__c) &&
      String.isNotBlank(record.Business_Role__c) &&
      String.isNotBlank(record.FederationIdentifier) &&
      record.IsActive == true
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description This function returns true if user business function and role is changed.
   * @param record User record from trigger
   * @param oldRecord User old record from trigger
   * @return `Boolean` True if current record business function and role are not matches old record business function and role.
   */
  public static Boolean isValidRecordForUpdate(User record, User oldRecord) {
    if (
      (record.Business_Function__c != oldRecord.Business_Function__c) ||
      (record.Business_Role__c != oldRecord.Business_Role__c)
    ) {
      return true;
    } else {
      return false;
    }
  }
  /**
   * @description This method is used to generate Business Function and Role key which will be used as a key in Custom Metadata.
   * @param record User record from trigger
   * @return `String` True if the the record type is of IDR type false otherwise.
   */
  public static String generateKey(User record) {
    String businessFunctionKey =
      record.Business_Function__c.trim().replaceAll(' ', '_') +
      '_' +
      record.Business_Role__c.trim().replaceAll(' ', '_');

    return businessFunctionKey;
  }
  /**
   * @description This method is called to get user permission API names from User Provisioning Setting Metadata based on Business function and role key from user record.
   * @param businessFuncAndRoles Set of Business Function and Roles key values combinations from trigger
   * @return `Map<String, User_Provisioning_Setting__mdt>` returns User Provisioning Setting list with DevloperName as a key
   */

  public static Map<String, User_Provisioning_Setting__mdt> getBusinesFunctionAndRoles(
    Set<String> businessFuncAndRoles
  ) {
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap = new Map<String, User_Provisioning_Setting__mdt>();

    for (User_Provisioning_Setting__mdt businessFunction : [
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
      WHERE DeveloperName IN :BusinessFuncAndRoles
    ]) {
      businessFunctionMap.put(
        (businessFunction.DeveloperName),
        businessFunction
      );
    }
    return businessFunctionMap;
  }

  /**
   * @description This method is called to get all profile names and their profile ids.
   * @return `Map<String, Profile>`
   */

  public static Map<String, Profile> getAllProfileMap() {
    Map<String, Profile> profileMap = new Map<String, Profile>();

    for (Profile prof : [SELECT Id, Name FROM Profile LIMIT 100]) {
      profileMap.put(prof.Name, prof);
    }
    return profileMap;
  }

  /**
   * @description This method is called to get all userrole names and their ids.
   * @return `Map<String, UserRole>`
   */

  public static Map<String, UserRole> getAllUserRoleMap() {
    Map<String, UserRole> userRoleMap = new Map<String, UserRole>();

    for (UserRole uRole : [SELECT Id, DeveloperName FROM UserRole LIMIT 100]) {
      userRoleMap.put(uRole.DeveloperName, uRole);
    }
    return userRoleMap;
  }

  /**
   * @description This method is called to get all call center names and their ids.
   * @return `Map<String, CallCenter>`
   */

  public static Map<String, CallCenter> getAllCallCenterMap() {
    Map<String, CallCenter> callCenterMap = new Map<String, CallCenter>();

    for (CallCenter cc : [SELECT Id, InternalName FROM CallCenter LIMIT 10]) {
      callCenterMap.put(cc.InternalName, cc);
    }
    return callCenterMap;
  }

  /**
   * @description This method is called to get all permission set names and their ids.
   * @return `Map<String, PermissionSet>`
   */

  public static Map<String, PermissionSet> getAllPSetMap() {
    Map<String, PermissionSet> pSetMap = new Map<String, PermissionSet>();

    for (PermissionSet pSet : [SELECT Id, Name FROM PermissionSet LIMIT 500]) {
      pSetMap.put(pSet.Name, pSet);
    }
    return pSetMap;
  }

  /**
   * @description This method is called to get all permission set group names and their ids.
   * @return `Map<String, PermissionSetGroup>`
   */

  public static Map<String, PermissionSetGroup> getAllPsetGroupMap() {
    Map<String, PermissionSetGroup> pSetGroupMap = new Map<String, PermissionSetGroup>();

    for (PermissionSetGroup pSetGroup : [
      SELECT Id, DeveloperName
      FROM PermissionSetGroup
      LIMIT 200
    ]) {
      pSetGroupMap.put(pSetGroup.DeveloperName, pSetGroup);
    }
    return pSetGroupMap;
  }

  /**
   * @description This method is called to get all permission set license names and their ids.
   * @return `Map<String, PermissionSetLicense>`
   */

  public static Map<String, PermissionSetLicense> getAllPSetLicenseMap() {
    Map<String, PermissionSetLicense> pSetLicenseMap = new Map<String, PermissionSetLicense>();

    for (PermissionSetLicense pSetLicense : [
      SELECT Id, DeveloperName
      FROM PermissionSetLicense
      LIMIT 200
    ]) {
      pSetLicenseMap.put(pSetLicense.DeveloperName, pSetLicense);
    }
    return pSetLicenseMap;
  }

  /**
   * @description This method is called to get all Group names and their ids.
   * @return `Map<String, Group>`
   */

  public static Map<String, Group> getAllPublicGroupMap() {
    Map<String, Group> publicGroupMap = new Map<String, Group>();

    for (Group publicGroup : [
      SELECT Id, DeveloperName
      FROM Group
      WHERE Type IN ('Regular', 'Queue')
    ]) {
      publicGroupMap.put(publicGroup.DeveloperName, publicGroup);
    }
    return publicGroupMap;
  }
}
