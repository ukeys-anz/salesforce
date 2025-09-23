/**
 * @author Ashish Kumar
 * @since 10/2024
 * @description Test class for TerritoryConfigSharingScheduler.
 */
@isTest
public class TerritoryConfigShareSchedulerTest {
  static Lib_MockProvider territoryConfigSharingMockProvider;

  static void registerMocks() {
    territoryConfigSharingMockProvider = Lib_MockProvider.forType(
      TerritoryConfigSharingRepository.class
    );
  }

  @isTest
  public static void testSchedular() {
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idOwner2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    registerMocks();
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'Manual',
      Sharing_Scope__c = 'Parent Object',
      Sharing_Object__c = 'InteractionShare',
      Object_Name__c = 'Interaction',
      Lookup_Fields__c = 'Lead__c',
      Eligible_Record_Types__c = 'ML_Interaction',
      Territory_Field__c = 'Territory__c',
      IsParentIdField__c = true
    );
    territoryConfigSharingMockProvider.mock(
      'getActiveTerritoryMetadata',
      new List<Territory_Based_Sharing_Config__mdt>{ objMtd }
    );
    territoryConfigSharingMockProvider.mock(
      'getUserTerritoriesToRecalc',
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
    territoryConfigSharingMockProvider.mock(
      'getListOfTerritories',
      new List<Territory__c>()
    );
    Test.startTest();
    TerritoryConfigSharingScheduler objBatch = new TerritoryConfigSharingScheduler();
    objBatch.execute(null);
    Test.stopTest();
    Assert.areEqual(
      [
        SELECT Id, ApexClass.Name
        FROM AsyncApexJob
        WHERE JobType = 'BatchApex'
        LIMIT 1
      ]
      .ApexClass.Name,
      'TerritoryConfigSharingBatch',
      'TerritoryConfigSharingScheduler is not executing TerritoryConfigSharingBatch'
    );
  }

  @isTest
  static void getUserTerritoriesToRecalcTest() {
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    Id idOwner = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    registerMocks();
    territoryConfigSharingMockProvider.mock(
      'getUserTerritoriesToRecalc',
      new List<User_Territory__c>{
        new User_Territory__c(
          ML_Role__c = 'Loan Writer',
          User__c = idOwner,
          Territory__c = idTerritory,
          Territory__r = new Territory__c(Access_Scope__c = 'Unrestricted')
        )
      }
    );
    territoryConfigSharingMockProvider.mock(
      'getListOfTerritories',
      new List<Territory__c>()
    );

    Test.startTest();
    TerritoryConfigSharingScheduler objBatch = new TerritoryConfigSharingScheduler();
    DateTime objDateTime = system.Now();
    List<User_Territory__c> utList = objBatch.getUserTerritoriesToRecalc(
      objDateTime
    );
    Test.stopTest();
    Assert.areEqual(
      utList[0].ML_Role__c,
      'Loan Writer',
      'getUserTerritoriesToRecalc is not returning correct record'
    );
    Assert.areEqual(
      utList[0].Territory__c,
      idTerritory,
      'getUserTerritoriesToRecalc is not returning correct record'
    );
  }

  @isTest
  static void testGetRecalcStartTime() {
    Test.startTest();
    TerritoryConfigSharingScheduler objBatch = new TerritoryConfigSharingScheduler();
    DateTime objDateTime = objBatch.getRecalcStartTime();
    Test.stopTest();
    Assert.areEqual(
      System.now().addHours(-5).format(),
      objDateTime.format(),
      'getRecalcStartTime is not returning correct time'
    );
  }
}
