/**
 * @author Ashish Kumar
 * @since  06/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritoryCommonUtils is class to handle common functionality related to territory management.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class TerritoryCommonUtils {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );
  public static final UserTerritoryActionsRepository UTA_REPOSITORY = (UserTerritoryActionsRepository) Lib_InstanceProvider.forType(
    UserTerritoryActionsRepository.class
  );
  private static final LeadActionsRepository LEADACTION_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  @testVisible
  private static Map<String, Id> mapOfProfileId = new Map<String, Id>{
    QueryProfile.anzMLStandardUser.Name => QueryProfile.anzMLStandardUser.Id,
    QueryProfile.systemAdmin.Name => QueryProfile.systemAdmin.Id,
    QueryProfile.anzCCRMStandardUser.Name => QueryProfile.anzCCRMStandardUser.Id
  };
  public static String strFranchiseRoleId = QueryRole.mlFranchiseRole.Id;

  /**
   * @description This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
   * @name validateTerritoryAndOwnerChange
   * @param oldMapSobject old map of sobject
   * @param lstOfSobject new list of sobject
   * @author Ashish Kumar
   * @US CC-1058
   */
  public static void validateTerritoryAndOwnerChange(
    Map<Id, sObject> oldMapSobject,
    List<sObject> lstOfSobject
  ) {
    if (
      USER_REPOSITORY.isIntegrationUser() ||
      USER_REPOSITORY.isCustomValidationsSkipped() ||
      UserInfo.getUserRoleId() != QueryRole.mlFranchiseRole.Id ||
      UserInfo.getProfileId() == QueryProfile.anzCCRMStandardUser.Id
    ) {
      return;
    }

    Territory_Based_Sharing_Config__mdt territoryConfigMgt = QueryTerritoryBasedSharingConfig.get(
      lstOfSobject.getSObjectType().toString()
    );
    lstOfSobject = filterValidateSobjectRecords(
      lstOfSobject,
      territoryConfigMgt
    );
    if (lstOfSobject.isEmpty()) {
      return;
    }

    List<sobject> lstSobjectsTerritoryNull = TerritoryCommonUtilsHelper.filterSobjectsByTerritoryNull(
      lstOfSobject
    );
    if (
      oldMapSobject == null &&
      !LEADACTION_REPOSITORY.isAllowLeadCreationCustomPermission()
    ) {
      return;
    }
    TerritoryCommonUtilsHelper.raiseSobjectError(
      lstSobjectsTerritoryNull,
      LABEL.ML_ValidateTerritory
    );

    List<sobject> lstSobjectsTerritoryChgd = TerritoryCommonUtilsHelper.filterSobjectsByTerritoryChanged(
      lstOfSobject,
      oldMapSobject
    );
    List<sobject> lstSobjectsTerritoryChgdByNonML = filterSobjectsByUpdatedByNonMLUser(
      lstSobjectsTerritoryChgd
    );
    TerritoryCommonUtilsHelper.raiseSobjectError(
      lstSobjectsTerritoryChgdByNonML,
      LABEL.ML_ValidateTerritoryChangeByNonMLUser
    );

    List<sobject> lstSobjectsOwnerChgd = TerritoryCommonUtilsHelper.filterSobjectsByOwnerChanged(
      lstOfSobject,
      oldMapSobject
    );
    List<sobject> lstSobjectsOwnerChgdByNonML = filterSobjectsByUpdatedByNonMLUser(
      lstSobjectsOwnerChgd
    );
    TerritoryCommonUtilsHelper.raiseSobjectError(
      lstSobjectsOwnerChgdByNonML,
      LABEL.ML_ValidateOwnerChangeByNonMLUser
    );

    List<sobject> lstSobjectsTerritoryChangedByMLUser = filterSobjectsByUpdatedByMLUser(
      lstSobjectsTerritoryChgd
    );

    Map<Id, User> mapOfUsers = getMapOfUsers(lstOfSobject);
    List<sobject> lstSobjectsOwnerChgdByFranchise = filterOwnedByFranchiseUsers(
      lstSobjectsOwnerChgd,
      mapOfUsers
    );
    Set<Id> setOfOwnerId = new Set<Id>();
    setOfOwnerId.addAll(
      addToOwnerIdSetIfOwnerChanged(
        lstSobjectsOwnerChgdByFranchise,
        oldMapSobject,
        mapOfUsers
      )
    );

    setOfOwnerId.addAll(
      addToOwnerIdSetIfTerritoryChangedUserNotAsFranchise(
        lstSobjectsTerritoryChangedByMLUser,
        mapOfUsers
      )
    );

    setOfOwnerId.addAll(
      addToOwnerIdSetIfTerritoryChangedUserAsFranchise(
        lstSobjectsTerritoryChangedByMLUser,
        mapOfUsers
      )
    );

    if (setOfOwnerId.isEmpty()) {
      return;
    }
    List<User_Territory__c> lstOfLoggedInUserTerritory = TerritoryCommonUtilsHelper.getUserTerritoriesToValidate(
      setOfOwnerId
    );

    Set<String> setOfUserTerritoryKeys = TerritoryCommonUtilsHelper.getUserTerritoryKey(
      lstOfLoggedInUserTerritory
    );
    List<sObject> lstOfvalidateOwnerRecord = TerritoryCommonUtilsHelper.validateOwnerAssignment(
      lstSobjectsOwnerChgdByFranchise,
      setOfUserTerritoryKeys
    );
    TerritoryCommonUtilsHelper.raiseSobjectError(
      lstOfvalidateOwnerRecord,
      LABEL.ML_ValidateOwnerAssigment
    );
    List<sObject> lstOfvalidateTerritoryRecord = TerritoryCommonUtilsHelper.validateTerritoryAssignment(
      lstSobjectsTerritoryChangedByMLUser,
      setOfUserTerritoryKeys
    );
    TerritoryCommonUtilsHelper.raiseSobjectError(
      lstOfvalidateTerritoryRecord,
      LABEL.ML_ValidateTerritoryAssignment
    );
  }
  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name addToOwnerIdSetIfOwnerChanged
   * @param lstObject List of sObject records
   * @param oldMapSobject Map of old sObject records
   * @param mapOfUsers Map of OwnerId and Owner
   * @return records Set of UserIds
   * @description  add id's of Owner if record's owner is changed and user is ML profile
   */
  public static Set<Id> addToOwnerIdSetIfOwnerChanged(
    List<sObject> lstObject,
    Map<Id, sObject> oldMapSobject,
    Map<Id, User> mapOfUsers
  ) {
    if (
      mapOfProfileId == null ||
      mapOfUsers == null ||
      lstObject.isEmpty() ||
      oldMapSobject == null
    ) {
      return new Set<Id>();
    }
    SObjectField ownerField = lstObject[0]
      .getSObjectType()
      .getDescribe()
      .fields.getMap()
      .get('OwnerId');
    List<SObject> listOfSobjects = ListUtil.filter(lstObject, oldMapSobject)
      .notEquals(ownerField, null)
      .changed(ownerField)
      .toList();
    return ListUtil.getIds(listOfSobjects, ownerField);
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name filterSobjectsByUpdatedByMLUser
   * @param records List of sObject records
   * @return records List of sObject records
   * @description  filter Sobjects when Territory or owner updated by ML user
   */
  public static List<sObject> filterSobjectsByUpdatedByMLUser(
    List<sObject> records
  ) {
    if (USER_REPOSITORY.isCurrentLoggedInNotMLOrAdminUser()) {
      return new List<sObject>();
    }
    return records;
  }
  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name filterSobjectsByUpdatedByNonMLUser
   * @param records List of sObject records
   * @return records List of sObject records
   * @description  filter Sobjects when Territory or owner updated by nonML user
   */
  public static List<sObject> filterSobjectsByUpdatedByNonMLUser(
    List<sObject> records
  ) {
    if (USER_REPOSITORY.isCurrentLoggedInMLOrAdminUser()) {
      return new List<sObject>();
    }
    return records;
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name addToOwnerIdSetIfTerritoryChangedUserNotAsFranchise
   * @param lstObject List of sObject records
   * @param mapOfUsers Map of OwnerId and Owner
   * @return records Set of UserIds
   * @description  add id's of Owner if record's Territory is changed and user is ML profile
   */
  @testVisible
  private static Set<Id> addToOwnerIdSetIfTerritoryChangedUserNotAsFranchise(
    List<sObject> lstObject,
    Map<Id, User> mapOfUsers
  ) {
    if (mapOfUsers == null) {
      return new Set<Id>();
    }
    Set<Id> setOfOwnerId = new Set<Id>();
    for (sObject objSobject : lstObject) {
      if (
        mapOfUsers.containsKey((Id) objSobject.get('OwnerId')) &&
        mapOfUsers.get((Id) objSobject.get('OwnerId')).UserRoleId ==
        strFranchiseRoleId
      ) {
        setOfOwnerId.add((Id) objSobject.get('OwnerId'));
      }
    }
    return setOfOwnerId;
  }

  /**
   * @author Shivsharan Giram
   * @since  05/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name addToOwnerIdSetIfTerritoryChangedUserAsFranchise
   * @param lstObject List of sObject records
   * @param mapOfUsers Map of OwnerId and Owner
   * @return records Set of UserIds
   * @description  add id's of Owner if record's Territory is changed and user is ML profile
   */
  @testVisible
  private static Set<Id> addToOwnerIdSetIfTerritoryChangedUserAsFranchise(
    List<sObject> lstObject,
    Map<Id, User> mapOfUsers
  ) {
    if (mapOfUsers == null || UserInfo.getUserRoleId() != strFranchiseRoleId) {
      return new Set<Id>();
    }
    Set<Id> setOfOwnerId = new Set<Id>();
    for (sObject objSobject : lstObject) {
      if (
        (mapOfUsers.containsKey((Id) objSobject.get('OwnerId')) &&
        mapOfUsers.get((Id) objSobject.get('OwnerId')).UserRoleId ==
        strFranchiseRoleId)
      ) {
        setOfOwnerId.add(UserInfo.getUserId());
      }
    }
    return setOfOwnerId;
  }

  /**
   * @author Ashish Kumar
   * @since  07/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name filterOwnedByFranchiseUsers
   * @param records List of sObject records
   * @param mapOfUsers Map of OwnerId and Owner
   * @return records List of sObject records
   * @description  filter Sobjects when owner is franchise
   */
  @testVisible
  private static List<sObject> filterOwnedByFranchiseUsers(
    List<sObject> records,
    Map<Id, User> mapOfUsers
  ) {
    SObjectType objType = records.getSObjectType();
    List<sObject> returnList = (List<sObject>) Type.forName(
        'List<' + objType + '>'
      )
      .newInstance();
    for (sObject record : records) {
      if (
        mapOfUsers != null &&
        mapOfUsers.containsKey((Id) record.get('OwnerId')) &&
        mapOfUsers.get((Id) record.get('OwnerId')).UserRoleId ==
        strFranchiseRoleId
      ) {
        returnList.add(record);
      }
    }
    return returnList;
  }

  /**
   * @description This method to set the territory for ML Lead
   * @name assignTerritoryForMLRecord
   * @param lstOfSobject List of sObject records
   * @author Ashish Kumar
   * @US CC-1054
   */
  public static void assignTerritoryForMLRecord(List<sObject> lstOfSobject) {
    List<sObject> lstOfValidRecords = TerritoryCommonUtilsHelper.filterSobjectsByTerritoryNull(
      lstOfSobject
    );
    if (lstOfValidRecords.isEmpty()) {
      return;
    }
    assignTerritoryForRecord(lstOfValidRecords);
  }

  /**
   * @description This method to set the territory for ML Lead
   * @name assignTerritoryForRecord
   * @param lstOfSobject List of sObject records
   * @author Ashish Kumar
   * @return records List of sObject records
   * @US CC-16111
   */
  public static List<sObject> assignTerritoryForRecord(
    List<sObject> lstOfSobject
  ) {
    Set<Id> setOfTerritoryOwners = TerritoryCommonUtilsHelper.createOwnerIdSet(
      lstOfSobject
    );
    List<User_Territory__c> lstOfUserTerritory = UTA_REPOSITORY.getUserTerrritoriesFromUserIds(
      setOfTerritoryOwners
    );
    if (lstOfUserTerritory.isEmpty()) {
      return new List<sObject>();
    }
    Map<Id, User_Territory__c> mapOfUserToTerritory = createUserToTerritoryMap(
      lstOfUserTerritory
    );
    return populateSobjectTerritory(lstOfSobject, mapOfUserToTerritory);
  }

  /**
   * @description This method to set the territory for ML Lead
   * @name createUserToTerritoryMap
   * @param lstOfUserTerritory List of user territory records
   * @return map of user territory
   * @US CC-1054
   */
  @testVisible
  private static Map<Id, User_Territory__c> createUserToTerritoryMap(
    List<User_Territory__c> lstOfUserTerritory
  ) {
    // ListUtil.mapBy cannot be used here as we need to store first occurance of user Territory ordered by territory name
    Map<Id, User_Territory__c> mapOfUserToTerritory = new Map<Id, User_Territory__c>();
    for (User_Territory__c objUserTerritory : lstOfUserTerritory) {
      if (mapOfUserToTerritory.containsKey(objUserTerritory.User__c)) {
        continue;
      }
      // Preparing mapping of user to its first territory ordered by territory name
      mapOfUserToTerritory.put(objUserTerritory.User__c, objUserTerritory);
    }
    return mapOfUserToTerritory;
  }

  /**
   * @description This method to set the territory for ML Lead
   * @name populateSobjectTerritory
   * @param lstOfSobject List of user territory records
   * @param mapOfUserToTerritory map of user territory records
   * @return records List of sObject records
   * @US CC-1054
   */
  @testVisible
  private static List<sObject> populateSobjectTerritory(
    List<sObject> lstOfSobject,
    Map<Id, User_Territory__c> mapOfUserToTerritory
  ) {
    if (mapOfUserToTerritory == null) {
      return new List<sObject>();
    }
    for (sObject objSobject : lstOfSobject) {
      if (mapOfUserToTerritory.containsKey((Id) objSobject.get('OwnerId'))) {
        //populating territory on sObject record
        objSobject.put(
          'Territory__c',
          mapOfUserToTerritory.get((Id) objSobject.get('OwnerId')).Territory__c
        );
      }
    }
    return lstOfSobject;
  }

  /**
   * @description This method is used to get record type API name of any object dynamically
   * @name getRecordTypeIdsByDeveloperName
   * @param strObjectName sobject name
   * @param lstDevelopername List of developername API Name
   * @return Set<Id> Set of developername API Name
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static Set<Id> getRecordTypeIdsByDeveloperName(
    String strObjectName,
    List<String> lstDevelopername
  ) {
    if (
      String.isBlank(strObjectName) ||
      lstDevelopername == null ||
      lstDevelopername.isEmpty()
    ) {
      return new Set<Id>();
    }
    SObjectType objType = Schema.getGlobalDescribe().get(strObjectName);
    Set<Id> setOfRecordTypeIds = new Set<Id>();
    for (String eachStr : lstDevelopername) {
      setOfRecordTypeIds.add(QueryRT.of(objType).getId(eachStr));
    }
    return setOfRecordTypeIds;
  }

  /**
   * @description This method to filter validated sobject record
   * @name filterValidateSobjectRecords
   * @param lstOfSobject list of sObject records
   * @param territoryConfigMgt Territory_Based_Sharing_Config__mdt of Territory Metadata
   * @return lstOfFilteredSobject list of sObjrcts records
   * @author Ashish Kumar
   * @US CC-1058
   */
  public static List<sObject> filterValidateSobjectRecords(
    List<sObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt territoryConfigMgt
  ) {
    if (lstOfSobject.isEmpty()) {
      return new List<Sobject>();
    }
    if (territoryConfigMgt.Eligible_Record_Types__c == null) {
      return lstOfSobject;
    }
    String sObjectName = lstOfSobject[0]
      .getSObjectType()
      .getDescribe()
      .getName();
    List<String> lstOfEligibleRTs = territoryConfigMgt.Eligible_Record_Types__c.split(
      ';'
    );
    Set<ID> setOfEligibleRTIds = getRecordTypeIdsByDeveloperName(
      sObjectName,
      lstOfEligibleRTs
    );
    SObjectField recordTypeField = lstOfSobject[0]
      .getSObjectType()
      .getDescribe()
      .fields.getMap()
      .get('recordTypeId');
    return ListUtil.filter(lstOfSobject)
      .equals(recordTypeField, setOfEligibleRTIds)
      .toList();
  }
  /**
   * @description This method to get map of OwnerId and User record
   * @name getMapOfUsers
   * @param lstOfSobject each sobject record
   * @return mapOfUsers Map of OwnerId and User
   * @author Ashish Kumar
   * @US CC-1058
   */
  @testVisible
  private static Map<Id, User> getMapOfUsers(List<sObject> lstOfSobject) {
    if (lstOfSobject.isEmpty()) {
      return null;
    }
    SObjectField ownerField = CommonUtil.getSObjectField(
      lstOfSobject[0],
      'OwnerId'
    );
    return USER_REPOSITORY.getUserMapFromUserIds(
      ListUtil.getIds(lstOfSobject, ownerField)
    );
  }

  /**
   * @description This method to get map of OwnerId and User record
   * @name assignTerritoryOnOwnerChange
   * @param oldMapSobject old map of sobject
   * @param lstOfSobject each sobject record
   * @author Ashish Kumar
   * @US CC-16111
   */
  public static void assignTerritoryOnOwnerChange(
    Map<Id, sObject> oldMapSobject,
    List<sObject> lstOfSobject
  ) {
    if (UserInfo.getUserRoleId() == QueryRole.mlFranchiseRole.Id) {
      return;
    }
    SObjectField ownerIdField = CommonUtil.getSObjectField(
      lstOfSobject[0],
      'OwnerId'
    );
    List<Sobject> lstOfOwnerChangeRecord = ListUtil.filter(
        lstOfSobject,
        oldMapSobject
      )
      .changed(ownerIdField)
      .toList();
    assignTerritoryForRecord(lstOfOwnerChangeRecord);
  }
}
