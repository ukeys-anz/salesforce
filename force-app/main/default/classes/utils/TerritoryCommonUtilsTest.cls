/**
 * @author Hitesh Wasdani
 * @since 04/2024
 * @description  To test TerritoryCommonUtils
 */
@isTest
public class TerritoryCommonUtilsTest {
  static Lib_MockProvider userRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userTerritoryActionsRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    userRepoMock = Lib_MockProvider.forType(UserActionsRepository.class);
    userTerritoryActionsRepoMock = Lib_MockProvider.forType(
      UserTerritoryActionsRepository.class
    );
  }
  /**
   * @description test method for filterSobjectsByTerritoryNull
   */
  @isTest
  static void testfilterSobjectsByTerritoryNull() {
    Id mlcrmLeadRtId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead');
    List<sObject> lstOfSobject = new List<Lead>{
      new Lead(RecordTypeId = mlcrmLeadRtId, Territory__c = null)
    };
    Test.startTest();
    List<sObject> lstOfValidSobject = TerritoryCommonUtilsHelper.filterSobjectsByTerritoryNull(
      lstOfSobject
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfValidSobject.size(),
      'filterSobjectsByTerritoryNull is not filtering list where Territory is null '
    );
  }

  /**
   * @description test method for filterSobjectsByTerritoryChanged
   */
  @isTest
  static void testfilterSobjectsByTerritoryChanged() {
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<sObject> lstOfSobject = new List<Lead>{
      new Lead(
        Id = leadId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType)
      )
    };
    Lead oldSObject = new Lead(
      Id = leadId,
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Territory__c = Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    Map<Id, Lead> oldMapSobject = new Map<Id, Lead>{
      (Id) oldSObject.get('Id') => oldSObject
    };
    Test.startTest();
    List<sObject> lstOfValidSobject = TerritoryCommonUtilsHelper.filterSobjectsByTerritoryChanged(
      lstOfSobject,
      oldMapSobject
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfValidSobject.size(),
      'filterSobjectsByTerritoryChanged is not filtering records when Territory get Changed'
    );
  }

  /**
   * @description test method for testGetRecordTypeIdsByDeveloperName
   */
  @isTest
  static void testGetRecordTypeIdsByDeveloperName() {
    List<String> lstDevelopername = new List<String>{ 'MLCRM_Lead' };
    Test.startTest();
    Set<Id> setOfRTids = TerritoryCommonUtils.getRecordTypeIdsByDeveloperName(
      'Lead',
      lstDevelopername
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      setOfRTids.size(),
      'testGetRecordTypeIdsByDeveloperName is not returning correct set of Ids of RecordTypes'
    );
  }

  /**
   * @description test method for validateTerritoryAndOwnerChange
   */
  @isTest
  static void testvalidateTerritoryAndOwnerChange() {
    registerMocks();
    List<Lead> newLeads = new List<Lead>();
    for (Integer i = 1; i <= 5; i++) {
      Id mlcrmLeadRtId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead');
      String staticNumber = Datetime.now().format('MMddHHmmss') + i;
      Lead leadRecord = new Lead(
        Email = 'sam' + staticNumber + '@test.com',
        RecordTypeId = mlcrmLeadRtId,
        Description = 'Need a new Credit Card',
        Expiry_Date__c = System.today() + 10,
        FinServ__ExpressedInterest__c = 'Personal Loan',
        FinServ__PotentialValue__c = 12000,
        FirstName = 'Sam' + staticNumber,
        LastName = 'Jacob',
        LeadSource = 'Partner',
        New_to_Bank__c = 'Yes',
        Campaign_Code__c = staticNumber,
        Lead_Originator__c = 'Adobe',
        Business_ID__c = '012345',
        Status = 'New',
        OwnerId = UserInfo.getUserId()
      );
      newLeads.add(leadRecord);
    }
    userRepoMock.mock('filterSobjectsByUpdatedByMLUser', newLeads);
    userRepoMock.mock('isIntegrationUser', false);
    userRepoMock.mock('isCustomValidationsSkipped', false);
    userRepoMock.mock('isCurrentLoggedInMLOrAdminUser', true);
    userRepoMock.mock('isCurrentLoggedInNotMLOrAdminUser', false);
    Test.startTest();
    TerritoryCommonUtils.validateTerritoryAndOwnerChange(null, newLeads);
    Test.stopTest();
    Assert.areEqual(
      newLeads[0].OwnerId,
      UserInfo.getUserId(),
      'Territory and Owner Change has not validated properly'
    );
  }
  /*
   * description test method for filterSobjectsByOwnerChanged
   */
  @isTest
  static void testfilterSobjectsByOwnerChanged() {
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<sObject> lstOfSobject = new List<Lead>{
      new Lead(
        Id = idLead,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Lead sObjectOld = new Lead(
      Id = idLead,
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    Map<Id, Lead> oldMapSobject = new Map<Id, Lead>{ idLead => sObjectOld };
    Test.startTest();
    List<sObject> lstOfFilterRecords = TerritoryCommonUtilsHelper.filterSobjectsByOwnerChanged(
      lstOfSobject,
      oldMapSobject
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfFilterRecords.size(),
      'testfilterSobjectsByOwnerChanged method is not filtering records correctly when Owner is changed'
    );
  }

  /*
   * @description test method for testfilterOwnedByFranchiseUsers
   */
  @isTest
  static void testfilterOwnedByFranchiseUsers() {
    Id sobjectUserId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id sobjectUserRoleId = Lib_FakeIdGenerator.getMockId(UserRole.SObjectType);
    User objSObjectUser = new User(
      Id = sobjectUserId,
      UserRoleId = sobjectUserRoleId
    );
    Map<Id, User> mapOfUsers = new Map<Id, User>{
      sobjectUserId => (User) objSObjectUser
    };
    List<sObject> lstOfSobject = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = sobjectUserId
      )
    };
    TerritoryCommonUtils.strFranchiseRoleId = sobjectUserRoleId;
    Test.startTest();
    List<sObject> returnList = TerritoryCommonUtils.filterOwnedByFranchiseUsers(
      lstOfSobject,
      mapOfUsers
    );
    Test.stopTest();
    Assert.areEqual(1, returnList.size(), 'Owner is not Franchise user ');
  }
  /*
   * description test method for addToOwnerIdSetIfOwnerChanged
   */
  @isTest
  static void testaddToOwnerIdSetIfOwnerChanged() {
    Id sobjectUserId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id sobjectUserRoleId = UserInfo.getUserRoleId();
    sObject objSObjectUser = new User(
      Id = sobjectUserId,
      UserRoleId = sobjectUserRoleId
    );
    Map<Id, User> mapOfUsers = new Map<Id, User>{
      sobjectUserId => (User) objSObjectUser
    };
    Id sobjectId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(
        Id = sobjectId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Lead oldSObject = new Lead(
      Id = sobjectId,
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );

    Map<Id, Lead> oldMapSobject = new Map<Id, Lead>{
      (Id) oldSObject.get('Id') => oldSObject
    };
    Test.startTest();
    TerritoryCommonUtils.getMapOfUsers(lstOfSobject);
    Set<Id> setOfOwnerId = TerritoryCommonUtils.addToOwnerIdSetIfOwnerChanged(
      lstOfSobject,
      oldMapSobject,
      mapOfUsers
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      setOfOwnerId.size(),
      'testaddToOwnerIdSetIfOwnerChanged is not adding ids of Owner if record owner is changed and user is ML profile'
    );
  }
  /*
   * description test method for filterValidateSobjectRecords
   */
  @isTest
  static void testfilterValidateSobjectRecords() {
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id mlcrmLeadRtId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead');
    Lead objSObject = new Lead(
      OwnerId = idOwner,
      Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType),
      Id = idLead,
      RecordTypeId = mlcrmLeadRtId
    );
    Lead objSObject1 = new Lead(
      OwnerId = idOwner,
      RecordTypeId = mlcrmLeadRtId,
      Id = idLead
    );
    List<sObject> lstOfSobject = new List<Lead>{ objSObject, objSObject1 };
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Object_Name__c = 'Lead',
      Eligible_Record_Types__c = 'MLCRM_Lead',
      Active__c = true,
      Recalculation_Timeframe__c = 24,
      Lookup_Fields__c = 'Lead__c;Opportunity__c;Customer_Relationship__c'
    );
    Test.startTest();
    List<sobject> returnLst = TerritoryCommonUtils.filterValidateSobjectRecords(
      lstOfSobject,
      objMtd
    );
    Test.stopTest();
    Assert.areEqual(
      2,
      returnLst.size(),
      'testfilterValidateSobjectRecords method is not filtering validated sobject record'
    );
  }
  /*
   * description test method for filterSobjectsByUpdatedByNonMLUser
   */
  @isTest
  static void testfilterSobjectsByUpdatedByNonMLUser() {
    registerMocks();
    List<sObject> lstOfSobject = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Customer_Relationship__c.SObjectType
        ),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    userRepoMock.mock('isCurrentLoggedInMLOrAdminUser', false);
    Test.startTest();
    List<sObject> lstOfFilterRecords = TerritoryCommonUtils.filterSobjectsByUpdatedByNonMLUser(
      lstOfSobject
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfFilterRecords.size(),
      'Filtering of Sobjects is not working properly when sobjects records are updated by Non ML user'
    );
  }
  /*
   * @description test method for filterSobjectsByUpdatedByMLUser
   */
  @isTest
  static void testfilterSobjectsByUpdatedByMLUser() {
    registerMocks();
    List<sObject> lstOfSobject = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Customer_Relationship__c.SObjectType
        ),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    userRepoMock.mock('isCurrentLoggedInNotMLOrAdminUser', false);
    Test.startTest();
    List<sObject> lstOfFilterRecords = TerritoryCommonUtils.filterSobjectsByUpdatedByMLUser(
      lstOfSobject
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfFilterRecords.size(),
      'Filtering of Sobjects is not working properly when sobjects records are updated by ML user'
    );
  }
  /*
   * @description test method for addToOwnerIdSetIfTerritoryChangedUserAsFranchise
   */
  @isTest
  static void testaddToOwnerIdSetIfTerrChndUserNotAsFranchise() {
    Id sobjectUserId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id sobjectUserRoleId = UserInfo.getUserRoleId();
    sObject objSObjectUser = new User(
      Id = sobjectUserId,
      UserRoleId = sobjectUserRoleId
    );
    Map<Id, User> mapOfUsers = new Map<Id, User>{
      sobjectUserId => (User) objSObjectUser
    };
    List<sObject> lstOfSobject = new List<sObject>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = sobjectUserId
      )
    };
    Test.startTest();
    TerritoryCommonUtils.strFranchiseRoleId = sobjectUserRoleId;
    Set<Id> idsOfOwnerId = TerritoryCommonUtils.addToOwnerIdSetIfTerritoryChangedUserAsFranchise(
      lstOfSobject,
      mapOfUsers
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      idsOfOwnerId.size(),
      'testaddToOwnerIdSetIfTerrChndUserNotAsFranchise is not returning correct set of ownerIds'
    );
  }

  /**
   * @description test method for createUserToTerritoryMap
   */
  @isTest
  static void testCreateUserToTerritoryMap() {
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Test.startTest();
    Map<Id, User_Territory__c> mapOfUserToTerritory = TerritoryCommonUtils.createUserToTerritoryMap(
      new List<User_Territory__c>{
        new User_Territory__c(
          User__c = userId,
          Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType)
        )
      }
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      mapOfUserToTerritory.containsKey(userId),
      'createUserToTerritoryMap method did not prepared map of user territory with correct user id key'
    );
  }

  /**
   * @description test method for populateSobjectTerritory
   */
  @isTest
  static void testPopulateSobjectTerritory() {
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    User_Territory__c objUT = new User_Territory__c(
      User__c = userId,
      Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType)
    );
    Map<Id, User_Territory__c> mapOfUserToTerritory = new Map<Id, User_Territory__c>{
      userId => objUT
    };
    List<sObject> lstOfSobject = new List<sObject>{
      new Lead(
        RecordTypeId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead'),
        OwnerId = userId
      )
    };
    Test.startTest();
    TerritoryCommonUtils.populateSobjectTerritory(
      lstOfSobject,
      mapOfUserToTerritory
    );
    Test.stopTest();
    Assert.areEqual(
      mapOfUserToTerritory.get(userId).Territory__c,
      (Id) lstOfSobject[0].get('Territory__c'),
      'populateSobjectTerritory method did not populated territory id correctly'
    );
  }

  /*
   * description test method for assignTerritoryOnOwnerChange
   */
  @isTest
  static void testAssignTerritoryOnOwnerChange() {
    registerMocks();
    Id idLead = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id idTerritory1 = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idTerritory2 = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id usrId1 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id usrId2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<User_Territory__c> usrTerrRecord = new List<User_Territory__c>{
      new User_Territory__c(User__c = usrId2, Territory__c = idTerritory2)
    };
    List<sObject> lstOfSobject = new List<Lead>{
      new Lead(Id = idLead, OwnerId = usrId2)
    };
    sObject sObjectOld = new Lead(
      Id = idLead,
      OwnerId = usrId1,
      Territory__c = idTerritory1
    );
    Map<Id, sObject> oldMapSobject = new Map<Id, sObject>{
      idLead => sObjectOld
    };
    userTerritoryActionsRepoMock.mock(
      'getUserTerrritoriesFromUserIds',
      usrTerrRecord
    );
    Test.startTest();
    TerritoryCommonUtils.assignTerritoryOnOwnerChange(
      oldMapSobject,
      lstOfSobject
    );
    Test.stopTest();
    Assert.areEqual(
      idTerritory2,
      (Id) lstOfSobject[0].get('Territory__c'),
      'testAssignTerritoryOnOwnerChange method is not updating territory of record properly'
    );
  }
}
