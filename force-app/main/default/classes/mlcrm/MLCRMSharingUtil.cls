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
    if (objTerritoryMtd != null) {
      Set<Id> setOfEligibleRT = MLCRMCommonUtils.getTaskRecordTypeIdByDeveloperName(
        objTerritoryMtd.Object_Name__c,
        objTerritoryMtd.Eligible_Record_Types__c.split(';')
      );
      String strLoggedInUserEmail = UserInfo.getUserEmail();
      Territory_Base_Sharing_Event__e objTerritoryEvt = new Territory_Base_Sharing_Event__e();
      List<Sobject> lstOfLeadShareToInsert = new List<Sobject>();
      objTerritoryEvt.Trigger_Object__c = strSobjectName;
      for (sObject objSobject : lstOfSobject) {
        if (
          setOfEligibleRT.contains((Id) objSobject.get('RecordTypeId')) &&
          !objTerritoryMtd.Excluded_Users__c.containsIgnoreCase(
            strLoggedInUserEmail
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

        if (
          setOfEligibleRT.contains((Id) objSobject.get('RecordTypeId')) &&
          !objTerritoryMtd.Excluded_Users__c.containsIgnoreCase(
            strLoggedInUserEmail
          ) &&
          oldMapSobject != null &&
          objSobject.get('OwnerId') !=
          oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId')
        ) {
          Sobject objShareObject = getNewSObject(
            objTerritoryMtd.Sharing_Object__c
          );
          if (!strSobjectName.contains(MLCRMConstants.UNDERSCORE_C)) {
            objShareObject.put(
              strSobjectName + 'Id',
              (Id) objSobject.get('Id')
            );
            objShareObject.put(strSobjectName + 'AccessLevel', 'Edit');
            objShareObject.put(
              'UserOrGroupId',
              oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId')
            );
          } else if (strSobjectName.contains(MLCRMConstants.UNDERSCORE_C)) {
            objShareObject.put('ParentId', (Id) objSobject.get('Id'));
            objShareObject.put('AccessLevel', 'Edit');
            objShareObject.put(
              'UserOrGroupId',
              oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId')
            );
          }
          lstOfLeadShareToInsert.add(objShareObject);
        }
      }

      if (!lstOfLeadShareToInsert.isEmpty()) {
        //inserting the share records for original record owner in order of owner change to avoid temporary record lose access on UI.
        insert lstOfLeadShareToInsert;
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
    } else {
      Logger.error('Territory sharing config metadata record not found.');
      Logger.saveLog();
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
   * @param strShareObject share object name
   * @param strObject sobject name
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static void createTerritoryShareRecords(
    List<sObject> lstOfSobject,
    String strShareObject,
    String strObject
  ) {
    Map<Id, List<User_Territory__c>> mapOfTerritoryToUsers = new Map<Id, List<User_Territory__c>>();
    Map<Id, Id> mapOfRecordToOwnerId = new Map<Id, Id>();
    Set<Id> idsOfTerritory = new Set<Id>();
    Map<String,String> mapOfUserToRole = new Map<String,String>();
    if (!lstOfSobject.isEmpty()) {
      for (sObject objSobject : lstOfSobject) {
        idsOfTerritory.add((Id) objSobject.get('Territory__c'));
        mapOfRecordToOwnerId.put(
          (Id) objSobject.get('Id'),
          (Id) objSobject.get('OwnerId')
        );
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
        Sobject objShareObject = getNewSObject(strShareObject);
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
          !strObject.contains(MLCRMConstants.UNDERSCORE_C) &&
          (Id) objSobject.get('OwnerId') != objUT.User__c
        ) {
          objShareObject.put(strObject + 'Id', (Id) objSobject.get('Id'));
          objShareObject.put(strObject + 'AccessLevel', 'Edit');
          objShareObject.put('UserOrGroupId', objUT.User__c);
          lstOfLeadShare.add(objShareObject);
        } 
        // Condition to handle sharing of record for custom share object. Logic to make sure Loan writer are not able to see FO, FM and 
        // Admin records. However FO, FM and Admin are able to see LW's records. LWs can see other LWs' records in unrestricted territories. 
        // In restricted territories, no records are shared with LWs. 
        else if (
          mapOfUserToRole.containsKey(strUserRoleKey) &&
          ((mapOfUserToRole.get(strUserRoleKey) != MLCRMConstants.LOAN_WRITER &&
          objUT.ML_Role__c != MLCRMConstants.LOAN_WRITER) ||
          (mapOfUserToRole.get(strUserRoleKey) == MLCRMConstants.LOAN_WRITER &&
          ((objUT.ML_Role__c == MLCRMConstants.LOAN_WRITER &&
          objUT.Territory__r.Access_Scope__c ==
          MLCRMConstants.STRING_UNRESTRICTED) ||
          objUT.ML_Role__c != MLCRMConstants.LOAN_WRITER))) &&
          strObject.contains(MLCRMConstants.UNDERSCORE_C) &&
          (Id) objSobject.get('OwnerId') != objUT.User__c
        ) {
          objShareObject.put('ParentId', (Id) objSobject.get('Id'));
          objShareObject.put('AccessLevel', 'Edit');
          objShareObject.put('UserOrGroupId', objUT.User__c);
          lstOfLeadShare.add(objShareObject);
        }
      }
    }
    if (!lstOfSobject.isEmpty()) {
      deleteShareRecords(
        lstOfSobject,
        strShareObject,
        strObject,
        mapOfRecordToOwnerId
      );
    }

    if (!lstOfLeadShare.isEmpty()) {
      insertShareRecord(lstOfLeadShare,strShareObject,strObject);
    }
  }

  /**
   * @description This method is used to create dynamic instance of object.
   * @name insertShareRecord
   * @param lstOfSobject list of sobject record to process
   * @param strShareObject share sobject API name
   * @param strObject sobject API name
   * @author Ashish Kumar
   * @US CC-4418
   */
  private static void insertShareRecord(List<Sobject> lstOfSobject,String strShareObject,String strObject) {
    String strFieldColumn = strObject.contains(MLCRMConstants.UNDERSCORE_SHARE)
      ? 'ParentId'
      : strObject + 'Id';
    Set<Id> idsOfCreatedRecord = new Set<Id>();
      Database.SaveResult[] lstOfResults = Database.insert(
        lstOfSobject,
        false
      );
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
              'Error occured while creating ' + strShareObject + ' record',
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
   * @param strShareObject share object API name
   * @param strObject sobject name
   * @param mapOfRecordToOwnerId map of record id of userid to exclude from deleting share records
   * @author Ashish Kumar
   * @US CC-1894
   */
  private static void deleteShareRecords(
    List<Sobject> lstOfSobject,
    String strShareObject,
    String strObject,
    Map<Id, Id> mapOfRecordToOwnerId
  ) {
    String strWhereClause = strObject.contains(MLCRMConstants.UNDERSCORE_SHARE)
      ? 'ParentId'
      : strObject + 'Id';
    String strQuery =
      'SELECT Id,UserOrGroupId,' +
      strWhereClause +
      ' FROM ' +
      String.escapeSingleQuotes(strShareObject) +
      ' WHERE ' +
      String.escapeSingleQuotes(strWhereClause) +
      ' IN: lstOfSobject';
    List<Sobject> lstOfSobjectShareToDelete = Database.query(strQuery);
    List<Sobject> lstOfSobjectToDelete = new List<Sobject>();
    if (!lstOfSobjectShareToDelete.isEmpty()) {
      for (Sobject obj : lstOfSobjectShareToDelete) {
        if (
          mapOfRecordToOwnerId.containskey((String) obj.get(strWhereClause)) &&
          mapOfRecordToOwnerId.get((String) obj.get(strWhereClause)) !=
          (Id) obj.get('UserOrGroupId')
        ) {
          lstOfSobjectToDelete.add(obj);
        }
      }
      Set<Id> idsOfDeletedRecord = new Set<Id>();
      Database.DeleteResult[] lstOfDeleteResults = Database.delete(
        lstOfSobjectToDelete,
        false
      );
      List<WrapSharingError> lstOfSharingError = new List<WrapSharingError>();
      for (integer i = 0; i < lstOfDeleteResults.size(); i++) {
        if (!lstOfDeleteResults.get(i).isSuccess()) {
          Database.Error error = lstOfDeleteResults.get(i).getErrors().get(0);
          lstOfSharingError.add(
            new WrapSharingError(
              (String) lstOfSobject[i].get(strWhereClause),
              (String) lstOfSobject[i].get('UserOrGroupId'),
              error.getMessage()
            )
          );
        }
      }
      
      if (!lstOfSharingError.isEmpty()) {
          Logger.error(
              'Error occured while deleting ' + strShareObject + ' record',
              processSharingException(lstOfSharingError)
          );
          Logger.saveLog();
      }
    }
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
    public WrapSharingError(
      String recordId,
      String userId,
      String errMsg
    ) {
      this.recordId = recordId;
      this.userId = userId;
      this.errMsg = errMsg;
    }
  }
}
