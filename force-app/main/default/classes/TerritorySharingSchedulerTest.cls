/**
 * @author Ashish Kumar
 * @since 09/2025
 * @description Test class for TerritorySharingScheduler.
 */
@isTest
private class TerritorySharingSchedulerTest {
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
      IsParentIdField__c = true,
      Excluded_Users__c = 'test@anzx.com',
      Recalculation_Timeframe__c = 24
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
    TerritorySharingScheduler objBatch = new TerritorySharingScheduler();
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
      'TerritorySharingRecalculationBatch',
      'TerritorySharingScheduler is not executing TerritorySharingRecalculationBatch'
    );
  }

  @isTest
  static void testGetValidTerritoryMetadata() {
    // Arrange
    List<Territory_Based_Sharing_Config__mdt> inputMetadata = new List<Territory_Based_Sharing_Config__mdt>{
      new Territory_Based_Sharing_Config__mdt(
        Active__c = true,
        Row_Cause__c = 'Manual',
        Sharing_Scope__c = 'Territory',
        Sharing_Object__c = 'LeadShare',
        Object_Name__c = 'Lead',
        Eligible_Record_Types__c = 'MLCRM_Lead',
        Territory_Field__c = 'Territory__c',
        Excluded_Users__c = 'test@anz.com'
      )
    };

    // Act
    Test.startTest();
    List<Territory_Based_Sharing_Config__mdt> validMetadata = TerritorySharingScheduler.getValidTerritoryMetadata(
      inputMetadata
    );
    Test.stopTest();

    // Assert
    System.assertEquals(
      1,
      validMetadata.size(),
      'Only one valid config should be returned'
    );
  }
}
