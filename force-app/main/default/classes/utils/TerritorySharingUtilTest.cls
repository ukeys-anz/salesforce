/**
 * @author Ashish Kumar
 * @since 05/2024
 * @description  To test TerritorySharingUtil
 */
@isTest
public class TerritorySharingUtilTest {
  static Lib_MockProvider dmlMockProvider;
  static Lib_MockProvider userTerritoryMockProvider;
  static Lib_MockProvider territoryMockProvider;
  static void registerMocks() {
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
    userTerritoryMockProvider = Lib_MockProvider.forType(
      UserTerritoryActionsRepository.class
    );
    territoryMockProvider = Lib_MockProvider.forType(
      TerritoryActionsRepository.class
    );
  }
  /**
   * @description test method for shareRecordByTerritory
   */
  @isTest
  static void testShareRecordByTerritory() {
    registerMocks();
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Map<Id, Lead> mapOfOld = new Map<Id, Lead>{
      idLead => new Lead(
        Id = idLead,
        OwnerId = idOwner,
        Territory__c = idTerritory,
        RecordTypeId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead'),
        RecordType = new RecordType(DeveloperName = 'MLCRM_Lead')
      )
    };
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(
        Id = idLead,
        OwnerId = idOwner2,
        Territory__c = idTerritory,
        RecordTypeId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead'),
        RecordType = new RecordType(DeveloperName = 'MLCRM_Lead')
      )
    };
    territoryMockProvider.mock(
      'getTerritorySharingMetadata',
      new List<Territory_Based_Sharing_Config__mdt>{
        new Territory_Based_Sharing_Config__mdt(
          Active__c = true,
          Row_Cause__c = 'Manual',
          Sharing_Scope__c = 'Territory',
          Sharing_Object__c = 'LeadShare',
          Object_Name__c = 'Lead',
          Eligible_Record_Types__c = 'MLCRM_Lead',
          Territory_Field__c = 'Territory__c'
        )
      }
    );
    Test.startTest();
    TerritorySharingUtil.shareRecordByTerritory(mapOfOld, lstOfSobject, 'Lead');
    Test.stopTest();
    List<LeadShare> shareRecord = (List<LeadShare>) dmlMockProvider.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      idOwner,
      shareRecord[0].UserOrGroupId,
      'Record not shared with original owner'
    );
    Assert.isNotNull(
      dmlMockProvider.getHistory('doPublish'),
      'Territory Share Event is not published'
    );
  }

  /**
   * @description test method for createShareRecordsByTerritory
   */
  @isTest
  static void testCreateShareRecordsByTerritory() {
    registerMocks();
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(Id = idLead, OwnerId = idOwner, Territory__c = idTerritory)
    };
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Territory',
      Sharing_Object__c = 'LeadShare',
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead'
    );
    userTerritoryMockProvider.mock(
      'getUserTerritories',
      new List<User_Territory__c>{
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        ),
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner2,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        )
      }
    );
    territoryMockProvider.mock(
      'getShareRecords',
      new List<LeadShare>{
        new LeadShare(
          Id = Lib_FakeIdGenerator.getMockId(LeadShare.SObjectType),
          UserOrGroupId = idOwner,
          LeadId = idLead
        )
      }
    );
    Test.startTest();
    TerritorySharingUtil.createShareRecordsByTerritory(lstOfSobject, objMtd);
    Test.stopTest();
    List<LeadShare> createdLeadShare = (List<LeadShare>) dmlMockProvider.getHistory(
        'doInsert'
      )
      .getParam('records');
    List<LeadShare> deletedLeadShare = (List<LeadShare>) dmlMockProvider.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      idOwner2,
      createdLeadShare[0].UserOrGroupId,
      'Share Record for other user in territory not created'
    );
    Assert.areEqual(
      idOwner,
      deletedLeadShare[0].UserOrGroupId,
      'Share Record for curent owner is not deleted'
    );
  }

  /**
   * @description test method for getMapOfTerritoryUsersNonLWOwnedSobjects
   */
  @isTest
  static void testGetMapOfTerritoryUsersNonLWOwnedSobjects() {
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<User_Territory__c> lstOfUT = new List<User_Territory__c>{
      new User_Territory__c(
        ML_Role__c = 'Franchise Admin',
        User__c = idOwner,
        Territory__c = idTerritory,
        Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
      )
    };
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(
        RecordTypeId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead'),
        RecordType = new RecordType(DeveloperName = 'MLCRM_Lead'),
        Territory__c = idTerritory,
        OwnerId = idOwner
      )
    };
    Map<String, String> mapOfUserToRole = new Map<String, String>{
      (String) idOwner + (String) idTerritory => 'Franchise Admin'
    };
    Map<String, List<User_Territory__c>> mapOfTerritoryToUsers = new Map<String, List<User_Territory__c>>{
      (String) idOwner + (String) idTerritory => lstOfUT
    };
    Test.startTest();
    Map<String, List<User_Territory__c>> mapOfUserToResponse = TerritorySharingUtil.getMapOfTerritoryUsersNonLWOwnedSobjects(
      mapOfTerritoryToUsers,
      lstOfSobject,
      mapOfUserToRole
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      mapOfUserToResponse.get((String) idOwner + (String) idTerritory).size(),
      'There is no User territory record for lead owner and territory for a non Loan Writer role'
    );
  }

  /**
   * @description test method for getMapOfTerritoryUsersLWOwnedSobjects
   */
  @isTest
  static void testGetMapOfTerritoryUsersLWOwnedSobjects() {
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<User_Territory__c> lstOfUT = new List<User_Territory__c>{
      new User_Territory__c(
        ML_Role__c = 'Loan Writer',
        User__c = idOwner,
        Territory__c = idTerritory,
        Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
      )
    };
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(
        RecordTypeId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead'),
        RecordType = new RecordType(DeveloperName = 'MLCRM_Lead'),
        Territory__c = idTerritory,
        OwnerId = idOwner
      )
    };
    Map<String, String> mapOfUserToRole = new Map<String, String>{
      (String) idOwner + (String) idTerritory => 'Loan Writer'
    };
    Map<String, List<User_Territory__c>> mapOfTerritoryToUsers = new Map<String, List<User_Territory__c>>{
      (String) idOwner + (String) idTerritory => lstOfUT
    };
    Test.startTest();
    Map<String, List<User_Territory__c>> mapOfUserToResponse = TerritorySharingUtil.getMapOfTerritoryUsersLWOwnedSobjects(
      mapOfTerritoryToUsers,
      lstOfSobject,
      mapOfUserToRole
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      mapOfUserToResponse.get((String) idOwner + (String) idTerritory).size(),
      'There is no User territory record for lead owner and territory for a Loan Writer role'
    );
  }

  /**
   * @description test method for getMapOfTerritoryUsers
   */
  @isTest
  static void testGetMapOfTerritoryUsers() {
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(
        RecordTypeId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead'),
        RecordType = new RecordType(DeveloperName = 'MLCRM_Lead'),
        Territory__c = idTerritory,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    List<User_Territory__c> lstOfUT = new List<User_Territory__c>{
      new User_Territory__c(
        ML_Role__c = 'Loan Writer',
        User__c = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Territory__c = idTerritory,
        Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
      )
    };
    Map<Id, List<User_Territory__c>> mapOfTerritoryToUsers = new Map<Id, List<User_Territory__c>>{
      idTerritory => lstOfUT
    };
    Test.startTest();
    Map<String, List<User_Territory__c>> mapOfResult = TerritorySharingUtil.getMapOfTerritoryUsers(
      mapOfTerritoryToUsers,
      lstOfSobject
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      mapOfResult.get(
          (String) lstOfSobject[0].OwnerId +
          (String) lstOfSobject[0].Territory__c
        )
        .size(),
      'There are no User Territory records for users other than lead owner for a given territory'
    );
  }

  /**
   * @description test method for filterRecordsByTerritoryInMap
   */
  @isTest
  static void testFilterRecordsByTerritoryInMap() {
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Map<Id, List<User_Territory__c>> mapOfTerritoryToUsers = new Map<Id, List<User_Territory__c>>();
    List<User_Territory__c> lstOfUT = new List<User_Territory__c>{
      new User_Territory__c(ML_Role__c = 'Loan Writer')
    };
    List<SObject> lstOfSobject = new List<Lead>{
      new Lead(
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Territory__c = idTerritory
      )
    };
    mapOfTerritoryToUsers.put(idTerritory, lstOfUT);
    Test.startTest();
    List<SObject> lstOfResult = TerritorySharingUtil.filterRecordsByTerritoryInMap(
      lstOfSobject,
      mapOfTerritoryToUsers
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfResult.size(),
      'There are no records which has territory as per given territory Id'
    );
  }

  /**
   * @description test method for getOwnerRoleKey
   */
  @isTest
  static void testGetOwnerRoleKey() {
    Lead objSObject = new Lead(
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType)
    );
    Test.startTest();
    String strResult = TerritorySharingUtil.getOwnerRoleKey(objSObject);
    Test.stopTest();
    Assert.areEqual(
      (String) objSObject.OwnerId + (String) objSObject.Territory__c,
      strResult,
      'Owner and Territory is not concatenated'
    );
  }

  /**
   * @description test method for createMapUserTerritoryKeyToRoles
   */
  @isTest
  static void testCreateMapUserTerritoryKeyToRoles() {
    List<User_Territory__c> lstOfUserTerritory = new List<User_Territory__c>{
      new User_Territory__c(
        User__c = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType),
        ML_Role__c = 'Loan Writer'
      )
    };
    Test.startTest();
    Map<String, String> mapOfUserToRole = TerritorySharingUtil.createMapUserTerritoryKeyToRoles(
      lstOfUserTerritory
    );
    Test.stopTest();
    Assert.areEqual(
      'Loan Writer',
      mapOfUserToRole.get(
        (String) lstOfUserTerritory[0].User__c +
        (String) lstOfUserTerritory[0].Territory__c
      ),
      'Map of user + territory to role is not created'
    );
  }

  /**
   * @description test method for createShareRecordsByFranchise
   */
  @isTest
  static void testCreateShareRecordsByFranchise() {
    registerMocks();
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id franchiseOwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(Id = idLead, OwnerId = idOwner, Territory__c = idTerritory)
    };
    Territory__c terrRecord = new Territory__c(
      Id = idTerritory,
      Access_Scope__c = 'Unrestricted',
      Primary_Franchise_Owner__c = franchiseOwnerId
    );
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Territory',
      Sharing_Object__c = 'LeadShare',
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead'
    );
    territoryMockProvider.mock(
      'getTerritoryMap',
      new Map<Id, Territory__c>{ idTerritory => terrRecord }
    );
    userTerritoryMockProvider.mock(
      'getUserTerritoryFromFranchiseOwnerId',
      new List<User_Territory__c>{
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner,
          Territory__c = idTerritory,
          Territory__r = terrRecord
        ),
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner2,
          Territory__c = idTerritory,
          Territory__r = terrRecord
        )
      }
    );
    territoryMockProvider.mock(
      'getShareRecords',
      new List<LeadShare>{
        new LeadShare(
          Id = Lib_FakeIdGenerator.getMockId(LeadShare.SObjectType),
          UserOrGroupId = idOwner,
          LeadId = idLead
        )
      }
    );
    Test.startTest();
    TerritorySharingUtil.createShareRecordsByFranchise(lstOfSobject, objMtd);
    Test.stopTest();
    List<LeadShare> createdLeadShare = (List<LeadShare>) dmlMockProvider.getHistory(
        'doInsert'
      )
      .getParam('records');
    List<LeadShare> deletedLeadShare = (List<LeadShare>) dmlMockProvider.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      idOwner2,
      createdLeadShare[0].UserOrGroupId,
      'Share Record for other user with same franchise owner not created'
    );
    Assert.areEqual(
      idOwner,
      deletedLeadShare[0].UserOrGroupId,
      'Share Record for curent owner is not deleted'
    );
  }

  /**
   * @description test method for createShareRecordsForParentObj
   */
  @isTest
  static void testCreateShareRecordsForParentObj() {
    registerMocks();
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Interaction> lstOfSobject = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        OwnerId = idOwner,
        Territory__c = idTerritory,
        RecordTypeId = QueryRT.of(Interaction.SObjectType)
          .getId('ML_Interaction'),
        RecordType = new RecordType(DeveloperName = 'ML_Interaction'),
        Lead__c = leadId,
        Lead__r = new Lead(Id = leadId, OwnerId = idOwner)
      )
    };
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Parent Object',
      Sharing_Object__c = 'InteractionShare',
      Object_Name__c = 'Interaction',
      Lookup_Fields__c = 'Lead__c',
      Eligible_Record_Types__c = 'ML_Interaction',
      IsParentIdField__c = true
    );
    Territory_Based_Sharing_Config__mdt leadObjMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Territory',
      Sharing_Object__c = 'LeadShare',
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead',
      IsParentIdField__c = false
    );
    territoryMockProvider.mock(
      'getTerritorySharingMetadata',
      new List<Territory_Based_Sharing_Config__mdt>{ objMtd, leadObjMtd }
    );
    userTerritoryMockProvider.mock(
      'getUserTerritories',
      new List<User_Territory__c>{
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        ),
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner2,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        )
      }
    );
    territoryMockProvider.mock(
      'getShareRecords',
      new List<InteractionShare>{
        new InteractionShare(
          UserOrGroupId = idOwner,
          ParentId = lstOfSobject[0].Id
        )
      }
    );
    Test.startTest();
    TerritorySharingUtil.createShareRecordsForParentObj(lstOfSobject, objMtd);
    Test.stopTest();

    List<InteractionShare> createdInteractionShare = (List<InteractionShare>) dmlMockProvider.getHistory(
        'doInsert'
      )
      .getParam('records');
    List<InteractionShare> deletedInteractionShare = (List<InteractionShare>) dmlMockProvider.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      idOwner2,
      createdInteractionShare[0].UserOrGroupId,
      'Interaction is not shared with second user in territory of Parent Object Lead'
    );
    Assert.areEqual(
      idOwner,
      deletedInteractionShare[0].UserOrGroupId,
      'Share Record of previous Owner not deleted'
    );
  }

  /**
   * @description test method for filterSobjectBasedOnTerritoryScope
   */
  @isTest
  static void filterSobjectBasedOnTerritoryScopeTest() {
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Interaction> lstOfSobject = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        OwnerId = idOwner,
        Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType),
        RecordTypeId = QueryRT.of(Interaction.SObjectType)
          .getId('ML_Interaction'),
        RecordType = new RecordType(DeveloperName = 'ML_Interaction'),
        Lead__c = leadId,
        Lead__r = new Lead(Id = leadId, OwnerId = idOwner)
      )
    };
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Parent Object',
      Sharing_Object__c = 'InteractionShare',
      Object_Name__c = 'Interaction',
      Lookup_Fields__c = 'Lead__c',
      Eligible_Record_Types__c = 'ML_Interaction',
      IsParentIdField__c = true
    );
    Territory_Based_Sharing_Config__mdt leadObjMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Territory',
      Sharing_Object__c = 'LeadShare',
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead',
      IsParentIdField__c = false
    );
    Test.startTest();
    TerritorySharingUtil.WrapSobjectBasedOnScope objWrap = TerritorySharingUtil.filterSobjectBasedOnTerritoryScope(
      lstOfSobject,
      objMtd,
      new Map<String, Territory_Based_Sharing_Config__mdt>{
        'Interaction' => objMtd,
        'Lead' => leadObjMtd
      }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      objWrap.lstOfTerritoryShareRecord.size(),
      'SObject not added in list filtered based on territory'
    );
  }

  /**
   * @description test method for getSobjectType
   */
  @isTest
  static void testGetSobjectType() {
    Test.startTest();
    String strSobjectName = TerritorySharingUtil.getSobjectType(
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
        Lead__c = Lib_FakeIdGenerator.getMockId(Lead.SObjectType)
      ),
      'Lead__c'
    );
    Test.stopTest();
    Assert.areEqual(
      'Lead',
      strSobjectName,
      'SObject Type of Lookup field is not correct'
    );
  }

  /**
   * @description test method for insertShareRecord
   */
  @isTest
  static void testInsertShareRecord() {
    registerMocks();
    List<LeadShare> leadShareObjects = new List<LeadShare>{
      new LeadShare(
        LeadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        UserOrGroupId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        RowCause = 'Manual'
      )
    };
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Territory',
      Sharing_Object__c = 'LeadShare',
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead'
    );
    Test.startTest();
    TerritorySharingUtil.insertShareRecord(leadShareObjects, objMtd);
    Test.stopTest();
    List<LeadShare> createdLeadShare = (List<LeadShare>) dmlMockProvider.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      'Manual',
      createdLeadShare[0].RowCause,
      'Lead Share Record is not created'
    );
  }

  /**
   * @description test method for deleteShareRecords
   */
  @isTest
  static void testDeleteShareRecords() {
    registerMocks();
    List<LeadShare> leadShareObjects = new List<LeadShare>{
      new LeadShare(
        LeadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        UserOrGroupId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        RowCause = 'Manual'
      )
    };
    territoryMockProvider.mock('getShareRecords', leadShareObjects);
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Territory',
      Sharing_Object__c = 'LeadShare',
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead'
    );
    Test.startTest();
    TerritorySharingUtil.deleteShareRecords(leadShareObjects, objMtd);
    Test.stopTest();
    List<LeadShare> deletedLeadShare = (List<LeadShare>) dmlMockProvider.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      'Manual',
      deletedLeadShare[0].RowCause,
      'Lead Share Record is not deleted'
    );
  }

  /**
   * @description test method for processSharingException
   */
  @isTest
  static void testProcessSharingException() {
    TerritorySharingUtil.WrapSharingError wrapper = new TerritorySharingUtil.WrapSharingError(
      Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      Lib_FakeIdGenerator.getMockId(User.SObjectType),
      'Error'
    );
    Test.startTest();
    Exception ex = TerritorySharingUtil.processSharingException(
      new List<TerritorySharingUtil.WrapSharingError>{ wrapper }
    );
    Test.stopTest();
    Assert.isTrue(
      ex.getMessage().contains(wrapper.recordId),
      'Exception is not generated'
    );
  }
}
