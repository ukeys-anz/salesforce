/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Test class for @link CommercialOpportunityAPIRepository
 **/
@isTest
private class CommercialOpportunityAPIRepositoryTest {
  static final Faker FAKER = new Faker('AU');
  static Opportunity oppRecord = new Opportunity(
    Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
    Name = FAKER.randomString(10)
  );
  static List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>{
    new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      OpportunityId = oppRecord.Id,
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType)
    )
  };
  static List<FinServ__AccountAccountRelation__c> relatedEntities = new List<FinServ__AccountAccountRelation__c>();

  @isTest
  static void publishCaseToPegaSuccess() {
    HttpCalloutResponse success = new HttpCalloutResponse();
    success.successful = true;
    success.statusCode = 200;
    success.body = '{"id" : "XYZ-1001", "nextPageID":"Confirm", "pxObjClass": "Pega-API-CaseManagement-Case", "errors": []}';
    Lib_MockProvider.forType(PegaCaseService.class).mock('createCase', success);
    Exception ex;
    try {
      new CommercialOpportunityAPIRepository()
        .publishCaseToPega(oppRecord, oppLineItems, relatedEntities);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @isTest
  static void publishCaseToPegaError() {
    HttpCalloutResponse error = new HttpCalloutResponse();
    error.successful = false;
    error.statusCode = 500;
    error.error = new CalloutException('Error');
    Lib_MockProvider.forType(PegaCaseService.class).mock('createCase', error);
    Exception ex;
    try {
      new CommercialOpportunityAPIRepository()
        .publishCaseToPega(oppRecord, oppLineItems, relatedEntities);
    } catch (Exception e) {
      ex = e;
    }

    Assert.isTrue(
      ex instanceof RepositoryBase.ServerErrorException,
      'Exception should be thrown.'
    );
  }
}
