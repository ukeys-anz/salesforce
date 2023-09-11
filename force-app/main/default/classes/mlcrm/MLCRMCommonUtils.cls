/**
 * @author Ashish Kumar
 * @since  06/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMCommonUtils is class to handle common functionality related to territory management.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class MLCRMCommonUtils {
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
    Set<Id> idsOfOwnerId = new Set<Id>();
    String strMLProfileId = CommonUtil.getProfileByName(
        MLCRMConstants.ML_PROFILE_NAME
      )
      .Id;
    String strAdminProfileId = CommonUtil.getProfileByName(
        MLCRMConstants.ADMIN_PROFILE_NAME
      )
      .Id;
    String strFranchiseRole = CommonUtil.getUserRoleByDevName(
        Label.ML_Franchise_Role
      )
      .Id;

    for (sObject objSobject : lstOfSobject) {
      if (
        ((Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_LEAD_RT_ID ||
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) &&
        !CCRMLeadUtil.isIntegrationUser() &&
        userInfo.getProfileId() != strAdminProfileId &&
        !CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES
      ) {
        // validate if territory remains blank for any record then add error.
        if (objSobject.get('Territory__c') == null) {
          objSobject.addError(LABEL.ML_ValidateTerritory);
        } else if (
          objSobject.get('Territory__c') != null &&
          (oldMapSobject == null ||
          (oldMapSobject != null &&
          objSobject.get('Territory__c') !=
          oldMapSobject.get((Id) objSobject.get('Id')).get('Territory__c'))) &&
          userInfo.getProfileId() == strMLProfileId &&
          UserInfo.getUserRoleId() == strFranchiseRole
        ) {
          // validate if record's territory is changed and user is ML profile and having franchise role
          idsOfOwnerId.add((Id) objSobject.get('OwnerId'));
          idsOfOwnerId.add(UserInfo.getUserId());
        } else if (
          objSobject.get('Territory__c') != null &&
          (oldMapSobject == null ||
          (oldMapSobject != null &&
          objSobject.get('Territory__c') !=
          oldMapSobject.get((Id) objSobject.get('Id')).get('Territory__c'))) &&
          userInfo.getProfileId() != strMLProfileId
        ) {
          // validate if record's territory is changed and user is not ML profile then add error
          objSobject.addError(LABEL.ML_ValidateTerritoryChangeByNonMLUser);
        } else if (
          objSobject.get('OwnerId') != null &&
          (oldMapSobject == null ||
          (oldMapSobject != null &&
          objSobject.get('OwnerId') !=
          oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId'))) &&
          userInfo.getProfileId() == strMLProfileId
        ) {
          // validate if record's owner is changed and user is ML profile
          idsOfOwnerId.add((Id) objSobject.get('OwnerId'));
        } else if (
          objSobject.get('OwnerId') != null &&
          (oldMapSobject == null ||
          (oldMapSobject != null &&
          objSobject.get('OwnerId') !=
          oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId'))) &&
          userInfo.getProfileId() != strMLProfileId
        ) {
          // validate if record's owner is changed and user is not ML profile then add error
          objSobject.addError(LABEL.ML_ValidateOwnerChangeByNonMLUser);
        }
      }
    }

    if (!idsOfOwnerId.isEmpty()) {
      validateUserTerritoryAssignments(
        idsOfOwnerId,
        lstOfSobject,
        oldMapSobject
      );
    }
  }

  /**
   * @description This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
   * @name validateTerritoryAndOwnerChange
   * @param idsOfOwnerId ids of lead owner which is changed
   * @param lstOfSobject new list of sobject
   * @param oldMapSobject old map of sobject
   * @author Ashish Kumar
   * @US CC-1058
   */
  private static void validateUserTerritoryAssignments(
    Set<Id> idsOfOwnerId,
    List<sObject> lstOfSobject,
    Map<Id, sObject> oldMapSobject
  ) {
    Set<String> setOfUserToTerritory = new Set<String>();
    for (User_Territory__c objTerritory : [
      SELECT Territory__c, User__c
      FROM User_Territory__c
      WHERE
        User__c IN :idsOfOwnerId
        AND Status__c = :MLCRMConstants.STATUS_ACTIVE
    ]) {
      setOfUserToTerritory.add(
        String.valueOf(objTerritory.User__c) +
        String.valueOf(objTerritory.Territory__c)
      );
    }
    for (sObject objSobject : lstOfSobject) {
      String strTerritoryUserMapping =
        (String) objSobject.get('OwnerId') +
        (String) objSobject.get('Territory__c');

      if (
        objSobject.get('Territory__c') != null &&
        (oldMapSobject == null ||
        (oldMapSobject != null &&
        objSobject.get('Territory__c') !=
        oldMapSobject.get((Id) objSobject.get('Id')).get('Territory__c'))) &&
        (!setOfUserToTerritory.contains(strTerritoryUserMapping) ||
        !setOfUserToTerritory.contains(
          UserInfo.getUserId() + objSobject.get('Territory__c')
        ))
      ) {
        objSobject.addError(LABEL.ML_ValidateTerritoryAssignment);
      } else if (
        objSobject.get('OwnerId') != null &&
        (oldMapSobject == null ||
        (oldMapSobject != null &&
        objSobject.get('OwnerId') !=
        oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId'))) &&
        !setOfUserToTerritory.contains(strTerritoryUserMapping)
      ) {
        objSobject.addError(LABEL.ML_ValidateOwnerAssigment);
      }
    }
  }

  /**
   * @description This method to set the territory for ML Lead
   * @name assignTerritoryForMLRecord
   * @param lstOfSobject List of sObject records
   * @author Ashish Kumar
   * @US CC-1054
   */
  public static void assignTerritoryForMLRecord(List<sObject> lstOfSobject) {
    Set<Id> idsofLeadOwner = new Set<Id>();
    for (sObject objSobject : lstOfSobject) {
      if (
        ((Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_LEAD_RT_ID ||
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) &&
        objSobject.get('Territory__c') == null
      ) {
        idsofLeadOwner.add((Id) objSobject.get('OwnerId'));
      }
    }
    if (!idsofLeadOwner.isEmpty()) {
      Map<Id, User_Territory__c> mapOfUserToTerritory;
      //getting list of user territory where user is sObject owner
      List<User_Territory__c> lstOfUserTerritory = [
        SELECT Territory__c, User__c, Territory__r.Primary_Franchise_Owner__c
        FROM User_Territory__c
        WHERE
          User__c IN :idsofLeadOwner
          AND Status__c = :MLCRMConstants.STATUS_ACTIVE
        ORDER BY Territory__r.Name
      ];
      if (!lstOfUserTerritory.isEmpty()) {
        mapOfUserToTerritory = new Map<Id, User_Territory__c>();
        for (User_Territory__c objUserTerritory : lstOfUserTerritory) {
          if (!mapOfUserToTerritory.containsKey(objUserTerritory.User__c)) {
            // Preparing mapping of user to its first territory ordered by territory name
            mapOfUserToTerritory.put(
              objUserTerritory.User__c,
              objUserTerritory
            );
          }
        }
      }

      for (sObject objSobject : lstOfSobject) {
        if (
          mapOfUserToTerritory != null &&
          mapOfUserToTerritory.containsKey((Id) objSobject.get('OwnerId'))
        ) {
          //populating territory on sObject record
          objSobject.put(
            'Territory__c',
            mapOfUserToTerritory.get((Id) objSobject.get('OwnerId'))
              .Territory__c
          );
          //CC-1550 to populate primary franchise owner to be used for duplicate lead match criteria
          if ((objSobject.getSObjectType().getDescribe().getName()) == 'Lead') {
            objSobject.put(
              'Primary_Franchise_Owner__c',
              mapOfUserToTerritory.get((Id) objSobject.get('OwnerId'))
                .Territory__r.Primary_Franchise_Owner__c
            );
          }
        }
      }
    }
  }

  /**
   * @description This method is used to get record type API name of any object dynamically
   * @name getTaskRecordTypeIdByDeveloperName
   * @param strObjectName sobject name
   * @param lstDevelopername List of developername API Name
   * @return Set<Id> Set of developername API Name
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static Set<Id> getTaskRecordTypeIdByDeveloperName(
    String strObjectName,
    List<String> lstDevelopername
  ) {
    Set<Id> setOfRecordTypeIds = new Set<Id>();
    if (!lstDevelopername.isEmpty()) {
      Map<String, Schema.SObjectType> mapOfSchema = Schema.getGlobalDescribe();
      Schema.SObjectType objSchema = mapOfSchema.get(strObjectName);
      Schema.DescribeSObjectResult cfrSchema = objSchema.getDescribe();
      Map<String, Schema.RecordTypeInfo> recordTypeInfo = cfrSchema.getRecordTypeInfosByDeveloperName();
      for (String eachStr : lstDevelopername) {
        setOfRecordTypeIds.add(recordTypeInfo.get(eachStr).getRecordTypeId());
      }
    }
    return setOfRecordTypeIds;
  }

  /**
   * @description This method is used to get record type API name of any object dynamically
   * @name getUserIdFromUsername
   * @param lstOfuserName list of username
   * @return Set<Id> Set of users
   * @author Ashish Kumar
   * @US CC-4493
   */
  public static Set<Id> getUserIdFromUsername(List<String> lstOfuserName) {
    Set<Id> setOfRecordTypeIds = new Set<Id>();
    if (!lstOfuserName.isEmpty()) {
      Map<Id, User> mapOfUsers = new Map<Id, User>(
        [SELECT Id FROM User WHERE userName IN :lstOfuserName]
      );
      return mapOfUsers.keySet();
    }
    return null;
  }
}
