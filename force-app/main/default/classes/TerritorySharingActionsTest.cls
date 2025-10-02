/**
 * @author MLCRM Developer
 * @since 10/24
 * @description TerritorySharingActionsTest is the test class for TerritorySharingActions Class functionality.
 */
@isTest
public class TerritorySharingActionsTest {
  private static Lib_MockProvider territoryActionRepoMock;
  static Lib_MockProvider userTerritoryMockProvider;
  static void registerMocks() {
    userTerritoryMockProvider = Lib_MockProvider.forType(
      UserTerritoryActionsRepository.class
    );
    territoryActionRepoMock = Lib_MockProvider.forType(
      TerritoryActionsRepository.class
    );
  }
  /**
   * @description test method to test lookup fields split.
   */
  @isTest
  static void testGetLookupFields() {
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt();
    objMtd.Object_Name__c = 'Customer_Relationship__c';
    objMtd.Active__c = true;
    objMtd.Recalculation_Timeframe__c = 24;
    objMtd.Lookup_Fields__c = 'Lead__c;Opportunity__c;Customer_Relationship__c';
    Test.startTest();
    String strLookupFields = TerritorySharingActions.getLookupFields(objMtd);
    Test.stopTest();
    Assert.areEqual(
      'Lead__c,Opportunity__c,Customer_Relationship__c,',
      strLookupFields,
      'Method is not returning correctly spilted form of lookup fields correctly'
    );
  }

  /**
   * @description test method to test where clause
   */
  @isTest
  static void testGetWhereFilter() {
    Id newLeadId = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType());
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt();
    objMtd.Object_Name__c = 'Customer_Relationship__c';
    objMtd.Active__c = true;
    objMtd.Recalculation_Timeframe__c = 24;
    objMtd.Lookup_Fields__c = 'Lead__c;Opportunity__c;Customer_Relationship__c';
    Test.startTest();
    String strWhereClause = TerritorySharingActions.getWhereFilter(
      'Lead',
      new List<Id>{ newLeadId }
    );
    Test.stopTest();
    Assert.areEqual(
      ' WHERE ID IN:idsOfRecords and status !=\'Expired\'',
      strWhereClause,
      'method is not returning correctly where clause based on sobjecttype'
    );
  }

  @isTest
  static void subscribeTerritoryRecordTestInteraction() {
    registerMocks();
    Interaction intxn = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Interaction.getSObjectType()),
      Territory__c = Lib_FakeIdGenerator.getMockId(
        Schema.Territory__c.getSObjectType()
      ),
      InteractionType = 'Call',
      Opportunity__c = Lib_FakeIdGenerator.getMockId(
        Schema.Opportunity.getSObjectType()
      )
    );
    territoryActionRepoMock.mock(
      'getSobjectRecord',
      new List<sObject>{ intxn }
    );
    Test.startTest();
    try {
      TerritorySharingActions.subscribeTerritoryRecord(
        new List<Territory_Base_Sharing_Event__e>{
          new Territory_Base_Sharing_Event__e(
            Record_Ids__c = intxn.Id,
            Trigger_Object__c = 'Interaction',
            Change_Context__c = 'Territory'
          )
        }
      );
      Assert.fail('this line should not execute!');
    } catch (Exception e) {
      Assert.isNotNull(e, 'exception should be thrown!');
    }
    Test.stopTest();
  }

  @isTest
  static void createShareRecordFranchise() {
    registerMocks();
    Customer_Relationship__c crr = new Customer_Relationship__c(
      Id = Lib_FakeIdGenerator.getMockId(
        Schema.Customer_Relationship__c.getSObjectType()
      ),
      Territory__c = Lib_FakeIdGenerator.getMockId(
        Schema.Territory__c.getSObjectType()
      ),
      Relationship_To_Franchise__c = 'Primary'
    );
    Territory_Based_Sharing_Config__mdt objMtd = new Territory_Based_Sharing_Config__mdt(
      Active__c = true,
      Row_Cause__c = 'ML_Franchise_Sharing__c',
      Sharing_Scope__c = 'Franchise',
      Sharing_Object__c = 'Customer_Relationship__Share',
      Object_Name__c = 'Customer_Relationship__c'
    );
    Test.startTest();
    try {
      TerritorySharingActions.createShareRecords(
        new List<Customer_Relationship__c>{ crr },
        objMtd
      );
      Assert.fail('this line should not execute!');
    } catch (Exception e) {
      Assert.isNotNull(e, 'exception should be thrown!');
    }

    Test.stopTest();
  }

  @isTest
  static void subscribeTerritoryRecordTestLead() {
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
    territoryActionRepoMock.mock(
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
    territoryActionRepoMock.mock(
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
    try {
      TerritorySharingActions.subscribeTerritoryRecord(
        new List<Territory_Base_Sharing_Event__e>{
          new Territory_Base_Sharing_Event__e(
            Record_Ids__c = lstOfSobject[0].Id,
            Trigger_Object__c = 'Lead',
            Change_Context__c = 'Territory'
          )
        }
      );
      Assert.fail('this line should not execute!');
    } catch (Exception e) {
      Assert.isNotNull(e, 'exception should be thrown!');
    }
    Test.stopTest();
  }
}
