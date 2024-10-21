@isTest
private class CommercialAppFormTriggerTest {
  @isTest
  static void createAppFormTest() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    System.runAs(ccrmUser) {
      List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
        1,
        null
      );
      Test.startTest();
      List<ApplicationForm> appForms = CCRMTestDataFactory.createAppForm(
        1,
        opps[0].Id
      );
      insert appForms;
      Test.stopTest();
      Assert.areEqual(1, appForms.size(), 'Size is not 1');
    }
  }
}
