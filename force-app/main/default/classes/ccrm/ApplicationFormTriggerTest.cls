/**
 * @author Ali Mujtaba | Salesforce | 02-11-2025
 * @since October 2025
 * @description Test class for ApplicationFormActions actions
 */
@isTest
private class ApplicationFormTriggerTest {
  @isTest
  static void createAppFormTest() {
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
