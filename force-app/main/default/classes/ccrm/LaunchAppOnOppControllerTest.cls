/**
 * @author Ayushi Gupta
 * @since  09/2024
 * @description Test class of LaunchAppOnOppController
 */
@isTest
private class LaunchAppOnOppControllerTest {
  static Lib_MockProvider launchAppRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    launchAppRepoMock = Lib_MockProvider.forType(
      LaunchAppOnOppControllerRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void getOpportunityLineItemsTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    //Mock data creation
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      UnitPrice = 20,
      Funding_purpose__c = 'Property Purchase or Construction',
      Product2 = new Product2(Name = 'Test')
    );
    launchAppRepoMock.mock(
      'getOpportunityLineItems',
      new List<OpportunityLineItem>{ oli }
    );
    Test.startTest();
    List<LaunchAppOnOppController.OppLineItemWrapper> oliList = LaunchAppOnOppController.getOpportunityLineItems(
      oppId
    );
    Test.stopTest();
    Assert.isNotNull(oliList, 'No records are created');
  }

  @isTest
  static void createApplicationTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id recordTypeId = QueryRT.of(ApplicationForm.SObjectType).getId('AMBIT');
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      UnitPrice = 20,
      Funding_purpose__c = 'Property Purchase or Construction',
      Product2 = new Product2(Name = 'Test')
    );
    launchAppRepoMock.mock(
      'getOpportunityLineItemsRelatedToOppAndProduct',
      new List<OpportunityLineItem>{ oli }
    );
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true,"id":"0013000000abcde"}')
      }
    );
    Test.startTest();
    List<Id> appFormProductIds = LaunchAppOnOppController.createApplication(
      oppId,
      new List<Id>{ productId },
      recordTypeId
    );
    Test.stopTest();
    Assert.isNotNull(appFormProductIds, 'No records are created');
  }
}
