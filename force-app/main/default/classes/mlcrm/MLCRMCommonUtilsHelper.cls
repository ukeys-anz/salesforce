/**
 * @author Ashish Kumar
 * @since  02/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMCommonUtilsHelper class to handle common functionality related to MLCRM
 */
public with sharing class MLCRMCommonUtilsHelper {
  private static final Map<String, String> MAP_OF_SOBJECT_RT = new Map<String, String>{
    'Lead' => MLCRMConstants.MLCRM_LEAD_RT_ID,
    'Opportunity' => MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID
  };

  /**
   * @description This method is used to validate that loan writer and franchise admin cannot change the owner of the record not owner by themself
   * @name validateOwnerChange
   * @param oldMapSobject old Map of sobject records
   * @param lstOfSobject List of sobject records
   * @author Ashish Kumar
   * @US CC-7788
   */
  public static void validateOwnerChange(
    Map<Id, sObject> oldMapSobject,
    List<sObject> lstOfSobject
  ) {
    Id strCurrentUserId = UserInfo.getuserId();
    Map<String, String> mapOfUserToRole = MLCRMCommonUtilsHelper.getUserRole(
      new Set<Id>{ strCurrentUserId }
    );
    List<Sobject> lstOfValidSobject = filterEligibleSobjects(lstOfSobject);
    if (lstOfValidSobject.isEmpty()) {
      return;
    }
    List<Sobject> lstOfOwnerChangeRecord = filterOwnerIdChanged(
      oldMapSobject,
      lstOfValidSobject
    );
    if (lstOfOwnerChangeRecord.isEmpty()) {
      return;
    }
    addErrorInvalidOwnerChange(
      lstOfOwnerChangeRecord,
      mapOfUserToRole,
      oldMapSobject,
      strCurrentUserId
    );
  }
  /**
   * @description This method is used to fetch the user details
   * @name getUserRole
   * @param idsOfUsers ids of whose user details needs to be fetched
   * @return Map<Id,User>
   * @author Ashish Kumar
   * @US CC-7788
   */
  @testVisible
  private static Map<String, String> getUserRole(Set<Id> idsOfUsers) {
    Map<String, String> mapOfUserToRole = new Map<String, String>();
    for (User_Territory__c objTerr : [
      SELECT Id, ML_Role__c, User__c, Territory__c
      FROM User_Territory__c
      WHERE User__c IN :idsOfUsers AND Status__c = 'Active'
    ]) {
      mapOfUserToRole.put(
        (String) objTerr.Territory__c + (String) objTerr.User__c,
        objTerr.ML_Role__c
      );
    }
    return mapOfUserToRole;
  }

  /**
   * @description This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
   * @name filterEligibleSobjects
   * @param lstOfSobject List of sobject records
   * @return List<sObject>
   * @author Ashish Kumar
   * @US CC-7788
   */
  @testVisible
  private static List<sObject> filterEligibleSobjects(
    List<sObject> lstOfSobject
  ) {
    List<sObject> lstOfValidSobject = new List<sObject>();
    for (sObject objSobject : lstOfSobject) {
      if (
        objSobject.get('Territory__c') != null &&
        MAP_OF_SOBJECT_RT.containsKey(
          String.valueOf(objSobject.getSObjectType())
        )
      ) {
        lstOfValidSobject.add(objSobject);
      }
    }
    return lstOfValidSobject;
  }

  /**
   * @description This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
   * @name filterOwnerIdChanged
   * @param oldMapSobject old Map of sobject records
   * @param lstOfSobject List of sobject records
   * @return List<sObject>
   * @author Ashish Kumar
   * @US CC-7788
   */
  @testVisible
  private static List<sObject> filterOwnerIdChanged(
    Map<Id, sObject> oldMapSobject,
    List<sObject> lstOfSobject
  ) {
    List<sObject> lstOfOwnerChangeRecord = new List<sObject>();
    for (sObject objSobject : lstOfSobject) {
      if (
        (oldMapSobject != null &&
        objSobject.get('OwnerId') !=
        oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId'))
      ) {
        lstOfOwnerChangeRecord.add(objSobject);
      }
    }
    return lstOfOwnerChangeRecord;
  }

  /**
   * @description This method to validate user role of current user
   * @name validateUserRole
   * @param strRole role of the user
   * @param objSobject each old sobject record
   * @param strCurrentUserId current user id
   * @return Boolean
   * @author Ashish Kumar
   * @US CC-7788
   */
  @testVisible
  private static Boolean validateUserRole(
    String strRole,
    sObject objSobject,
    Id strCurrentUserId
  ) {
    return ((strRole == MLCRMConstants.FRANCHISE_ADMIN ||
    strRole == MLCRMConstants.LOAN_WRITER) &&
    (Id) objSobject.get('OwnerId') != strCurrentUserId);
  }

  /**
   * @description This method to add error if current user is admin/loan writer and not the owner of the record
   * @name addErrorInvalidOwnerChange
   * @param lstOfOwnerChangeRecord list of sobject records
   * @param mapOfUserToRole map of users
   * @param oldMapSobject old map sobject record
   * @param strCurrentUserId current user id
   * @author Ashish Kumar
   * @US CC-7788
   */
  @testVisible
  private static void addErrorInvalidOwnerChange(
    List<sObject> lstOfOwnerChangeRecord,
    Map<String, String> mapOfUserToRole,
    Map<Id, sObject> oldMapSobject,
    Id strCurrentUserId
  ) {
    for (sObject objSobject : lstOfOwnerChangeRecord) {
      if (
        validateUserRole(
          mapOfUserToRole.get(
            (String) objSobject.get('Territory__c') + (String) strCurrentUserId
          ),
          oldMapSobject.get((Id) objSobject.get('Id')),
          strCurrentUserId
        )
      ) {
        objSobject.addError(LABEL.ValidateOwnerChange);
      }
    }
  }
}
