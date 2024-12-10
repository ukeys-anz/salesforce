/**
 * @author Ayushi Gupta
 * @since  09/2024
 * @description Test class of LaunchAppOnOppHelper
 */
@isTest
private class LaunchAppOnOppHelperTest {
  @isTest
  static void createOppLineItemWrapperTest() {
    //Mock data creation
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      UnitPrice = 20,
      Funding_purpose__c = 'Property Purchase or Construction',
      Product2 = new Product2(Name = 'Test')
    );
    Test.startTest();
    List<LaunchAppOnOppController.OppLineItemWrapper> items = LaunchAppOnOppHelper.createOppLineItemWrapper(
      new List<OpportunityLineItem>{ oli }
    );
    Test.stopTest();
    Assert.isFalse(items.size() == 0, 'No items found');
    Assert.areEqual(
      'Property Purchase or Construction',
      items[0].fundingPurpose,
      'Funding purpose is not set correctly'
    );
    Assert.areEqual(
      'Test',
      items[0].productName,
      'Product Name is not set correctly'
    );
  }

  @isTest
  static void createProductAmountMapTest() {
    //Mock data creation
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      UnitPrice = 20,
      Funding_purpose__c = 'Property Purchase or Construction',
      Product2 = new Product2(Name = 'Test')
    );
    Test.startTest();
    Map<Id, Decimal> result = LaunchAppOnOppHelper.createProductAmountMap(
      new List<OpportunityLineItem>{ oli }
    );
    Test.stopTest();
    Assert.areEqual(1, result.keySet().size(), 'Map is empty');
  }
}
