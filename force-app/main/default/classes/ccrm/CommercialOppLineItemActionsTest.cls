/**
 * @author Naman Garg
 * @since  Jun 2025
 * @description This is the Test class for CommercialOppLineItemActions
 */
@IsTest
public with sharing class CommercialOppLineItemActionsTest {
  static Lib_MockProvider oliRepoMock;
  static void registerMocks() {
    oliRepoMock = Lib_MockProvider.forType(
      CommercialOppLineItemRepository.class
    );
  }

  @isTest
  static void preventOLIDeletionTest() {
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

    //WHEN calling a method
    CommercialOppLineItemActions.preventOLIDeletion(records, oldMap);

    //THEN it should not throw an error
    Assert.areEqual(
      false,
      oldMap.get(oliId).hasErrors(),
      'should not throw error while deletion OLI'
    );
  }

  @isTest
  static void formOppIdToAfpProdIdMapTest() {
    //GIVEN afpList
    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
        ApplicationFormId = Lib_FakeIdGenerator.getMockId(
          ApplicationForm.SObjectType
        ),
        ApplicationForm = new ApplicationForm(
          OpportunityId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
        )
      ),
      new ApplicationFormProduct(
        Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
        ApplicationFormId = Lib_FakeIdGenerator.getMockId(
          ApplicationForm.SObjectType
        ),
        ApplicationForm = new ApplicationForm(
          OpportunityId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
        )
      )
    };

    //WHEN calling a method
    Map<Id, Set<Id>> oppIdToAfpProdIdMap = CommercialOppLineItemActions.formOppIdToAfpProdIdMap(
      afpList
    );

    //THEN it should form a map
    Assert.areEqual(
      2,
      oppIdToAfpProdIdMap.size(),
      'should form a map of Opp Id to AFP product Ids'
    );
  }

  @isTest
  static void preventDeletionTest() {
    //GIVEN oldMap, filteredOliList, oppIdToAfpProdIdMap
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id productId2 = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Map<Id, OpportunityLineItem> oldMap = new Map<Id, OpportunityLineItem>{
      oliId => new OpportunityLineItem(
        Id = oliId,
        Product2Id = productId,
        OpportunityId = oppId
      )
    };

    List<OpportunityLineItem> filteredOliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(
        Id = oliId,
        Product2Id = productId,
        OpportunityId = oppId
      )
    };

    Map<Id, Set<Id>> oppIdToAfpProdIdMap = new Map<Id, Set<Id>>{
      oppId => new Set<Id>{ productId, productId2 }
    };

    //WHEN calling a method
    CommercialOppLineItemActions.preventDeletion(
      oldMap,
      filteredOliList,
      oppIdToAfpProdIdMap
    );

    //THEN it should throw an error
    Assert.areEqual(
      true,
      oldMap.get(oliId).hasErrors(),
      'should throw error while deletion OLI'
    );
  }
}
