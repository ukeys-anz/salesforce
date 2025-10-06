/**
 * @author Ashish Kumar
 * @since 04/2024
 * @description  To test TerritoryCommonUtilsHelperTest
 */
@isTest
public class TerritoryCommonUtilsHelperTest {
  static Lib_MockProvider userTerritoryRepoMock;
  static void registerMocks() {
    userTerritoryRepoMock = Lib_MockProvider.forType(
      UserTerritoryActionsRepository.class
    );
  }
  static final String MLCRM_LEAD_RT_ID = QueryRT.of(Lead.SObjectType)
    .getId('MLCRM_Lead');

  /**
   * @description test method for filterOwnerIdChanged
   */
  @isTest
  static void testFilterSobjectsByOwnerChanged() {
    List<SObject> lstOfSobject = new List<SObject>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Test.startTest();
    List<SObject> lstOfValidSobject = TerritoryCommonUtilsHelper.filterSobjectsByOwnerChanged(
      lstOfSobject,
      null
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfValidSobject.size(),
      'Lead object is not filtered basis changed owner'
    );
  }

  /**
   * @description test method for ValidateUserRole
   */
  @isTest
  static void testValidateUserRole() {
    SObject objSObject = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    Test.startTest();
    Boolean isValidRecord = TerritoryCommonUtilsHelper.validateUserRole(
      'Admin',
      objSObject,
      Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      isValidRecord,
      'Current User role is not validated as Admin'
    );
  }

  /**
   * @description test method for validateOwnerAssignment
   */
  @isTest
  static void testvalidateOwnerAssignment() {
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType)
      )
    };
    Set<String> setOfUserTerritoryKeys = new Set<String>{
      (String) Lib_FakeIdGenerator.getMockId(User.SObjectType) +
      (String) lstOfSobject[0].Territory__c
    };
    Test.startTest();
    List<SObject> ownerChangedRecords = TerritoryCommonUtilsHelper.validateOwnerAssignment(
      lstOfSobject,
      setOfUserTerritoryKeys
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      ownerChangedRecords.size(),
      'Owner is not changed for the record'
    );
  }
  /**
   * @description test method for validateTerritoryAssignment
   */
  @isTest
  static void testvalidateTerritoryAssignment() {
    List<Lead> lstOfSobject = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType)
      )
    };
    Set<String> setOfUserTerritoryKeys = new Set<String>{
      (String) Lib_FakeIdGenerator.getMockId(User.SObjectType) +
      (String) lstOfSobject[0].Territory__c
    };
    Test.startTest();
    List<SObject> ownerChangedRecords = TerritoryCommonUtilsHelper.validateTerritoryAssignment(
      lstOfSobject,
      setOfUserTerritoryKeys
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      ownerChangedRecords.size(),
      'Record territory is not as same as User territory'
    );
  }

  /**
   * @description test method for getUserTerritoryKey
   */
  @isTest
  static void testgetUserTerritoryKey() {
    List<User_Territory__c> lstOfUserTerritory = new List<User_Territory__c>{
      new User_Territory__c(
        ML_Role__c = 'Franchise Owner',
        Status__c = 'Active',
        Territory__c = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType),
        User__c = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Test.startTest();
    Set<String> setOfUserTerritoryKeys = TerritoryCommonUtilsHelper.getUserTerritoryKey(
      lstOfUserTerritory
    );
    Test.stopTest();
    Assert.isTrue(
      setOfUserTerritoryKeys.contains(
        String.valueOf(lstOfUserTerritory[0].User__c) +
        String.valueOf(lstOfUserTerritory[0].Territory__c)
      ),
      'Concatenation of User and Territory for users territory record is not working'
    );
  }
  /*
   * description test method for raiseSobjectError
   */
  @isTest
  static void testraiseSobjectError() {
    List<SObject> lstOfSobjectTerritoryNull = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Territory__c = null
      )
    };
    String strTerritoryNullMessage = 'Territory needs to be populated.';
    String strNonTerritoryOwnerMessage = 'You cannot assign record to a Territory you are not assigned to.';
    Test.startTest();
    TerritoryCommonUtilsHelper.raiseSobjectError(
      lstOfSobjectTerritoryNull,
      strTerritoryNullMessage
    );
    TerritoryCommonUtilsHelper.raiseSobjectError(
      lstOfSobjectTerritoryNull,
      strNonTerritoryOwnerMessage
    );
    Test.stopTest();
    Assert.areEqual(
      lstOfSobjectTerritoryNull[0].getErrors()[0].getMessage(),
      strTerritoryNullMessage,
      'AddError method not working properly in case of multiple error message on same sobject record'
    );
  }

  /**
   * @description test method for filterSobjectsByTerritoryNull
   */
  @isTest
  static void testFilterSobjectsByTerritoryNull() {
    List<SObject> lstOfSobject = new List<Lead>{
      new Lead(RecordTypeId = MLCRM_LEAD_RT_ID, Territory__c = null)
    };
    Test.startTest();
    List<SObject> lstOfValidSobject = TerritoryCommonUtilsHelper.filterSobjectsByTerritoryNull(
      lstOfSobject
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfValidSobject.size(),
      'Method did not filter records with null territory'
    );
  }

  /**
   * @description test method for createOwnerIdSet
   */
  @isTest
  static void testCreateOwnerIdSet() {
    List<SObject> lstOfSobject = new List<Lead>{
      new Lead(
        RecordTypeId = MLCRM_LEAD_RT_ID,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Test.startTest();
    Set<Id> idsofLeadOwner = TerritoryCommonUtilsHelper.createOwnerIdSet(
      lstOfSobject
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      idsofLeadOwner.size(),
      'Method did not returned set of owner ids from list of sobject records'
    );
  }

  /**
   * @description test method for getUserRole
   */
  @isTest
  static void testGetUserRole() {
    registerMocks();
    Id territoryId = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id ownerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    userTerritoryRepoMock.mock(
      'getActiveUserTerrritories',
      new List<User_Territory__c>{
        new User_Territory__c(
          Id = Lib_FakeIdGenerator.getMockId(User_Territory__c.SObjectType),
          User__c = ownerId,
          ML_Role__c = 'Loan Writer',
          Territory__c = territoryId
        )
      }
    );
    Test.startTest();
    Map<String, String> mapOfUserToRole = TerritoryCommonUtilsHelper.getUserRole(
      new Set<Id>{ ownerId }
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      mapOfUserToRole.containsKey(((String) territoryId + (String) ownerId)),
      'User is not present in User Territory setup'
    );
  }

  /**
   * @description test method for getUserTerritoryFranchiseWise
   */
  @isTest
  static void testGetUserTerritoryFranchiseWise() {
    registerMocks();
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    userTerritoryRepoMock.mock(
      'getUserTerritoryFromFranchiseOwnerId',
      new List<User_Territory__c>{
        new User_Territory__c(
          Id = Lib_FakeIdGenerator.getMockId(User_Territory__c.SObjectType),
          ML_Role__c = 'Franchise Owner',
          Status__c = 'Active',
          Territory__c = Lib_FakeIdGenerator.getMockId(
            Territory__c.SObjectType
          ),
          User__c = userId
        )
      }
    );
    Test.startTest();
    Map<Id, List<User_Territory__c>> mapOfFranchiseToUsers = TerritoryCommonUtilsHelper.getUserTerritoryFranchiseWise(
      new Set<Id>{ UserId }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      mapOfFranchiseToUsers.size(),
      'User Territory is not setup with Primary_Franchise_Owner__c for this user'
    );
  }

  /**
   * @description test method for getUserTerritoriesToValidate
   */
  @isTest
  static void testGetUserTerritoriesToValidate() {
    registerMocks();
    Id ownerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    userTerritoryRepoMock.mock(
      'getActiveUserTerrritories',
      new List<User_Territory__c>{
        new User_Territory__c(
          Id = Lib_FakeIdGenerator.getMockId(User_Territory__c.SObjectType),
          User__c = ownerId,
          Territory__c = Lib_FakeIdGenerator.getMockId(
            Territory__c.SObjectType
          ),
          ML_Role__c = 'Loan Writer',
          Status__c = 'Active'
        )
      }
    );
    Test.startTest();
    List<User_Territory__c> lstOfLoggedInUserTerritory = TerritoryCommonUtilsHelper.getUserTerritoriesToValidate(
      new Set<Id>{ ownerId }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      lstOfLoggedInUserTerritory.size(),
      'UserTerritories not present for given ownerIds'
    );
  }
}
