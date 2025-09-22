/**
 * @author Ashish Kumar
 * @since  06/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritorySharingUtil is class to handle common functionality related to territory sharing.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class TerritorySharingUtil {
  private static final String LOAN_WRITER = 'Loan Writer';
  private static final String STRING_UNRESTRICTED = 'Unrestricted';
  private static final String STR_TERRITORY = 'Territory';
  private static final String STR_FRANCHISE = 'Franchise';
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserTerritoryActionsRepository USER_TERRITORY_REPOSITORY = (UserTerritoryActionsRepository) Lib_InstanceProvider.forType(
    UserTerritoryActionsRepository.class
  );
  private static final TerritoryActionsRepository TERRITORY_REPOSITORY = (TerritoryActionsRepository) Lib_InstanceProvider.forType(
    TerritoryActionsRepository.class
  );
  private static final QueryTerritoryBasedSharingConfig TERRITORY_CONFIG = (QueryTerritoryBasedSharingConfig) Lib_InstanceProvider.forType(
    QueryTerritoryBasedSharingConfig.class
  );
  @TestVisible
  private class CustomSharingException extends Exception {
  }
  /**
   * @description This method to handle sharing of sobject records based on territory field of sobject
   * @name shareRecordByTerritory
   * @param oldMapSobject old map of sobject
   * @param lstOfSobject new list of sobject
   * @param strSobjectName sobject name
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static void shareRecordByTerritory(
    Map<Id, SObject> oldMapSobject,
    List<SObject> lstOfSobject,
    String strSobjectName
  ) {
    Territory_Based_Sharing_Config__mdt objTerritoryMtd = QueryTerritoryBasedSharingConfig.get(
      strSobjectName
    );
    if (objTerritoryMtd == null) {
      Logger.error('Territory sharing config metadata record not found.');
      Logger.saveLog();
      return;
    }
    if (lstOfSobject.isEmpty()) {
      return;
    }
    Territory_Base_Sharing_Event__e objTerritoryEvt = TerritorySharingUtilHelper.createSharingPE(
      lstOfSobject,
      strSobjectName,
      oldMapSobject,
      objTerritoryMtd
    );
    List<SObject> lstOfSobjectShareToInsert = TerritorySharingUtilHelper.reShareToOriginalOwner(
      lstOfSobject,
      strSobjectName,
      oldMapSobject,
      objTerritoryMtd
    );
    //inserting the share records for original record owner in order of owner change to avoid temporary record lose access on UI.
    DML_REPOSITORY.doInsert(
      lstOfSobjectShareToInsert,
      new DmlConfig().systemMode()
    );
    if (objTerritoryEvt == null || objTerritoryEvt.Record_Ids__c == null) {
      return;
    }
    DML_REPOSITORY.doPublish(objTerritoryEvt);
  }

  /**
   * @description This method to handle sharing of sobject records based on territory field of sobject
   * @name createShareRecordsByTerritory
   * @param lstOfSobject list of new sobject records
   * @param objMtd share object metadata record
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static void createShareRecordsByTerritory(
    List<SObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objMtd
  ) {
    if (lstOfSobject.isEmpty()) {
      return;
    }
    Set<Id> idsOfTerritory = (Set<Id>) ListUtil.getUniques(
      lstOfSobject,
      'Territory__c',
      Id.class
    );
    Set<Id> idsOfOwner = (Set<Id>) ListUtil.getUniques(
      lstOfSobject,
      'OwnerId',
      Id.class
    );
    List<User_Territory__c> lstOfUserTerritory = USER_TERRITORY_REPOSITORY.getUserTerritories(
      idsOfTerritory,
      idsOfOwner
    );
    Map<String, String> mapOfUserTerrKeyToRole = createMapUserTerritoryKeyToRoles(
      lstOfUserTerritory
    );
    Map<Id, List<User_Territory__c>> mapOfTerritoryToUsers = (Map<Id, List<User_Territory__c>>) ListUtil.groupBy(
      lstOfUserTerritory,
      User_Territory__c.Territory__c
    );

    List<SObject> lstOfSobjectsInTerritoryMap = filterRecordsByTerritoryInMap(
      lstOfSobject,
      mapOfTerritoryToUsers
    );
    if (lstOfSobjectsInTerritoryMap.isEmpty()) {
      return;
    }

    Map<String, List<User_Territory__c>> mapOfTerritoryUsers = getMapOfTerritoryUsers(
      mapOfTerritoryToUsers,
      lstOfSobjectsInTerritoryMap
    );

    // further filter map of territory users based on role of owner and territory access model
    Map<String, List<User_Territory__c>> mapOfNonLoanWriterUserToTerritories = getMapOfTerritoryUsersNonLWOwnedSobjects(
      mapOfTerritoryUsers,
      lstOfSobjectsInTerritoryMap,
      mapOfUserTerrKeyToRole
    );
    Map<String, List<User_Territory__c>> mapOfLoanWriterUserToTerritories = getMapOfTerritoryUsersLWOwnedSobjects(
      mapOfTerritoryUsers,
      lstOfSobjectsInTerritoryMap,
      mapOfUserTerrKeyToRole
    );

    Map<String, List<User_Territory__c>> mapOfUserToTerritoriesForSharing = TerritorySharingUtilHelper.mergeMaps(
      mapOfNonLoanWriterUserToTerritories,
      mapOfLoanWriterUserToTerritories
    );
    List<SObject> lstOfSobjectShare = new List<SObject>();
    for (SObject objSobject : lstOfSobjectsInTerritoryMap) {
      Type objType = Type.forName(objMtd.Sharing_Object__c);
      for (
        User_Territory__c objUT : mapOfUserToTerritoriesForSharing.get(
          (String) objSobject.get('OwnerId') +
          (String) objSobject.get('Territory__c')
        )
      ) {
        SObject objShareObject = (SObject) objType.newInstance();
        String strParentId = !objMtd.IsParentIdField__c
          ? objMtd.Object_Name__c + 'Id'
          : 'ParentId';
        String strAccessLevel = !objMtd.IsParentIdField__c
          ? objMtd.Object_Name__c + 'AccessLevel'
          : 'AccessLevel';
        objShareObject.put(strParentId, (Id) objSobject.get('Id'));
        objShareObject.put(strAccessLevel, 'Edit');
        objShareObject.put('UserOrGroupId', objUT.User__c);
        objShareObject.put('RowCause', objMtd.Row_Cause__c);
        lstOfSobjectShare.add(objShareObject);
      }
    }
    deleteShareRecords(lstOfSobject, objMtd);
    insertShareRecord(lstOfSobjectShare, objMtd);
  }

  /**
   * @description This method creates a map of user territory to share records owned by non-LW to non-LW users in territory,
   *              regardless of territory's access scope
   * @name getMapOfTerritoryUsersNonLWOwnedSobjects
   * @param mapOfTerritoryToUsers list of sobject records
   * @param lstOfSobject list of sobject records
   * @param mapOfUserTerrKeyToRole list of sobject records
   * @return Boolean
   * @author Ashish Kumar
   * @US CC-8176
   */
  @testvisible
  private static Map<String, List<User_Territory__c>> getMapOfTerritoryUsersNonLWOwnedSobjects(
    Map<String, List<User_Territory__c>> mapOfTerritoryToUsers,
    List<SObject> lstOfSobject,
    Map<String, String> mapOfUserTerrKeyToRole
  ) {
    Map<String, List<User_Territory__c>> mapOfValidRecords = new Map<String, List<User_Territory__c>>();
    String strOwnerRoleKey;
    for (SObject objSobject : lstOfSobject) {
      String key =
        (String) objSobject.get('OwnerId') +
        (String) objSobject.get('Territory__c');
      strOwnerRoleKey = getOwnerRoleKey(objSobject);
      mapOfValidRecords.put(key, new List<User_Territory__c>());
      for (User_Territory__c objUT : mapOfTerritoryToUsers.get(key)) {
        if (
          !mapOfUserTerrKeyToRole.containsKey(strOwnerRoleKey) ||
          mapOfUserTerrKeyToRole.get(strOwnerRoleKey) == LOAN_WRITER ||
          objUT.ML_Role__c == LOAN_WRITER
        ) {
          continue;
        }
        mapOfValidRecords.get(key).add(objUT);
      }
    }
    return mapOfValidRecords;
  }

  /**
   * @description This method creates a map of user territory to share records owned by LW to LW users in unrestricted territory,
   *              and to non-LW in territory regardless of scope.
   * @name getMapOfTerritoryUsersLWOwnedSobjects
   * @param mapOfTerritoryToUsers list of sobject records
   * @param lstOfSobject list of sobject records
   * @param mapOfUserTerrKeyToRole list of sobject records
   * @return Boolean
   * @author Ashish Kumar
   * @US CC-8176
   */
  @testvisible
  private static Map<String, List<User_Territory__c>> getMapOfTerritoryUsersLWOwnedSobjects(
    Map<String, List<User_Territory__c>> mapOfTerritoryToUsers,
    List<SObject> lstOfSobject,
    Map<String, String> mapOfUserTerrKeyToRole
  ) {
    Map<String, List<User_Territory__c>> mapOfValidRecords = new Map<String, List<User_Territory__c>>();
    String strOwnerRoleKey;
    for (SObject objSobject : lstOfSobject) {
      strOwnerRoleKey = getOwnerRoleKey(objSobject);
      String key =
        (String) objSobject.get('OwnerId') +
        (String) objSobject.get('Territory__c');
      mapOfValidRecords.put(key, new List<User_Territory__c>());
      for (User_Territory__c objUT : mapOfTerritoryToUsers.get(key)) {
        if (
          !mapOfUserTerrKeyToRole.containsKey(strOwnerRoleKey) ||
          mapOfUserTerrKeyToRole.get(strOwnerRoleKey) != LOAN_WRITER ||
          ((objUT.ML_Role__c != LOAN_WRITER ||
          objUT.Territory__r.Access_Scope__c != STRING_UNRESTRICTED) &&
          objUT.ML_Role__c == LOAN_WRITER)
        ) {
          continue;
        }
        mapOfValidRecords.get(key).add(objUT);
      }
    }
    return mapOfValidRecords;
  }

  /**
   * @description This method is used to get users within a particular territory, except for the record owner
   * @name getMapOfTerritoryUsers
   * @param mapOfTerritoryToUsers list of sobject records
   * @param lstOfSobject list of sobject records
   * @return Map<Id, List<User_Territory__c>>
   * @author Ashish Kumar
   * @US CC-8176
   */
  @testvisible
  private static Map<String, List<User_Territory__c>> getMapOfTerritoryUsers(
    Map<Id, List<User_Territory__c>> mapOfTerritoryToUsers,
    List<SObject> lstOfSobject
  ) {
    Map<String, List<User_Territory__c>> mapOfTerritoryUsers = new Map<String, List<User_Territory__c>>();
    for (SObject objSobject : lstOfSobject) {
      String key =
        (String) objSobject.get('OwnerId') +
        (String) objSobject.get('Territory__c');
      mapOfTerritoryUsers.put(key, new List<User_Territory__c>());
      for (
        User_Territory__c objUT : mapOfTerritoryToUsers.get(
          (Id) objSobject.get('Territory__c')
        )
      ) {
        if ((Id) objSobject.get('OwnerId') == objUT.User__c) {
          continue;
        }
        mapOfTerritoryUsers.get(key).add(objUT);
      }
    }
    return mapOfTerritoryUsers;
  }

  /**
   * @description This method is used to filter for sobject records within the territory map
   * @name filterRecordsByTerritoryInMap
   * @param lstOfSobject list of sobject records
   * @param mapOfTerritoryToUsers list of sobject records
   * @return List<SObject>
   * @author Ashish Kumar
   * @US CC-8176
   */
  @testvisible
  private static List<SObject> filterRecordsByTerritoryInMap(
    List<SObject> lstOfSobject,
    Map<Id, List<User_Territory__c>> mapOfTerritoryToUsers
  ) {
    if (lstOfSobject.isEmpty()) {
      return new List<SObject>();
    }
    SObjectField territoryField = CommonUtil.getSObjectField(
      lstOfSobject[0],
      'Territory__c'
    );
    return (List<SObject>) ListUtil.filter(lstOfSobject)
      .equals(territoryField, mapOfTerritoryToUsers.keySet())
      .toList();
  }

  /**
   * @description This method is used to prepare key of owner and territory for a sobject record
   * @name getOwnerRoleKey
   * @param objSobject list of sobject records
   * @return String
   * @author Ashish Kumar
   * @US CC-8176
   */
  @testvisible
  private static String getOwnerRoleKey(SObject objSobject) {
    return (String) objSobject.get('OwnerId') +
      (String) objSobject.get('Territory__c');
  }

  /**
   * @description This method is used to prepare map of user+territory to the role of that user in that territory.
   * @name createMapUserTerritoryKeyToRoles
   * @param lstOfUserTerritory list of sobject records
   * @return Map<String, String>
   * @author Ashish Kumar
   * @US CC-8176
   */
  @testvisible
  private static Map<String, String> createMapUserTerritoryKeyToRoles(
    List<User_Territory__c> lstOfUserTerritory
  ) {
    Map<String, String> mapOfUserTerrKeyToRole = new Map<String, String>();
    for (User_Territory__c objUserTerritory : lstOfUserTerritory) {
      mapOfUserTerrKeyToRole.put(
        (String) objUserTerritory.User__c +
        (String) objUserTerritory.Territory__c,
        objUserTerritory.ML_Role__c
      );
    }
    return mapOfUserTerrKeyToRole;
  }

  /**
   * @description This method to create share record for sobject having franchise scope
   * @name createShareRecordsByFranchise
   * @param lstOfSobject list of new sobject records
   * @param objMtd share object metadata record
   * @author Ashish Kumar
   * @US CC-3659
   */
  public static void createShareRecordsByFranchise(
    List<SObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objMtd
  ) {
    if (lstOfSobject.isEmpty()) {
      return;
    }
    Set<Id> idsOfTerritory = (Set<Id>) ListUtil.getUniques(
      lstOfSobject,
      'Territory__c',
      Id.class
    );
    Map<Id, Territory__c> mapOfTerritory = TERRITORY_REPOSITORY.getTerritoryMap(
      idsOfTerritory
    );
    Set<Id> idsOfFranchiseOwner = ListUtil.getIds(
      mapOfTerritory.values(),
      Territory__c.Primary_Franchise_Owner__c
    );
    List<SObject> lstOfShareRecord = new List<SObject>();
    Map<Id, List<User_Territory__c>> mapOfFranchiseToUsers = TerritoryCommonUtilsHelper.getUserTerritoryFranchiseWise(
      idsOfFranchiseOwner
    );
    for (SObject objSobject : lstOfSobject) {
      Type objType = Type.forName(objMtd.Sharing_Object__c);
      for (
        User_Territory__c objUT : mapOfFranchiseToUsers.get(
          mapOfTerritory.get((String) objSobject.get('Territory__c'))
            .Primary_Franchise_Owner__c
        )
      ) {
        if ((Id) objSobject.get('OwnerId') == objUT.User__c) {
          continue;
        }
        SObject objShareObject = (SObject) objType.newInstance();
        String strParentId = !objMtd.IsParentIdField__c
          ? objMtd.Object_Name__c + 'Id'
          : 'ParentId';
        String strAccessLevel = !objMtd.IsParentIdField__c
          ? objMtd.Object_Name__c + 'AccessLevel'
          : 'AccessLevel';
        objShareObject.put(strParentId, (Id) objSobject.get('Id'));
        objShareObject.put(strAccessLevel, 'Edit');
        objShareObject.put('UserOrGroupId', objUT.User__c);
        objShareObject.put('RowCause', objMtd.Row_Cause__c);
        lstOfShareRecord.add(objShareObject);
      }
    }
    deleteShareRecords(lstOfSobject, objMtd);
    insertShareRecord(lstOfShareRecord, objMtd);
  }

  /**
   * @description This method is used share sobject record based on parent object sharing modal
   * @name createShareRecordsForParentObj
   * @param lstOfSobject list of sobject records
   * @param objTerritoryMtd territory sharing metadata record
   * @author Ashish Kumar
   * @US CC-5207
   */
  public static void createShareRecordsForParentObj(
    List<SObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    if (lstOfSobject.isEmpty()) {
      return;
    }
    List<String> listEligibleRTs = TerritorySharingUtilHelper.getEligibleRT(
      objTerritoryMtd
    );
    Set<Id> setOfEligibleRT = TerritoryCommonUtils.getRecordTypeIdsByDeveloperName(
      objTerritoryMtd.Object_Name__c,
      listEligibleRTs
    );
    if (
      setOfEligibleRT == null ||
      setOfEligibleRT.isEmpty() ||
      objTerritoryMtd.Lookup_Fields__c == null
    ) {
      return;
    }
    Map<String, Territory_Based_Sharing_Config__mdt> mapOfTerritoryConfig = QueryTerritoryBasedSharingConfig.territorySharingConfigByObjectMap;
    if (mapOfTerritoryConfig == null) {
      return;
    }
    WrapSobjectBasedOnScope objClass = filterSobjectBasedOnTerritoryScope(
      lstOfSobject,
      objTerritoryMtd,
      mapOfTerritoryConfig
    );

    if (objClass == null) {
      return;
    }
    createShareRecordsByTerritory(
      objClass.lstOfTerritoryShareRecord,
      objTerritoryMtd
    );
    createShareRecordsByFranchise(
      objClass.lstOfFranchiseShareRecord,
      objTerritoryMtd
    );
  }

  /**
   * @description This method to fetch the territory sharing metadata record
   * @name filterSobjectBasedOnTerritoryScope
   * @param lstOfSobject list of sobject records
   * @param objTerritoryMtd territory sharing metadata record
   * @param mapOfTerritoryConfig map of territory sharing metadata record
   * @return WrapSobjectBasedOnScope
   * @author Ashish Kumar
   * @US CC-8176
   */
  @testvisible
  private static WrapSobjectBasedOnScope filterSobjectBasedOnTerritoryScope(
    List<SObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd,
    Map<String, Territory_Based_Sharing_Config__mdt> mapOfTerritoryConfig
  ) {
    WrapSobjectBasedOnScope objClass = new WrapSobjectBasedOnScope(
      lstOfSobject[0]
    );
    for (SObject objSobject : lstOfSobject) {
      for (String strLookUp : objTerritoryMtd.Lookup_Fields__c.split(';')) {
        if ((Id) objSobject.get(strLookUp) == null) {
          continue;
        }
        String objName = getSobjectType(objSobject, strLookUp);
        if (
          mapOfTerritoryConfig.get(objName)?.Sharing_Scope__c == STR_TERRITORY
        ) {
          objClass.lstOfTerritoryShareRecord.add(objSobject);
        } else if (
          mapOfTerritoryConfig.get(objName)?.Sharing_Scope__c == STR_FRANCHISE
        ) {
          objClass.lstOfFranchiseShareRecord.add(objSobject);
        }
        break;
      }
    }
    return objClass;
  }

  /**
   * @description This method to get the type of sobject based on lookup field
   * @name getSobjectType
   * @param objSobject list of sobject records
   * @param strLookUpField territory sharing metadata record
   * @return String
   * @author Ashish Kumar
   * @US CC-8176
   */
  @testvisible
  private static String getSobjectType(
    SObject objSobject,
    String strLookUpField
  ) {
    return ((Id) objSobject.get(strLookUpField)).getSObjectType().toString();
  }

  /**
   * @description This method is used to create dynamic instance of object.
   * @name insertShareRecord
   * @param lstOfSobject list of sobject record to process
   * @param objMtd share object metadata record
   * @author Ashish Kumar
   * @US CC-4418
   */
  @testvisible
  private static void insertShareRecord(
    List<SObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objMtd
  ) {
    String strFieldColumn = objMtd.IsParentIdField__c == true
      ? 'ParentId'
      : objMtd.Object_Name__c + 'Id';
    Database.SaveResult[] lstOfResults = DML_REPOSITORY.doInsert(
      lstOfSobject,
      new DMLConfig().allowPartial().systemMode()
    );
    if (lstOfResults == null) {
      return;
    }
    List<WrapSharingError> lstOfSharingError = new List<WrapSharingError>();
    for (integer i = 0; i < lstOfResults.size(); i++) {
      if (lstOfResults.get(i).isSuccess()) {
        continue;
      }
      Database.Error error = lstOfResults.get(i).getErrors().get(0);
      lstOfSharingError.add(
        new WrapSharingError(
          (String) lstOfSobject[i].get(strFieldColumn),
          (String) lstOfSobject[i].get('UserOrGroupId'),
          error.getMessage()
        )
      );
    }

    if (lstOfSharingError.isEmpty()) {
      return;
    }
    Logger.error(
      'Error occured while creating ' + objMtd.Sharing_Object__c + ' record',
      processSharingException(lstOfSharingError)
    );
    Logger.saveLog();
  }

  /**
   * @description This method is used to delete share record dynamically.
   * @name deleteShareRecords
   * @param lstOfSobject list of new sobject records
   * @param objMtd share object metadata record
   * @author Ashish Kumar
   * @US CC-1894
   */
  @TestVisible
  private static void deleteShareRecords(
    List<SObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objMtd
  ) {
    String strParentField = objMtd.IsParentIdField__c == true
      ? 'ParentId'
      : objMtd.Object_Name__c + 'Id';
    List<SObject> lstOfSobjectShareToDelete = TERRITORY_REPOSITORY.getShareRecords(
      lstOfSobject,
      objMtd,
      strParentField
    );
    if (lstOfSobjectShareToDelete.isEmpty()) {
      return;
    }
    Database.DeleteResult[] lstOfDeleteResults = DML_REPOSITORY.doDelete(
      lstOfSobjectShareToDelete,
      new DMLConfig().allowPartial().systemMode()
    );
    if (lstOfDeleteResults == null) {
      return;
    }
    List<WrapSharingError> lstOfSharingError = new List<WrapSharingError>();
    for (integer i = 0; i < lstOfDeleteResults.size(); i++) {
      if (lstOfDeleteResults.get(i).isSuccess()) {
        continue;
      }
      Database.Error error = lstOfDeleteResults.get(i).getErrors().get(0);
      lstOfSharingError.add(
        new WrapSharingError(
          (String) lstOfSobjectShareToDelete[i].get(strParentField),
          (String) lstOfSobjectShareToDelete[i].get('UserOrGroupId'),
          error.getMessage()
        )
      );
    }

    if (lstOfSharingError.isEmpty()) {
      return;
    }
    Logger.error(
      'Error occured while deleting ' + objMtd.Sharing_Object__c + ' record',
      processSharingException(lstOfSharingError)
    );
    Logger.saveLog();
  }

  /**
   * @description This method is return custom error message related to sharing record error
   * @name processSharingException
   * @param lstOfSharingError list of record on which error occurs
   * @return Exception exception object
   * @author Ashish Kumar
   * @US CC-4418
   */
  @TestVisible
  private static Exception processSharingException(
    List<wrapSharingError> lstOfSharingError
  ) {
    Schema.DescribeFieldResult objDescribe = LogEntry__c.ExceptionMessage__c.getDescribe();
    Integer lengthOfField = objDescribe.getLength();
    return new CustomSharingException(
      JSON.serializePretty(lstOfSharingError).length() > lengthOfField
        ? JSON.serializePretty(lstOfSharingError).substring(0, lengthOfField)
        : JSON.serializePretty(lstOfSharingError)
    );
  }

  /**
   * @description This is wrapper class to create JSON in userid and recordid mapping
   * @name WrapSharingError
   * @author Ashish Kumar
   * @US CC-4418
   */
  @TestVisible
  private class WrapSharingError {
    public String recordId;
    public String userId;
    public String errMsg;

    /**
     * @description This is constructor to create JSON in userid and recordid mapping
     * @name WrapSharingError
     * @param recordId sobject recordid for which sharing failed
     * @param userId user id for which sharing failed
     * @param errMsg error message
     * @author Ashish Kumar
     * @US CC-4418
     */
    public WrapSharingError(String recordId, String userId, String errMsg) {
      this.recordId = recordId;
      this.userId = userId;
      this.errMsg = errMsg;
    }
  }

  /**
   * @description This is wrapper class to create JSON in userid and recordid mapping
   * @name WrapSharingError
   * @author Ashish Kumar
   * @US CC-4418
   */
  @TestVisible
  private class WrapSobjectBasedOnScope {
    @TestVisible
    private List<SObject> lstOfTerritoryShareRecord;
    @TestVisible
    private List<SObject> lstOfFranchiseShareRecord;

    /**
     * @description This is constructor to initialize SObject Record lists dynamically
     * @name WrapSobjectBasedOnScope
     * @param record SObject to initialize as List<ObjectName>
     */
    public WrapSobjectBasedOnScope(SObject record) {
      String objectType = String.valueOf(record.getSObjectType());
      this.lstOfTerritoryShareRecord = (List<SObject>) Type.forName(
          'List<' + objectType + '>'
        )
        .newInstance();
      this.lstOfFranchiseShareRecord = (List<SObject>) Type.forName(
          'List<' + objectType + '>'
        )
        .newInstance();
    }
  }
}
