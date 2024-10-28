@isTest
public class CommercialAppFormProdTriggerTest {
  @isTest
  static void createCommercialAppFormProductTest() {
    List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
      1,
      null
    );
    List<ApplicationForm> appForms = CCRMTestDataFactory.createAppForm(
      1,
      opps[0].Id
    );
    insert appForms;
    Test.startTest();
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appForms[0].Id,
      CCRMConstants.OPP_IDENTIFIED
    );
    insert afpList;
    Test.stopTest();
    Assert.areEqual(afpList.size(), 1, 'Records created');
  }
}
