/**
 * @description CommercialOppLineItemTriggerHandlerTest is the handler test class for CommercialOppLineItemTriggerHandler.
 * @author Ayushi Gupta
 * @since Aug 2025
 */
@isTest
public class CommercialOppLineItemTriggerHandlerTest {
  static Lib_MockProvider oliRepoMock;
  static void registerMocks() {
    oliRepoMock = Lib_MockProvider.forType(
      CommercialOppLineItemRepository.class
    );
  }
  @isTest
  static void onBeforeDeleteTest() {
    registerMocks();
    //GIVEN records, oldMap
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

    List<OpportunityLineItem> records = new List<OpportunityLineItem>();
    List<OpportunityLineItem> filteredOliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(
        Id = oliId,
        Product2Id = productId,
        OpportunityId = oppId
      )
    };
    Map<Id, OpportunityLineItem> oldMap = new Map<Id, OpportunityLineItem>{
      oliId => new OpportunityLineItem(
        Id = oliId,
        Product2Id = productId,
        OpportunityId = oppId
      )
    };

    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
        ApplicationFormId = Lib_FakeIdGenerator.getMockId(
          ApplicationForm.SObjectType
        ),
        ProductId = productId,
        ApplicationForm = new ApplicationForm(
          OpportunityId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
        )
      )
    };

    oliRepoMock.mock('getOliRecords', filteredOliList);
    oliRepoMock.mock('getAppFormProduct', afpList);

    CommercialOppLineItemTriggerHandler handler = new CommercialOppLineItemTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeDelete();
    Test.stopTest();

    //THEN it should not throw an error
    Assert.areEqual(
      false,
      oldMap.get(oliId).hasErrors(),
      'should not throw error while deletion OLI'
    );
  }
}
