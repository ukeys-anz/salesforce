/**
 * @author MLCRM Developer
 * @since 08/2025
 * @description OpportunityActionsHelperTest is the test class for OpportunityActionsHelper Class functionality.
 */
@isTest
public class OpportunityActionsHelperTest {
  static Lib_MockProvider oppRepoMock;
  static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    oppRepoMock = Lib_MockProvider.forType(OpportunityActionsRepository.class);
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
  }

  /**
   * @description test method for getExistingCRRMap
   */
  @isTest
  static void testGetExistingCRRMap() {
    Customer_Relationship__c crr = (Customer_Relationship__c) TestUtil.setFields(
      new Customer_Relationship__c(
        Customer__c = Lib_FakeIdGenerator.getMockId(
          Schema.Account.getSObjectType()
        )
      ),
      new Map<String, Object>{
        'Territory__r' => new Territory__c(
          Primary_Franchise_Owner__c = UserInfo.getUserId()
        )
      }
    );
    Test.startTest();
    Map<String, Customer_Relationship__c> returnMap = OpportunityActionsHelper.getExistingCRRMap(
      new List<Customer_Relationship__c>{ crr }
    );
    Test.stopTest();
    Assert.isTrue(
      returnMap.containsKey(
        String.valueOf(crr.Customer__c) +
        String.valueOf(crr.Territory__r.Primary_Franchise_Owner__c)
      ),
      'key should be correctly formed!'
    );
  }

  /**
   * @description test method for insertCustomerRelationships
   */
  @isTest
  static void testInsertCustomerRelationships() {
    registerMocks();
    Id territoryId = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    List<Opportunity> nonLeadConvertedOpportunities = new List<Opportunity>{
      (Opportunity) TestUtil.setFields(
        new Opportunity(
          AccountId = accountId,
          RecordTypeId = RTOpportunity.mlOpportunity,
          Lead_Converted__c = false,
          Territory__c = territoryId
        ),
        new Map<String, Object>{
          'Territory__r' => new Territory__c(
            Id = territoryId,
            Primary_Franchise_Owner__c = UserInfo.getUserId()
          )
        }
      )
    };
    oppRepoMock.mock(
      'getTerritories',
      new Map<Id, Territory__c>{
        nonLeadConvertedOpportunities[0].Territory__c => new Territory__c(
          Id = nonLeadConvertedOpportunities[0].Territory__c,
          Primary_Franchise_Owner__c = UserInfo.getUserId()
        )
      }
    );
    Map<String, Customer_Relationship__c> existingCrrMap = new Map<String, Customer_Relationship__c>();
    Test.startTest();
    List<Customer_Relationship__c> crrListToInsert = OpportunityActionsHelper.insertCustomerRelationships(
      existingCrrMap,
      nonLeadConvertedOpportunities
    );
    Test.stopTest();
    Assert.areEqual(1, crrListToInsert.size(), '1 crr should be inserted!');
    Assert.areEqual(
      nonLeadConvertedOpportunities[0].Territory__c,
      crrListToInsert[0].Territory__c,
      'Territory should match with opportunity territory'
    );
    Assert.areEqual(
      nonLeadConvertedOpportunities[0].AccountId,
      crrListToInsert[0].Customer__c,
      'Customer id should match with opportunity accountId'
    );
  }

  /**
   * @description test method for insertCustomerRelationships
   */
  @isTest
  static void testInsertCustomerRelationshipsNegative() {
    registerMocks();
    Id territoryId = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    Id accountId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    List<Opportunity> nonLeadConvertedOpportunities = new List<Opportunity>{
      (Opportunity) TestUtil.setFields(
        new Opportunity(
          AccountId = accountId,
          RecordTypeId = RTOpportunity.mlOpportunity,
          Lead_Converted__c = false,
          Territory__c = territoryId
        ),
        new Map<String, Object>{
          'Territory__r' => new Territory__c(Id = territoryId)
        }
      )
    };
    oppRepoMock.mock(
      'getTerritories',
      new Map<Id, Territory__c>{
        nonLeadConvertedOpportunities[0].Territory__c => new Territory__c(
          Id = nonLeadConvertedOpportunities[0].Territory__c
        )
      }
    );
    Map<String, Customer_Relationship__c> existingCrrMap = new Map<String, Customer_Relationship__c>();
    Test.startTest();
    List<Customer_Relationship__c> crrListToInsert = OpportunityActionsHelper.insertCustomerRelationships(
      existingCrrMap,
      nonLeadConvertedOpportunities
    );
    Test.stopTest();
    Assert.areEqual(0, crrListToInsert.size(), 'no crr should be inserted!');
  }
}
