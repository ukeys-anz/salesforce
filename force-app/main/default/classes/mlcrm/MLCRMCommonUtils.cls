/**
 * @author Ashish Kumar
 * @since  06/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMCommonUtils is class to handle common functionality related to territory management.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class MLCRMCommonUtils {
  private static Profile userProfile;
  private static Set<Id> userProfileSet;
  private static Map<String, Id> mapOfProfileId = null;
  private static String strFranchiseRole;
  private static Map<Id, User> mapOfUsers;
  private static Set<Id> idsOfOwnerId = new Set<Id>();

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
    for (sObject objSobject : lstOfSobject) {
      if (validateSobjectRecord(objSobject)) {
        getProfileId(lstOfSobject);
        if (
          mapOfProfileId != null &&
          userInfo.getProfileId() ==
          mapOfProfileId.get(MLCRMConstants.ADMIN_PROFILE_NAME)
        ) {
          continue;
        }
        // validate if territory remains blank for any record then add error.
        if (objSobject.get('Territory__c') == null) {
          objSobject.addError(LABEL.ML_ValidateTerritory);
        } else if (
          objSobject.get('Territory__c') != null &&
          (oldMapSobject == null ||
          (oldMapSobject != null &&
          objSobject.get('Territory__c') !=
          oldMapSobject.get((Id) objSobject.get('Id')).get('Territory__c'))) &&
          (mapOfProfileId != null &&
          userInfo.getProfileId() !=
          mapOfProfileId.get(MLCRMConstants.ML_PROFILE_NAME))
        ) {
          // validate if record's territory is changed and user is not ML profile then add error
          objSobject.addError(LABEL.ML_ValidateTerritoryChangeByNonMLUser);
        } else if (
          objSobject.get('OwnerId') != null &&
          (oldMapSobject == null ||
          (oldMapSobject != null &&
          objSobject.get('OwnerId') !=
          oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId'))) &&
          (mapOfProfileId != null &&
          userInfo.getProfileId() !=
          mapOfProfileId.get(MLCRMConstants.ML_PROFILE_NAME))
        ) {
          // validate if record's owner is changed and user is not ML profile then add error
          objSobject.addError(LABEL.ML_ValidateOwnerChangeByNonMLUser);
        } else if (
          hasTerrChgdAndCurrUserOnFranRole(objSobject, oldMapSobject)
        ) {
        } else if (
          hasTerrChgdAndCurrUserNotOnFranRole(objSobject, oldMapSobject)
        ) {
        } else if (
          objSobject.get('OwnerId') != null &&
          (oldMapSobject == null ||
          (oldMapSobject != null &&
          objSobject.get('OwnerId') !=
          oldMapSobject.get((Id) objSobject.get('Id')).get('OwnerId'))) &&
          (mapOfProfileId != null &&
          userInfo.getProfileId() ==
          mapOfProfileId.get(MLCRMConstants.ML_PROFILE_NAME)) &&
          (mapOfUsers != null &&
          mapOfUsers.get((Id) objSobject.get('OwnerId')).UserRoleId ==
          strFranchiseRole)
        ) {
          // validate if record's owner is changed and user is ML profile
          idsOfOwnerId.add((Id) objSobject.get('OwnerId'));
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
    List<User_Territory__c> lstOfLoggedInUserTerritory = [
      SELECT Territory__c, User__c
      FROM User_Territory__c
      WHERE
        User__c IN :idsOfOwnerId
        AND Status__c = :MLCRMConstants.STATUS_ACTIVE
    ];
    for (User_Territory__c objTerritory : lstOfLoggedInUserTerritory) {
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
        ((String.valueOf(objSobject.getSObjectType()) ==
        MLCRMConstants.SOBJECT_LEAD &&
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_LEAD_RT_ID) ||
        (String.valueOf(objSobject.getSObjectType()) ==
        MLCRMConstants.SOBJECT_OPPORTUNITY &&
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) ||
        (String.valueOf(objSobject.getSObjectType()) ==
        MLCRMConstants.SOBJECT_RELATIONSHIP_NOTES) ||
        (String.valueOf(objSobject.getSObjectType()) == 'Interaction' &&
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.ML_INTERACTION_RT_ID)) &&
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
    Set<Id> setOfRecordTypeIds = new Set<Id>();
    if (lstDevelopername != null && !lstDevelopername.isEmpty()) {
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

  /**
   * @description getProfileById get Profile by ProfileId
   * @param profileId Id of the Profile
   * @return Profile
   */
  public static Profile getProfileById(String profileId) {
    if (userProfile == null) {
      if (Schema.sObjectType.Profile.isQueryable()) {
        List<Profile> prof = [
          SELECT Id, Name
          FROM Profile
          WHERE Id = :profileId
        ];
        if (!prof.isEmpty()) {
          userProfile = prof[0];
        }
      }
    }
    return userProfile;
  }

  /**
   * @description getAllowedProfileIdsSet to query Profiles by set of Profile Names
   * @param profileNames set of name of the Profile
   * @param reset reset the profileId Set
   * @return Set<Id>
   */
  public static Set<Id> getAllowedProfileIdsSet(
    Set<String> profileNames,
    Boolean reset
  ) {
    if (userProfileSet == null || reset) {
      Set<Id> profIdSet = new Set<Id>();
      for (Profile prof : [
        SELECT Id
        FROM Profile
        WHERE Name IN :profileNames
      ]) {
        profIdSet.add(prof.Id);
      }
      return profIdSet;
    }
    return userProfileSet;
  }

  /**
   * @description This method is used share sobject record based on parent object sharing modal
   * @name parentObjectRecordSharing
   * @param lstOfSobject list of sobject records
   * @param objTerritoryMtd territory sharing metadata record
   * @author Ashish Kumar
   * @US CC-5207
   */
  public static void parentObjectRecordSharing(
    List<Sobject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    List<Sobject> lstOfTerrirotyShareRecord = new List<Sobject>();
    List<Sobject> lstOfFranchiseShareRecord = new List<Sobject>();
    Set<Id> setOfEligibleRT = MLCRMCommonUtils.getRecordTypeIdsByDeveloperName(
      objTerritoryMtd.Object_Name__c,
      objTerritoryMtd.Eligible_Record_Types__c != null
        ? objTerritoryMtd.Eligible_Record_Types__c.split(';')
        : null
    );
    Map<String, Territory_Based_Sharing_Config__mdt> mapOfTerritoryConfig = getTerritoryMetadata();
    for (Sobject objSobject : lstOfSobject) {
      if (objTerritoryMtd.Lookup_Fields__c != null) {
        for (String str : objTerritoryMtd.Lookup_Fields__c.split(';')) {
          if ((Id) objSobject.get(str) != null) {
            String objName = ((Id) objSobject.get(str))
              .getSObjectType()
              .getDescribe()
              .getName();
            if (
              mapOfTerritoryConfig.containsKey(objName) &&
              mapOfTerritoryConfig.get(objName).Sharing_Scope__c ==
              MLCRMConstants.STR_TERRITORY
            ) {
              lstOfTerrirotyShareRecord.add(objSobject);
            } else if (
              mapOfTerritoryConfig.containsKey(objName) &&
              mapOfTerritoryConfig.get(objName).Sharing_Scope__c ==
              MLCRMConstants.STR_FRANCHISE
            ) {
              lstOfFranchiseShareRecord.add(objSobject);
            }
            break;
          }
        }
      }
    }

    if (!lstOfTerrirotyShareRecord.isEmpty()) {
      MLCRMSharingUtil.createTerritoryShareRecords(
        lstOfTerrirotyShareRecord,
        objTerritoryMtd
      );
    }

    if (!lstOfFranchiseShareRecord.isEmpty()) {
      MLCRMSharingUtil.createShareRecordsFranchiseWise(
        lstOfFranchiseShareRecord,
        objTerritoryMtd
      );
    }
  }

  /**
   * @description This method to fetch the territory sharing metadata record
   * @name getTerritoryMetadata
   * @author Ashish Kumar
   * @return Map<String,Territory_Based_Sharing_Config__mdt>
   * @US CC-5207
   */
  private static Map<String, Territory_Based_Sharing_Config__mdt> getTerritoryMetadata() {
    List<Territory_Based_Sharing_Config__mdt> lstOfTerritoryMetadata = Territory_Based_Sharing_Config__mdt.getAll()
      .values();
    Map<String, Territory_Based_Sharing_Config__mdt> mapOfTerritoryConfig = new Map<String, Territory_Based_Sharing_Config__mdt>();
    if (!lstOfTerritoryMetadata.isEmpty()) {
      for (
        Territory_Based_Sharing_Config__mdt objMetadata : lstOfTerritoryMetadata
      ) {
        mapOfTerritoryConfig.put(objMetadata.Object_Name__c, objMetadata);
      }
    }
    return mapOfTerritoryConfig;
  }

  /**
   * @description This method to fetch the territory sharing metadata record
   * @name getProfileId
   * @param lstOfSobject each sobject record
   * @author Ashish Kumar
   * @US CC-1058
   */
  private static void getProfileId(List<sObject> lstOfSobject) {
    if (mapOfProfileId == null) {
      mapOfUsers = getRecordUserRole(lstOfSobject);
      mapOfProfileId = CommonUtil.getProfileByNames(
        new List<String>{
          MLCRMConstants.ML_PROFILE_NAME,
          MLCRMConstants.ADMIN_PROFILE_NAME
        }
      );
      strFranchiseRole = CommonUtil.getUserRoleByDevName(
          Label.ML_Franchise_Role
        )
        .Id;
    }
  }

  /**
   * @description This method to validate the sobject record
   * @name validateSobjectRecord
   * @param objSobject each sobject record
   * @return Boolean
   * @author Ashish Kumar
   * @US CC-1058
   */
  private static Boolean validateSobjectRecord(sObject objSobject) {
    if (
      ((String.valueOf(objSobject.getSObjectType()) ==
      MLCRMConstants.SOBJECT_LEAD &&
      (Id) objSobject.get('RecordTypeId') == MLCRMConstants.MLCRM_LEAD_RT_ID) ||
      (String.valueOf(objSobject.getSObjectType()) ==
      MLCRMConstants.SOBJECT_OPPORTUNITY &&
      (Id) objSobject.get('RecordTypeId') ==
      MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) ||
      (String.valueOf(objSobject.getSObjectType()) ==
      MLCRMConstants.SOBJECT_RELATIONSHIP_NOTES) ||
      (String.valueOf(objSobject.getSObjectType()) == 'Interaction' &&
      (Id) objSobject.get('RecordTypeId') ==
      MLCRMConstants.ML_INTERACTION_RT_ID)) &&
      !CCRMLeadUtil.isIntegrationUser() &&
      !CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description This method to get user role developername
   * @name getRecordUserRole
   * @param lstOfSobject each sobject record
   * @return Map<Id,User>
   * @author Ashish Kumar
   * @US CC-1058
   */
  private static Map<Id, User> getRecordUserRole(List<sObject> lstOfSobject) {
    Set<Id> idsOfOwner = new Set<Id>();
    for (Sobject objSobject : lstOfSobject) {
      idsOfOwner.add((Id) objSobject.get('OwnerId'));
    }

    if (!idsOfOwner.isEmpty()) {
      Map<Id, User> mapOfUsers = new Map<Id, User>(
        [SELECT Id, UserRoleId FROM User WHERE ID IN :idsOfOwner]
      );
      return mapOfUsers;
    }
    return null;
  }

  /**
   * @description This method to validate the sobject record
   * @name validateTerritoryChange
   * @param objSobject each sobject record
   * @param oldMapSobject old sobject record
   * @return Boolean
   * @author Ashish Kumar
   * @US CC-1058
   */
  private static Boolean hasTerrChgdAndCurrUserOnFranRole(
    sObject objSobject,
    Map<Id, sObject> oldMapSobject
  ) {
    if (
      objSobject.get('Territory__c') != null &&
      (oldMapSobject == null ||
      (oldMapSobject != null &&
      objSobject.get('Territory__c') !=
      oldMapSobject.get((Id) objSobject.get('Id')).get('Territory__c'))) &&
      (mapOfProfileId != null &&
      userInfo.getProfileId() ==
      mapOfProfileId.get(MLCRMConstants.ML_PROFILE_NAME)) &&
      (mapOfUsers != null &&
      mapOfUsers.get((Id) objSobject.get('OwnerId')).UserRoleId ==
      strFranchiseRole) &&
      UserInfo.getUserRoleId() == strFranchiseRole
    ) {
      // validate if record's territory is changed and user is ML profile and having franchise role
      idsOfOwnerId.add((Id) objSobject.get('OwnerId'));
      idsOfOwnerId.add(UserInfo.getUserId());
      return true;
    }
    return false;
  }

  /**
   * @description This method to validate the sobject record
   * @name hasTerrChgdAndCurrUserNotOnFranRole
   * @param objSobject each sobject record
   * @param oldMapSobject old sobject record
   * @return Boolean
   * @author Ashish Kumar
   * @US CC-1058
   */
  private static Boolean hasTerrChgdAndCurrUserNotOnFranRole(
    sObject objSobject,
    Map<Id, sObject> oldMapSobject
  ) {
    if (
      objSobject.get('Territory__c') != null &&
      (oldMapSobject == null ||
      (oldMapSobject != null &&
      objSobject.get('Territory__c') !=
      oldMapSobject.get((Id) objSobject.get('Id')).get('Territory__c'))) &&
      (mapOfProfileId != null &&
      userInfo.getProfileId() ==
      mapOfProfileId.get(MLCRMConstants.ML_PROFILE_NAME)) &&
      (mapOfUsers != null &&
      mapOfUsers.get((Id) objSobject.get('OwnerId')).UserRoleId ==
      strFranchiseRole)
    ) {
      // validate if record's territory is changed and record owner is having franchise role
      idsOfOwnerId.add((Id) objSobject.get('OwnerId'));
      return true;
    }
    return false;
  }

  /**
   * @description This method prefill Referrer when Referrer Email is populated or changed
   * @name referrerPrefill
   * @param records List of sObject records
   * @param oldMap Map of old sObject records
   * author Ankit Garg
   * @US CC-1882
   */
  public static void referrerPrefill(
    List<sObject> records,
    Map<Id, sObject> oldMap
  ) {
    Set<Id> internalReferrerIds = new Set<Id>();
    Set<Id> externalReferrerIds = new Set<Id>();
    List<sObject> referrerEmailSobject = new List<sObject>();
    List<sObject> referrerSobject = new List<sObject>();
    Set<String> internalReferrerEmails = new Set<String>();
    Set<String> externalReferrerEmails = new Set<String>();

    //filter all the ML leads for which Internal Referral or Referrer Email is changed
    for (sObject objSobject : records) {
      if (
        ((Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_LEAD_RT_ID ||
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) &&
        String.isNotBlank(
          (String) objSobject.get('FinServ__ReferredByUser__c')
        ) &&
        (oldMap == null ||
        (String) objSobject.get('FinServ__ReferredByUser__c') !=
        oldMap.get((Id) objSobject.get('Id')).get('FinServ__ReferredByUser__c'))
      ) {
        internalReferrerIds.add(
          (Id) objSobject.get('FinServ__ReferredByUser__c')
        );
        referrerSobject.add(objSobject);
      } else if (
        ((Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_LEAD_RT_ID ||
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) &&
        String.isNotBlank(
          (String) objSobject.get('FinServ__ReferredByContact__c')
        ) &&
        (oldMap == null ||
        (String) objSobject.get('FinServ__ReferredByContact__c') !=
        oldMap.get((Id) objSobject.get('Id'))
          .get('FinServ__ReferredByContact__c'))
      ) {
        externalReferrerIds.add(
          (Id) objSobject.get('FinServ__ReferredByContact__c')
        );
        referrerSobject.add(objSobject);
      } else if (
        ((Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_LEAD_RT_ID ||
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) &&
        String.isNotBlank((String) objSobject.get('Referrer_Email__c')) &&
        ((String) objSobject.get('LeadSource'))
          .equals(MLCRMConstants.INTERNAL_REFERRAL) &&
        (oldMap == null ||
        (String) objSobject.get('Referrer_Email__c') !=
        oldMap.get((Id) objSobject.get('Id')).get('Referrer_Email__c'))
      ) {
        internalReferrerEmails.add(
          (String) objSobject.get('Referrer_Email__c')
        );
        referrerEmailSobject.add(objSobject);
      } else if (
        ((Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_LEAD_RT_ID ||
        (Id) objSobject.get('RecordTypeId') ==
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID) &&
        String.isNotBlank((String) objSobject.get('Referrer_Email__c')) &&
        ((String) objSobject.get('LeadSource'))
          .equals(MLCRMConstants.EXTERNAL_REFERRAL) &&
        (oldMap == null ||
        (String) objSobject.get('Referrer_Email__c') !=
        oldMap.get((Id) objSobject.get('Id')).get('Referrer_Email__c'))
      ) {
        externalReferrerEmails.add(
          (String) objSobject.get('Referrer_Email__c')
        );
        referrerEmailSobject.add(objSobject);
      }
    }

    mapReferrerByEmail(
      internalReferrerEmails,
      externalReferrerEmails,
      referrerEmailSobject
    );
    mapReferrerByLookupId(
      internalReferrerIds,
      externalReferrerIds,
      referrerSobject
    );
  }

  /**
   * @description This method to map reffere by email
   * @name mapReferrerByEmail
   * @param internalReferrerEmails Set of internal Email
   * @param externalReferrerEmails Set of external Email
   * @param referrerEmailSobject list of sobject
   * @author Ankit Garg
   * @US CC-1882
   */
  private static void mapReferrerByEmail(
    Set<String> internalReferrerEmails,
    Set<String> externalReferrerEmails,
    List<sObject> referrerEmailSobject
  ) {
    Map<String, sObject> userEmailMap = new Map<String, sObject>();
    if (
      !internalReferrerEmails.isEmpty() && Schema.sObjectType.User.isQueryable()
    ) {
      userEmailMap = getReferrerUsers(internalReferrerEmails, 'User');
      populateReferrer(
        referrerEmailSobject,
        userEmailMap,
        'FinServ__ReferredByUser__c'
      );
    } else if (
      !externalReferrerEmails.isEmpty() &&
      Schema.sObjectType.Contact.isQueryable()
    ) {
      userEmailMap = getReferrerUsers(externalReferrerEmails, 'Contact');
      populateReferrer(
        referrerEmailSobject,
        userEmailMap,
        'FinServ__ReferredByContact__c'
      );
    }
  }

  /**
   * @description This method to map reffere by lookup Id
   * @name mapReferrerByLookupId
   * @param internalReferrerIds Set of internal Id
   * @param externalReferrerIds Set of external Id
   * @param referrerSobject list of sobject
   * @author Ankit Garg
   * @US CC-1882
   */
  private static void mapReferrerByLookupId(
    Set<Id> internalReferrerIds,
    Set<Id> externalReferrerIds,
    List<sObject> referrerSobject
  ) {
    Map<Id, sObject> userMap = new Map<Id, sObject>();
    if (
      !internalReferrerIds.isEmpty() && Schema.sObjectType.User.isQueryable()
    ) {
      userMap = getReferrerUsers(internalReferrerIds, 'User');
      populateReferrerDetails(
        referrerSobject,
        userMap,
        'FinServ__ReferredByUser__c'
      );
    } else if (
      !externalReferrerIds.isEmpty() && Schema.sObjectType.Contact.isQueryable()
    ) {
      userMap = getReferrerUsers(externalReferrerIds, 'Contact');
      populateReferrerDetails(
        referrerSobject,
        userMap,
        'FinServ__ReferredByContact__c'
      );
    }
  }

  /**
   * @description This method to query users matching with Referrer Emails
   * @name getReferrerUsers
   * @param referrerEmails Set of Email Ids
   * @param strObject sobject API Name
   * @return userEmailMap Map<String,User>()
   * @author Ankit Garg
   * @US CC-1882
   */
  private static Map<String, sObject> getReferrerUsers(
    Set<String> referrerEmails,
    String strObject
  ) {
    Map<String, sObject> userEmailMap = new Map<String, sObject>();
    String strPhoneColumn = '';
    if (strObject == 'Contact') {
      strPhoneColumn = ' ,MobilePhone';
    }
    String strQuery =
      'SELECT Id, Name, Email ' +
      strPhoneColumn +
      ' FROM ' +
      strObject +
      ' WHERE Email = :referrerEmails';
    if (strObject == 'User') {
      strQuery += ' AND isActive = TRUE';
    }

    //query users matching with Referrer Emails
    if (
      (strObject == 'User' && Schema.sObjectType.User.isQueryable()) ||
      (strObject == 'Contact' && Schema.sObjectType.Contact.isQueryable())
    ) {
      for (Sobject rUser : Database.query(strQuery)) {
        if (!userEmailMap.containsKey((String) rUser.get('Email'))) {
          userEmailMap.put((String) rUser.get('Email'), rUser);
        }
      }
    }
    return userEmailMap;
  }

  /**
   * @description This method to query users matching with Referrer Emails
   * @name getReferrerUsers
   * @param referrerIds Set of User Ids
   * @param strObject sobject API Name
   * @return userMap Map<Id,User>()
   * @author Ankit Garg
   * @US CC-1882
   */
  private static Map<Id, sObject> getReferrerUsers(
    Set<Id> referrerIds,
    String strObject
  ) {
    //query users matching with Internal Referrer Ids
    String strPhoneColumn = '';
    if (strObject == 'Contact') {
      strPhoneColumn = ' ,MobilePhone';
    }
    String strQuery =
      'SELECT Id, Name, Email ' +
      strPhoneColumn +
      ' FROM ' +
      strObject +
      ' WHERE Id = :referrerIds';
    if (strObject == 'User') {
      strQuery += ' AND isActive = TRUE';
    }

    strQuery += ' LIMIT 10000';
    Map<Id, sObject> userMap = new Map<Id, sObject>(Database.query(strQuery));
    return userMap;
  }

  /**
   * @description This method to populate Referrer Email and Referrer Name
   * @name populateReferrerDetails
   * @param referrerSobject List of sObject records
   * @param userMap Map of users
   * @param strField field API Name
   * @author Ankit Garg
   * @US CC-1882
   */
  private static void populateReferrerDetails(
    List<sObject> referrerSobject,
    Map<Id, sObject> userMap,
    String strField
  ) {
    for (sObject objSobject : referrerSobject) {
      if (
        (String) objSobject.get(strField) != null &&
        !userMap.isEmpty() &&
        userMap.containsKey((String) objSobject.get(strField))
      ) {
        objSobject.put(
          'Referrer_Email__c',
          userMap.get((String) objSobject.get(strField)).get('Email')
        );
        objSobject.put(
          'Referrer_Name__c',
          userMap.get((String) objSobject.get(strField)).get('Name')
        );
        if (strField == 'FinServ__ReferredByContact__c') {
          objSobject.put(
            'Referrer_Phone__c',
            userMap.get((String) objSobject.get(strField)).get('MobilePhone')
          );
        }
      }
    }
  }
  /**
   * @description This method to populate Internal Referrer and Referrer Name
   * @name populateReferrer
   * @param referrerSobject List of sObject records
   * @param userEmailMap Map of email with users
   * @param strField field API Name
   * @author Ankit Garg
   * @US CC-1882
   */
  private static void populateReferrer(
    List<sObject> referrerSobject,
    Map<String, sObject> userEmailMap,
    String strField
  ) {
    for (sObject objSobject : referrerSobject) {
      if (
        (String) objSobject.get('Referrer_Email__c') != null &&
        !userEmailMap.isEmpty() &&
        userEmailMap.containsKey((String) objSobject.get('Referrer_Email__c'))
      ) {
        objSobject.put(
          strField,
          userEmailMap.get((String) objSobject.get('Referrer_Email__c'))
            .get('Id')
        );
        objSobject.put(
          'Referrer_Name__c',
          userEmailMap.get((String) objSobject.get('Referrer_Email__c'))
            .get('Name')
        );
        if (strField == 'FinServ__ReferredByContact__c') {
          objSobject.put(
            'Referrer_Phone__c',
            userEmailMap.get((String) objSobject.get(strField))
              .get('MobilePhone')
          );
        }
      } else {
        objSobject.put(strField, null);
      }
    }
  }
}
