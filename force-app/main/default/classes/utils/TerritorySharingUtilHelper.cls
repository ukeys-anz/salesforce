/**
 * @author Ashish Kumar
 * @since  05/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritorySharingUtilHelper is helper class to handle functionality related to territory sharing.
 */
public without sharing class TerritorySharingUtilHelper {
  /**
   * @description This method creates the platform events for asynchronous sobject territory sharing
   * @name createSharingPE
   * @param lstOfSobject List of sobjects
   * @param strSobjectName sobject API name
   * @param oldMapSobject List of oldmap Sobjects
   * @param objTerritoryMtd Territory sharing MDT
   * @return The territory sharing platform event
   * @author Ashish Kumar
   */
  public static Territory_Base_Sharing_Event__e createSharingPE(
    List<sObject> lstOfSobject,
    String strSobjectName,
    Map<Id, sObject> oldMapSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    if (isExcludedUsers(objTerritoryMtd, UserInfo.getUserName())) {
      return null;
    }

    List<sObject> lstOfFilteredSobjectByRT = TerritoryCommonUtils.filterValidateSobjectRecords(
      lstOfSobject,
      objTerritoryMtd
    );
    if (lstOfFilteredSobjectByRT.isEmpty()) {
      return null;
    }
    Map<Id, sObject> mapOfFilteredByOwnerChanged = filterRecordsByOwnerChanged(
      lstOfFilteredSobjectByRT,
      oldMapSobject
    );
    Map<Id, sObject> mapOfFilteredByTerritoryChanged = filterRecordsByTerritoryChanged(
      lstOfFilteredSobjectByRT,
      oldMapSobject,
      objTerritoryMtd
    );

    List<sObject> lstOfFilteredSobjectByOwnerOrTerritory = new List<sObject>();
    lstOfFilteredSobjectByOwnerOrTerritory.addAll(
      mapOfFilteredByOwnerChanged.values()
    );
    lstOfFilteredSobjectByOwnerOrTerritory.addAll(
      mapOfFilteredByTerritoryChanged.values()
    );

    Territory_Base_Sharing_Event__e objTerritoryEvt = new Territory_Base_Sharing_Event__e(
      Trigger_Object__c = strSobjectName
    );
    return populateRecordIdsForPE(
      lstOfFilteredSobjectByOwnerOrTerritory,
      objTerritoryEvt
    );
  }

  /**
   * @description This method reshare sobject records back to original owner. This prevents user immediately losing
   *              visibility of record in the UI once they re-assigned to another user.
   * @name reShareToOriginalOwner
   * @param lstOfSobject List of sobjects
   * @param strSobjectName sobject API name
   * @param oldMapSobject List of oldmap Sobjects
   * @param objTerritoryMtd Territory sharing MDT
   * @return List of sharing sobject records to insert
   * @author Ashish Kumar
   */
  public static List<Sobject> reShareToOriginalOwner(
    List<sObject> lstOfSobject,
    String strSobjectName,
    Map<Id, sObject> oldMapSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    if (oldMapSobject == null) {
      return new List<sObject>();
    }
    if (isExcludedUsers(objTerritoryMtd, UserInfo.getUserName())) {
      return new List<sObject>();
    }
    List<Sobject> lstOfShareRecord = new List<Sobject>();
    List<sObject> lstOfFilteredSobjectByRT = TerritoryCommonUtils.filterValidateSobjectRecords(
      lstOfSobject,
      objTerritoryMtd
    );
    // If sobject is a lead, only reshare if lead is not expired.
    List<sObject> lstOfUnexpiredLeadIfSobjectTypeLead = filterForUnExpiredLeadsIfSobjectTypeLead(
      strSobjectName,
      lstOfFilteredSobjectByRT
    );
    if (lstOfUnexpiredLeadIfSobjectTypeLead.isEmpty()) {
      return new List<sObject>();
    }
    SObjectField ownerIdField = CommonUtil.getSObjectField(
      lstOfUnexpiredLeadIfSobjectTypeLead[0],
      'OwnerId'
    );
    List<sObject> lstOfFilteredByOwnerChanged = ListUtil.filter(
        lstOfUnexpiredLeadIfSobjectTypeLead,
        oldMapSobject
      )
      .changed(ownerIdField)
      .toList();
    for (sObject record : lstOfFilteredByOwnerChanged) {
      lstOfShareRecord.add(
        prepareSobjectShareRecord(
          strSobjectName,
          record,
          objTerritoryMtd,
          UserInfo.getUserId()
        )
      );
    }
    return lstOfShareRecord;
  }

  /**
   * @description This method filters for records with owner changed and puts them in a map
   * @name filterRecordsByOwnerChanged
   * @param lstOfSobject List of sobjects
   * @param oldMapSobject Map of oldmap Sobjects
   * @return Map<Id,sObject>
   * @author Ashish Kumar
   */
  @testVisible
  private static Map<Id, sObject> filterRecordsByOwnerChanged(
    List<sObject> lstOfSobject,
    Map<Id, sObject> oldMapSobject
  ) {
    if (lstOfSobject.isEmpty()) {
      return new Map<Id, sObject>();
    }
    if (oldMapSobject == null) {
      return new Map<Id, sObject>(lstOfSobject);
    }
    SObjectField ownerIdField = CommonUtil.getSObjectField(
      lstOfSobject[0],
      'OwnerId'
    );
    List<sObject> filteredChangedOwnerRecords = ListUtil.filter(
        lstOfSobject,
        oldMapSobject
      )
      .changed(ownerIdField)
      .toList();
    return new Map<Id, sObject>(filteredChangedOwnerRecords);
  }

  /**
   * @description This method filters for records with territory changed and puts them in a map
   * @name filterRecordsByTerritoryChanged
   * @param lstOfSobject List of sobjects
   * @param oldMapSobject Map of oldmap Sobjects
   * @param objTerritoryMtd Territory sharing custom metadata type object
   * @return Map<Id,sObject>
   * @author Ashish Kumar
   */
  @testVisible
  private static Map<Id, sObject> filterRecordsByTerritoryChanged(
    List<sObject> lstOfSobject,
    Map<Id, sObject> oldMapSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    if (lstOfSobject.isEmpty()) {
      return new Map<Id, sObject>();
    }
    if (oldMapSobject == null) {
      return new Map<Id, sObject>(lstOfSobject);
    }
    SObjectField territoryIdField = CommonUtil.getSObjectField(
      lstOfSobject[0],
      objTerritoryMtd.Territory_Field__c
    );
    List<sObject> filteredChangedTerritoryRecords = ListUtil.filter(
        lstOfSobject,
        oldMapSobject
      )
      .changed(territoryIdField)
      .toList();
    return new Map<Id, sObject>(filteredChangedTerritoryRecords);
  }
  /**
   * @description This method validates that the user is an excluded user for the sobject's territory sharing configuration
   * @name isExcludedUsers
   * @param objTerritoryMtd Territory sharing custom metadata type object
   * @param userName username of user
   * @return Boolean
   * @author Ashish Kumar
   */
  @testVisible
  private static Boolean isExcludedUsers(
    Territory_Based_Sharing_Config__mdt objTerritoryMtd,
    String userName
  ) {
    return (objTerritoryMtd.Excluded_Users__c != null &&
    objTerritoryMtd.Excluded_Users__c.containsIgnoreCase(userName));
  }

  /**
   * @description This method filters for Lead records with status of Expired
   * @name filterForUnExpiredLeadsIfSobjectTypeLead
   * @param strSobjectName sobject Name
   * @param lstOfSobject List of sobjects
   * @return List<sObject> List of valid sobjects records
   * @author Ashish Kumar
   */
  @testVisible
  private static List<sObject> filterForUnExpiredLeadsIfSobjectTypeLead(
    String strSobjectName,
    List<sObject> lstOfSobject
  ) {
    List<sObject> lstOfValidSobjectRecord = (List<SObject>) Type.forName(
        'List<' + strSobjectName + '>'
      )
      .newInstance();
    for (sObject objSobject : lstOfSobject) {
      if (strSobjectName == 'Lead' && objSobject.get('Status') == 'Expired') {
        continue;
      }
      lstOfValidSobjectRecord.add(objSobject);
    }
    return lstOfValidSobjectRecord;
  }

  /**
   * @description This method populates and appends the Record Type Ids field on the sharing platform event
   * @name populateRecordIdsForPE
   * @param lstOfFilteredSobject List of sobjects
   * @param objTerritoryEvt Territory sharing custom platform object
   * @return Territory_Base_Sharing_Event__e Territory platform object
   * @author Ashish Kumar
   */
  @testVisible
  private static Territory_Base_Sharing_Event__e populateRecordIdsForPE(
    List<sObject> lstOfFilteredSobject,
    Territory_Base_Sharing_Event__e objTerritoryEvt
  ) {
    for (sObject objSobject : lstOfFilteredSobject) {
      if (objTerritoryEvt.Record_Ids__c == null) {
        objTerritoryEvt.Record_Ids__c = objSobject.Id;
      } else {
        objTerritoryEvt.Record_Ids__c =
          objTerritoryEvt.Record_Ids__c +
          ';' +
          objSobject.Id;
      }
    }
    return objTerritoryEvt;
  }

  /**
   * @description This method creates sharing record for an sobject record
   * @name prepareSobjectShareRecord
   * @param strSobjectName sobject Name
   * @param record sobject record
   * @param objTerritoryMtd Territory sharing custom metadata type object
   * @param userId userId
   * @return List<sObject>
   * @author Ashish Kumar
   */
  public static sObject prepareSobjectShareRecord(
    String strSobjectName,
    sObject record,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd,
    Id userId
  ) {
    Sobject objShareObject = getNewSObject(objTerritoryMtd.Sharing_Object__c);
    String strParentId = !objTerritoryMtd.IsParentIdField__c
      ? strSobjectName + 'Id'
      : 'ParentId';
    String strAccessLevel = !objTerritoryMtd.IsParentIdField__c
      ? strSobjectName + 'AccessLevel'
      : 'AccessLevel';
    objShareObject.put(strParentId, record.Id);
    objShareObject.put(strAccessLevel, 'Edit');
    objShareObject.put('UserOrGroupId', userId);
    objShareObject.put('RowCause', objTerritoryMtd.Row_Cause__c);
    return objShareObject;
  }

  /**
   * @author Ashish Kumar
   * @since  06/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name mergeMaps
   * @param map1 map of user Territory
   * @param map2 map of user Territory
   * @return Map<String, List<User_Territory__c>> map of merged maps
   * @description  This method is used to merge maps
   */

  public static Map<String, List<User_Territory__c>> mergeMaps(
    Map<String, List<User_Territory__c>> map1,
    Map<String, List<User_Territory__c>> map2
  ) {
    Map<String, List<User_Territory__c>> results = new Map<String, List<User_Territory__c>>();
    for (String key : map1.keyset()) {
      if (!results.containsKey(key)) {
        results.put(key, new List<User_Territory__c>());
      }
      results.get(key).addAll(map1.get(key));
    }

    for (String key : map2.keyset()) {
      if (!results.containsKey(key)) {
        results.put(key, new List<User_Territory__c>());
      }
      results.get(key).addAll(map2.get(key));
    }
    return results;
  }

  /**
   * @description This method returns list of eligible record types for Territory sharing
   * @name getEligibleRT
   * @param objTerritoryMtd Territory sharing custom metadata type object
   * @return List<String> of eligible record type ids
   * @author Ashish Kumar
   */
  public static List<String> getEligibleRT(
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    return objTerritoryMtd.Eligible_Record_Types__c?.split(';');
  }
  /**
   * @description This method is used to create dynamic instance of object.
   * @name getNewSobject
   * @param strSobjectName sobject name
   * @return SObject
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static SObject getNewSobject(String strSobjectName) {
    return (SObject) Type.forName('Schema.' + strSobjectName).newInstance();
  }
}
