/**
 * @author Ayushi Gupta
 * @since  09/2025
 * @description Test class of ModifyProductController
 */
@isTest
private class ModifyProductControllerTest {
  static Lib_MockProvider modifyProductRepo;

  static void registerMocks() {
    modifyProductRepo = Lib_MockProvider.forType(ModifyProductRepository.class);
  }

  @isTest
  static void getProductsTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      UnitPrice = 20,
      Funding_purpose__c = 'Property Purchase or Construction',
      Product2 = new Product2(Name = 'Test'),
      OpportunityId = oppId
    );
    modifyProductRepo.mock('getProducts', new List<OpportunityLineItem>{ oli });
    Test.startTest();
    List<OpportunityLineItem> items = ModifyProductController.getProducts(
      oppId
    );
    Test.stopTest();
    Assert.areEqual(1, items.size(), 'No Opp Line Items found');
  }
}
