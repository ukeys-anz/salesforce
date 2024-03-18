/**
 * @author Ashish Kumar
 * @since  06/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMSharingUtil is class to handle common functionality related to territory sharing.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class MLCRMSharingUtil {
  private class CustomSharingException extends Exception {
  }
  private static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

  /**
   * @description This method to handle sharing of territory record with the franchise
   * @name shareRecordByTerritory
   * @param oldMapSobject old map of sobject
   * @param lstOfSobject new list of sobject
   * @param strSobjectName sobject name
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static void shareRecordByTerritory(
    Map<Id, sObject> oldMapSobject,
    List<sObject> lstOfSobject,
    String strSobjectName
  ) {
    Territory_Based_Sharing_Config__mdt objTerritoryMtd = getTerritoryRecords(
      strSobjectName
    );
    if (objTerritoryMtd == null) {
      Logger.error('Territory sharing config metadata record not found.');
      Logger.saveLog();
      return;
    }

    Territory_Base_Sharing_Event__e objTerritoryEvt = createSharingPE(
      lstOfSobject,
      strSobjectName,
      oldMapSobject,
      objTerritoryMtd
    );
    List<Sobject> lstOfLeadShareToInsert = reShareToOriginalOwner(
      lstOfSobject,
      strSobjectName,
      oldMapSobject,
      objTerritoryMtd
    );

    if (!lstOfLeadShareToInsert.isEmpty()) {
      //inserting the share records for original record owner in order of owner change to avoid temporary record lose access on UI.
      try {
        insert lstOfLeadShareToInsert;
      } catch (Exception ex) {
        Logger.error('Error while creating share record for original user', ex);
        Logger.saveLog();
      }
    }
    if (objTerritoryEvt != null && objTerritoryEvt.Record_Ids__c != null) {
      Database.SaveResult results = EventBus.publish(objTerritoryEvt);
      if (!results.isSuccess()) {
        Logger.error(
          'Error occured while publishing territory sharing platform event.',
          results
        );
        Logger.saveLog();
      }
    }
  }

  /**
   * @description This method to fetch territory share metadata record for a particular sobject.
   * @name getTerritoryRecords
   * @param strObjectName sobject name
   * @return Territory_Based_Sharing_Config__mdt Territory metadata records
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static Territory_Based_Sharing_Config__mdt getTerritoryRecords(
    String strObjectName
  ) {
    List<Territory_Based_Sharing_Config__mdt> lstOfTerritoryMtd = Territory_Based_Sharing_Config__mdt.getAll()
      .Values();
    if (!lstOfTerritoryMtd.isEmpty()) {
      for (
        Territory_Based_Sharing_Config__mdt objTerritoryMtd : lstOfTerritoryMtd
      ) {
        if (
          objTerritoryMtd.Active__c &&
          objTerritoryMtd.Object_Name__c.equalsIgnoreCase(strObjectName)
        ) {
          return objTerritoryMtd;
        }
      }
    }
    return null;
  }

  /**
   * @description This method to fetch territory share metadata record for a particular sobject.
   * @name createTerritoryShareRecords
   * @param lstOfSobject list of new sobject records
   * @param objMtd share object metadata record
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static void createTerritoryShareRecords(
    List<sObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objMtd
  ) {
    Map<Id, List<User_Territory__c>> mapOfTerritoryToUsers = new Map<Id, List<User_Territory__c>>();
    Set<Id> idsOfTerritory = new Set<Id>();
    Map<String, String> mapOfUserToRole = new Map<String, String>();
    if (!lstOfSobject.isEmpty()) {
      for (sObject objSobject : lstOfSobject) {
        idsOfTerritory.add((Id) objSobject.get('Territory__c'));
      }
    }

    if (!idsOfTerritory.isEmpty()) {
      List<User_Territory__c> lstOfUserTerritory = [
        SELECT
          Id,
          ML_Role__c,
          User__c,
          Territory__c,
          Territory__r.Access_Scope__c
        FROM User_Territory__c
        WHERE
          Status__c = :MLCRMConstants.STATUS_ACTIVE
          AND Territory__c IN :idsOfTerritory
      ];
      for (User_Territory__c objTerritory : lstOfUserTerritory) {
        mapOfUserToRole.put(
          (String) objTerritory.User__c + (String) objTerritory.Territory__c,
          objTerritory.ML_Role__c
        );
        if (!mapOfTerritoryToUsers.containsKey(objTerritory.Territory__c)) {
          mapOfTerritoryToUsers.put(
            objTerritory.Territory__c,
            new List<User_Territory__c>()
          );
        }
        mapOfTerritoryToUsers.get(objTerritory.Territory__c).add(objTerritory);
      }
    }
    List<Sobject> lstOfLeadShare = new List<Sobject>();
    String strUserRoleKey;
    //Creating the share record for user who are within the same territory.
    for (sObject objSobject : lstOfSobject) {
      strUserRoleKey =
        (String) objSobject.get('OwnerId') +
        (String) objSobject.get('Territory__c');
      for (
        User_Territory__c objUT : mapOfTerritoryToUsers.get(
          (Id) objSobject.get('Territory__c')
        )
      ) {
        Sobject objShareObject = getNewSObject(objMtd.Sharing_Object__c);
        // Condition to handle sharing of record for standard share object. Logic to make sure Loan writer are not able to see FO, FM and
        // Admin records. However FO, FM and Admin are able to see LW's records. LWs can see other LWs' records in unrestricted territories.
        // In restricted territories, no records are shared with LWs.
        if (
          mapOfUserToRole.containsKey(strUserRoleKey) &&
          ((mapOfUserToRole.get(strUserRoleKey) != MLCRMConstants.LOAN_WRITER &&
          objUT.ML_Role__c != MLCRMConstants.LOAN_WRITER) ||
          (mapOfUserToRole.get(strUserRoleKey) == MLCRMConstants.LOAN_WRITER &&
          ((objUT.ML_Role__c == MLCRMConstants.LOAN_WRITER &&
          objUT.Territory__r.Access_Scope__c ==
          MLCRMConstants.STRING_UNRESTRICTED) ||
          objUT.ML_Role__c != MLCRMConstants.LOAN_WRITER))) &&
          !objMtd.IsParentIdField__c &&
          (Id) objSobject.get('OwnerId') != objUT.User__c
        ) {
          objShareObject.put(
            objMtd.Object_Name__c + 'Id',
            (Id) objSobject.get('Id')
          );
          objShareObject.put(objMtd.Object_Name__c + 'AccessLevel', 'Edit');
          objShareObject.put('UserOrGroupId', objUT.User__c);
          objShareObject.put('RowCause', objMtd.Row_Cause__c);
          lstOfLeadShare.add(objShareObject);
        } else if (
          mapOfUserToRole.containsKey(strUserRoleKey) &&
          ((mapOfUserToRole.get(strUserRoleKey) != MLCRMConstants.LOAN_WRITER &&
          objUT.ML_Role__c != MLCRMConstants.LOAN_WRITER) ||
          (mapOfUserToRole.get(strUserRoleKey) == MLCRMConstants.LOAN_WRITER &&
          ((objUT.ML_Role__c == MLCRMConstants.LOAN_WRITER &&
          objUT.Territory__r.Access_Scope__c ==
          MLCRMConstants.STRING_UNRESTRICTED) ||
          objUT.ML_Role__c != MLCRMConstants.LOAN_WRITER))) &&
          objMtd.IsParentIdField__c &&
          (Id) objSobject.get('OwnerId') != objUT.User__c
        ) {
          // Condition to handle sharing of record for custom share object. Logic to make sure Loan writer are not able to see FO, FM and
          // Admin records. However FO, FM and Admin are able to see LW's records. LWs can see other LWs' records in unrestricted territories.
          // In restricted territories, no records are shared with LWs.
          objShareObject.put('ParentId', (Id) objSobject.get('Id'));
          objShareObject.put('AccessLevel', 'Edit');
          objShareObject.put('UserOrGroupId', objUT.User__c);
          objShareObject.put('RowCause', objMtd.Row_Cause__c);
          lstOfLeadShare.add(objShareObject);
        }
      }
    }
    if (!lstOfSobject.isEmpty()) {
      deleteShareRecords(lstOfSobject, objMtd);
    }

    if (!lstOfLeadShare.isEmpty()) {
      insertShareRecord(lstOfLeadShare, objMtd);
    }
  }

  /**
   * @description This method to create share record for sobject having franchise scope
   * @name createShareRecordsFranchiseWise
   * @param lstOfSobject list of new sobject records
   * @param objMtd share object metadata record
   * @author Ashish Kumar
   * @US CC-3659
   */
  public static void createShareRecordsFranchiseWise(
    List<sObject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objMtd
  ) {
    Map<Id, List<User_Territory__c>> mapOfFranchiseToUsers = new Map<Id, List<User_Territory__c>>();
    Set<Id> idsOfTerritory = new Set<Id>();
    Set<Id> idsOfFranchiseOwner = new Set<Id>();
    Map<String, String> mapOfUserToRole = new Map<String, String>();
    Map<Id, Territory__c> mapOfTerritory;
    List<Sobject> lstOfShareRecord = new List<Sobject>();
    for (sObject objSobject : lstOfSobject) {
      idsOfTerritory.add((Id) objSobject.get('Territory__c'));
    }

    if (!idsOfTerritory.isEmpty()) {
      mapOfTerritory = new Map<Id, Territory__c>(
        [
          SELECT Primary_Franchise_Owner__c
          FROM Territory__c
          WHERE ID IN :idsOfTerritory
        ]
      );
      for (Territory__c objTerritory : mapOfTerritory.values()) {
        if (objTerritory.Primary_Franchise_Owner__c != null) {
          idsOfFranchiseOwner.add(objTerritory.Primary_Franchise_Owner__c);
        }
      }
    }

    if (!idsOfFranchiseOwner.isEmpty()) {
      for (User_Territory__c objUT : [
        SELECT Id, Territory__r.Primary_Franchise_Owner__c, User__c
        FROM User_Territory__c
        WHERE
          Territory__r.Primary_Franchise_Owner__c IN :idsOfFranchiseOwner
          AND Status__c = :MLCRMConstants.STATUS_ACTIVE
      ]) {
        if (
          !mapOfFranchiseToUsers.containsKey(
            objUT.Territory__r.Primary_Franchise_Owner__c
          )
        ) {
          mapOfFranchiseToUsers.put(
            objUT.Territory__r.Primary_Franchise_Owner__c,
            new List<User_Territory__c>()
          );
        }
        mapOfFranchiseToUsers.get(objUT.Territory__r.Primary_Franchise_Owner__c)
          .add(objUT);
      }

      for (sObject objSobject : lstOfSobject) {
        if (
          mapOfTerritory.get((Id) objSobject.get('Territory__c'))
            .Primary_Franchise_Owner__c != null
        ) {
          for (
            User_Territory__c objUT : mapOfFranchiseToUsers.get(
              mapOfTerritory.get((Id) objSobject.get('Territory__c'))
                .Primary_Franchise_Owner__c
            )
          ) {
            Sobject objShareObject = getNewSObject(objMtd.Sharing_Object__c);
            if (
              !objMtd.IsParentIdField__c &&
              (Id) objSobject.get('OwnerId') != objUT.User__c
            ) {
              objShareObject.put(
                objMtd.Object_Name__c + 'Id',
                (Id) objSobject.get('Id')
              );
              objShareObject.put(objMtd.Object_Name__c + 'AccessLevel', 'Edit');
              objShareObject.put('UserOrGroupId', objUT.User__c);
              objShareObject.put('RowCause', objMtd.Row_Cause__c);
              lstOfShareRecord.add(objShareObject);
            } else if (
              objMtd.IsParentIdField__c &&
              (Id) objSobject.get('OwnerId') != objUT.User__c
            ) {
              objShareObject.put('ParentId', (Id) objSobject.get('Id'));
              objShareObject.put('AccessLevel', 'Edit');
              objShareObject.put('UserOrGroupId', objUT.User__c);
              objShareObject.put('RowCause', objMtd.Row_Cause__c);
              lstOfShareRecord.add(objShareObject);
            }
          }
        }
      }
    }
    if (!lstOfSobject.isEmpty()) {
      deleteShareRecords(lstOfSobject, objMtd);
    }

    if (!lstOfShareRecord.isEmpty()) {
      insertShareRecord(lstOfShareRecord, objMtd);
    }
  }

  /**
   * @description This method is used to create dynamic instance of object.
   * @name insertShareRecord
   * @param lstOfSobject list of sobject record to process
   * @param objMtd share object metadata record
   * @author Ashish Kumar
   * @US CC-4418
   */
  private static void insertShareRecord(
    List<Sobject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objMtd
  ) {
    String strFieldColumn = objMtd.IsParentIdField__c == true
      ? 'ParentId'
      : objMtd.Object_Name__c + 'Id';
    Set<Id> idsOfCreatedRecord = new Set<Id>();
    Database.SaveResult[] lstOfResults = Database.insert(lstOfSobject, false);
    List<WrapSharingError> lstOfSharingError = new List<WrapSharingError>();
    for (integer i = 0; i < lstOfResults.size(); i++) {
      if (!lstOfResults.get(i).isSuccess()) {
        Database.Error error = lstOfResults.get(i).getErrors().get(0);
        lstOfSharingError.add(
          new WrapSharingError(
            (String) lstOfSobject[i].get(strFieldColumn),
            (String) lstOfSobject[i].get('UserOrGroupId'),
            error.getMessage()
          )
        );
      }
    }

    if (!lstOfSharingError.isEmpty()) {
      Logger.error(
        'Error occured while creating ' +
        objMtd.Sharing_Object__c +
        ' record',
        processSharingException(lstOfSharingError)
      );
      Logger.saveLog();
    }
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
    Schema.SObjectType st = gd.get(strSobjectName);
    Sobject s = st.newSobject();
    return s;
  }

  /**
   * @description This method is used to delete share record dynamically.
   * @name deleteShareRecords
   * @param lstOfSobject list of new sobject records
   * @param objMtd share object metadata record
   * @author Ashish Kumar
   * @US CC-1894
   */
  private static void deleteShareRecords(
    List<Sobject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objMtd
  ) {
    String strWhereClause = objMtd.IsParentIdField__c == true
      ? 'ParentId'
      : objMtd.Object_Name__c + 'Id';
    String strRowCause = objMtd.Row_Cause__c;
    String strQuery =
      'SELECT Id,UserOrGroupId,' +
      strWhereClause +
      ' FROM ' +
      String.escapeSingleQuotes(objMtd.Sharing_Object__c) +
      ' WHERE ' +
      String.escapeSingleQuotes(strWhereClause) +
      ' IN: lstOfSobject and RowCause =: strRowCause';
    List<Sobject> lstOfSobjectShareToDelete = Database.query(strQuery);
    List<Sobject> lstOfSobjectToDelete = new List<Sobject>();
    if (!lstOfSobjectShareToDelete.isEmpty()) {
      Database.DeleteResult[] lstOfDeleteResults = Database.delete(
        lstOfSobjectShareToDelete,
        false
      );
      List<WrapSharingError> lstOfSharingError = new List<WrapSharingError>();
      for (integer i = 0; i < lstOfDeleteResults.size(); i++) {
        if (!lstOfDeleteResults.get(i).isSuccess()) {
          Database.Error error = lstOfDeleteResults.get(i).getErrors().get(0);
          lstOfSharingError.add(
            new WrapSharingError(
              (String) lstOfSobjectShareToDelete[i].get(strWhereClause),
              (String) lstOfSobjectShareToDelete[i].get('UserOrGroupId'),
              error.getMessage()
            )
          );
        }
      }

      if (!lstOfSharingError.isEmpty()) {
        Logger.error(
          'Error occured while deleting ' +
          objMtd.Sharing_Object__c +
          ' record',
          processSharingException(lstOfSharingError)
        );
        Logger.saveLog();
      }
    }
  }

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
  private static Territory_Base_Sharing_Event__e createSharingPE(
    List<sObject> lstOfSobject,
    String strSobjectName,
    Map<Id, sObject> oldMapSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    Set<Id> setOfEligibleRT = getEligibleRT(objTerritoryMtd);
    Territory_Base_Sharing_Event__e objTerritoryEvt = new Territory_Base_Sharing_Event__e(
      Trigger_Object__c = strSobjectName
    );
    for (sObject objSobject : lstOfSobject) {
      if (
        (!setOfEligibleRT.isEmpty() &&
        setOfEligibleRT.contains((Id) objSobject.get('RecordTypeId')) ||
        setOfEligibleRT.isEmpty()) &&
        !objTerritoryMtd.Excluded_Users__c.containsIgnoreCase(
          UserInfo.getUserName()
        ) &&
        (oldMapSobject == null ||
        (oldMapSobject != null &&
        (oldMapSobject.get((Id) objSobject.get('Id'))
          .get(objTerritoryMtd.Territory_Field__c) !=
        objSobject.get(objTerritoryMtd.Territory_Field__c) ||
        objSobject.get('OwnerId') !=
        oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId'))))
      ) {
        if (objTerritoryEvt.Record_Ids__c == null) {
          objTerritoryEvt.Record_Ids__c = (Id) objSobject.get('Id');
        } else {
          objTerritoryEvt.Record_Ids__c =
            objTerritoryEvt.Record_Ids__c +
            ';' +
            (Id) objSobject.get('Id');
        }
      }
    }
    return objTerritoryEvt;
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
  private static List<Sobject> reShareToOriginalOwner(
    List<sObject> lstOfSobject,
    String strSobjectName,
    Map<Id, sObject> oldMapSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    List<Sobject> lstOfLeadShareToInsert = new List<Sobject>();
    Set<Id> setOfEligibleRT = getEligibleRT(objTerritoryMtd);
    for (sObject objSobject : lstOfSobject) {
      if (strSobjectName == 'Lead' && objSobject.get('Status') == 'Expired') {
        continue;
      }
      if (
        (!setOfEligibleRT.isEmpty() &&
        setOfEligibleRT.contains((Id) objSobject.get('RecordTypeId')) ||
        setOfEligibleRT.isEmpty()) &&
        !objTerritoryMtd.Excluded_Users__c.containsIgnoreCase(
          UserInfo.getUserName()
        ) &&
        oldMapSobject != null &&
        objSobject.get('OwnerId') !=
        oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId')
      ) {
        Sobject objShareObject = getNewSObject(
          objTerritoryMtd.Sharing_Object__c
        );
        String strParentId = !strSobjectName.contains(
            MLCRMConstants.UNDERSCORE_C
          )
          ? strSobjectName + 'Id'
          : 'ParentId';
        String strAccessLevel = !strSobjectName.contains(
            MLCRMConstants.UNDERSCORE_C
          )
          ? strSobjectName + 'AccessLevel'
          : 'AccessLevel';
        objShareObject.put(strParentId, (Id) objSobject.get('Id'));
        objShareObject.put(strAccessLevel, 'Edit');
        objShareObject.put(
          'UserOrGroupId',
          oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId')
        );
        objShareObject.put('RowCause', objTerritoryMtd.Row_Cause__c);
        lstOfLeadShareToInsert.add(objShareObject);
      }
    }
    return lstOfLeadShareToInsert;
  }

  /**
   * @description This method returns list of eligible record types for Territory sharing
   * @name getEligibleRT
   * @param objTerritoryMtd Territory sharing custom metadata type object
   * @return List of eligible record type ids
   * @author Ashish Kumar
   */
  private static Set<Id> getEligibleRT(
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    return MLCRMCommonUtils.getRecordTypeIdsByDeveloperName(
      objTerritoryMtd.Object_Name__c,
      objTerritoryMtd.Eligible_Record_Types__c != null
        ? objTerritoryMtd.Eligible_Record_Types__c.split(';')
        : null
    );
  }

  /**
   * @description This method is return custom error message related to sharing record error
   * @name processSharingException
   * @param lstOfSharingError list of record on which error occurs
   * @return Exception exception object
   * @author Ashish Kumar
   * @US CC-4418
   */
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
  public class WrapSharingError {
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
}