/**
 * @author Ashish Kumar
 * @since  02/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritoryCommonUtilsHelper class to handle common functionality related to MLCRM
 */
public with sharing class TerritoryCommonUtilsHelper {
  private static final UserTerritoryActionsRepository USER_TERRITORY_REPOSITORY = (UserTerritoryActionsRepository) Lib_InstanceProvider.forType(
    UserTerritoryActionsRepository.class
  );

  private static Set<Id> errorTrackerSet = new Set<Id>();
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
    Map<String, String> mapOfUserToRole = getUserRole(
      new Set<Id>{ strCurrentUserId }
    );
    List<Sobject> lstOfRecordWithTerritory = filterForTerritoryNotNull(
      lstOfSobject
    );
    if (lstOfRecordWithTerritory.isEmpty()) {
      return;
    }
    List<Sobject> lstOfOwnerChangeRecord = filterSobjectsByOwnerChanged(
      lstOfRecordWithTerritory,
      oldMapSobject
    );
    List<sObject> lstOfResult = addErrorInvalidOwnerChange(
      lstOfOwnerChangeRecord,
      mapOfUserToRole,
      oldMapSobject
    );
    TerritoryCommonUtilsHelper.raiseSobjectError(
      lstOfResult,
      LABEL.ValidateOwnerChange
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
    for (
      User_Territory__c objTerr : USER_TERRITORY_REPOSITORY.getActiveUserTerrritories(
        idsOfUsers
      )
    ) {
      mapOfUserToRole.put(
        (String) objTerr.Territory__c + (String) objTerr.User__c,
        objTerr.ML_Role__c
      );
    }
    return mapOfUserToRole;
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
    return ((strRole == 'Admin' || strRole == 'Loan Writer') &&
    (Id) objSobject.get('OwnerId') != strCurrentUserId);
  }

  /**
   * @description This method to add error if current user is admin/loan writer and not the owner of the record
   * @name addErrorInvalidOwnerChange
   * @param lstOfOwnerChangeRecord list of sobject records
   * @param mapOfUserToRole map of users
   * @param oldMapSobject old map sobject record
   * @return List<sObject> of valid sobjects records
   * @author Ashish Kumar
   * @US CC-7788
   */
  @testVisible
  private static List<sObject> addErrorInvalidOwnerChange(
    List<sObject> lstOfOwnerChangeRecord,
    Map<String, String> mapOfUserToRole,
    Map<Id, sObject> oldMapSobject
  ) {
    if (lstOfOwnerChangeRecord == null || lstOfOwnerChangeRecord.isEmpty()) {
      return new List<sObject>();
    }
    Id strCurrentUserId = UserInfo.getuserId();
    List<sObject> lstOfResult = new List<sObject>();
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
        lstOfResult.add(objSobject);
      }
    }
    return lstOfResult;
  }

  /**
   * @description This method to create share record for sobject having franchise scope
   * @name getUserTerritoryFranchiseWise
   * @param idsOfFranchiseOwner ids of territory franchise owner
   * @return Map<Id, List<User_Territory__c>>
   * @author Ashish Kumar
   * @US CC-3659
   */
  public static Map<Id, List<User_Territory__c>> getUserTerritoryFranchiseWise(
    Set<Id> idsOfFranchiseOwner
  ) {
    Map<Id, List<User_Territory__c>> mapOfFranchiseToUsers = new Map<Id, List<User_Territory__c>>();
    Map<Id, Set<Id>> franchiseToSeenUsers = new Map<Id, Set<Id>>();
    for (
      User_Territory__c objUT : USER_TERRITORY_REPOSITORY.getUserTerritoryFromFranchiseOwnerId(
        idsOfFranchiseOwner
      )
    ) {
      Id franchiseId = objUT.Territory__r.Primary_Franchise_Owner__c;
      Id userId = objUT.User__c;

      if (!mapOfFranchiseToUsers.containsKey(franchiseId)) {
        mapOfFranchiseToUsers.put(franchiseId, new List<User_Territory__c>());
        franchiseToSeenUsers.put(franchiseId, new Set<Id>());
      }

      // Add only if User__c has not already been added for this Franchise
      if (!franchiseToSeenUsers.get(franchiseId).contains(userId)) {
        mapOfFranchiseToUsers.get(franchiseId).add(objUT);
        franchiseToSeenUsers.get(franchiseId).add(userId);
      }
    }
    return mapOfFranchiseToUsers;
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name filterSobjectsByTerritoryNull
   * @param lstOfSobject list of sobject
   * @return lstOfSobject list of sobject
   * @description  filter list of sobject where Territory is null
   */
  public static List<sObject> filterSobjectsByTerritoryNull(
    List<sObject> lstOfSobject
  ) {
    SObjectField territoryIdfield = CommonUtil.getSObjectField(
      lstOfSobject[0],
      'Territory__c'
    );
    return ListUtil.filter(lstOfSobject)
      .equals(territoryIdfield, null)
      .toList();
  }

  /**
   * @description to check if the territory is updated on Leads
   * @name filterForTerritoryNotNull
   * @param lstOfSobject The Lead records passed from Trigger.new()
   * @return List<Lead> recordList
   */
  public static List<sObject> filterForTerritoryNotNull(
    List<sObject> lstOfSobject
  ) {
    if (lstOfSobject.isEmpty()) {
      return new List<SObject>();
    }
    SObjectField territoryIdfield = CommonUtil.getSObjectField(
      lstOfSobject[0],
      'Territory__c'
    );
    return ListUtil.filter(lstOfSobject)
      .notEquals(territoryIdfield, null)
      .toList();
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name raiseSobjectError
   * @param lstSobjects List of sObject records
   * @param strErrorMessage String of errormessage to add error
   * @description  reusable method to raise Error.
   */
  public static void raiseSobjectError(
    List<sObject> lstSobjects,
    String strErrorMessage
  ) {
    if (lstSobjects == null || lstSobjects.isEmpty()) {
      return;
    }
    for (sObject objSobject : lstSobjects) {
      if (errorTrackerSet.contains((Id) objSobject.get('Id'))) {
        continue;
      }
      objSobject.addError(strErrorMessage);
      errorTrackerSet.add((Id) objSobject.get('Id'));
    }
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name filterSobjectsByTerritoryChanged
   * @param records List of sObject records
   * @param oldMapSobject Map of old sObject records
   * @return list of sobject records
   * @description  filter Sobjects when Territory get Changed
   */
  public static List<sObject> filterSobjectsByTerritoryChanged(
    List<sObject> records,
    Map<Id, sObject> oldMapSobject
  ) {
    SObjectField territoryField = CommonUtil.getSObjectField(
      records[0],
      'Territory__c'
    );
    return ListUtil.filter(records, oldMapSobject)
      .notEquals(territoryField, null)
      .changed(territoryField)
      .toList();
  }
  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name filterSobjectsByOwnerChanged
   * @param records List of sObject records
   * @param oldMapSobject Map of old sObject records
   * @return records List of sObject records
   * @description  filter Sobjects when owner get changed
   */
  public static List<sObject> filterSobjectsByOwnerChanged(
    List<sObject> records,
    Map<Id, sObject> oldMapSobject
  ) {
    if (records.isEmpty()) {
      return null;
    }
    SObjectField ownerIdField = CommonUtil.getSObjectField(
      records[0],
      'OwnerId'
    );
    return ListUtil.filter(records, oldMapSobject)
      .changed(ownerIdField)
      .toList();
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name getUserTerritoriesToValidate
   * @param idsOfOwnerId set of ownerId's
   * @return lstOfLoggedInUserTerritory List of User_Territory__c records
   * @description  method to get User Territories from ownerIds
   */
  public static List<User_Territory__c> getUserTerritoriesToValidate(
    Set<Id> idsOfOwnerId
  ) {
    return USER_TERRITORY_REPOSITORY.getActiveUserTerrritories(idsOfOwnerId);
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name getUserTerritoryKey
   * @param lstOfLoggedInUserTerritory list of UserTerritory
   * @return set of setOfUserTerritoryKeys
   * @description  method to get UserTerritoryKey for validateOwnerAssignment and validateTerritoryAssignment
   */
  public static Set<String> getUserTerritoryKey(
    List<User_Territory__c> lstOfLoggedInUserTerritory
  ) {
    Set<String> setOfUserTerritoryKeys = new Set<String>();
    for (User_Territory__c objTerritory : lstOfLoggedInUserTerritory) {
      setOfUserTerritoryKeys.add(
        String.valueOf(objTerritory.User__c) +
        String.valueOf(objTerritory.Territory__c)
      );
    }
    return setOfUserTerritoryKeys;
  }
  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name validateOwnerAssignment
   * @param lstOfSobject list of sObject record
   * @param setOfUserTerritoryKeys set Of UserTerritory
   * @return List<sObject> of valid sobjects records
   * @description  This method to validate owner change on Sobject to make sure it happen within user's territory
   */
  public static List<sObject> validateOwnerAssignment(
    List<sObject> lstOfSobject,
    Set<String> setOfUserTerritoryKeys
  ) {
    List<sObject> returnList = new List<sObject>();
    for (sObject objSobject : lstOfSobject) {
      String strTerritoryUserMapping =
        (String) objSobject.get('OwnerId') +
        (String) objSobject.get('Territory__c');

      if (setOfUserTerritoryKeys.contains(strTerritoryUserMapping)) {
        continue;
      }
      returnList.add(objSobject);
    }
    return returnList;
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name validateTerritoryAssignment
   * @param lstOfSobject List of sObject records
   * @param setOfUserTerritoryKeys set of user Territory
   * @return List<sObject> of valid sobjects records
   * @description  This method to validate territory change on Sobject to make sure it happen within user's territory
   */
  public static List<sObject> validateTerritoryAssignment(
    List<sObject> lstOfSobject,
    Set<String> setOfUserTerritoryKeys
  ) {
    List<sObject> returnList = new List<sObject>();
    for (sObject objSobject : lstOfSobject) {
      String strTerritoryUserMapping =
        (String) objSobject.get('OwnerId') +
        (String) objSobject.get('Territory__c');

      if (
        objSobject.get('Territory__c') != null &&
        (!setOfUserTerritoryKeys.contains(strTerritoryUserMapping) ||
        (UserInfo.getUserRoleId() == TerritoryCommonUtils.strFranchiseRoleId &&
        !setOfUserTerritoryKeys.contains(
          UserInfo.getUserId() + objSobject.get('Territory__c')
        )))
      ) {
        returnList.add(objSobject);
      }
    }
    return returnList;
  }

  /**
   * @description This method to set the territory for ML Lead
   * @name createOwnerIdSet
   * @param lstOfSobject List of sObject records
   * @return set of ownerIds of list of sobjects
   * @US CC-1054
   */
  public static Set<Id> createOwnerIdSet(List<sObject> lstOfSobject) {
    if (lstOfSobject.isEmpty()) {
      return new Set<Id>();
    }
    SObjectField ownerIdField = CommonUtil.getSObjectField(
      lstOfSobject[0],
      'OwnerId'
    );
    return ListUtil.getIds(lstOfSobject, ownerIdField);
  }
}
