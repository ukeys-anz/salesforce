/**
 * @author Emmanuel Yap
 * @since 01/2022
 * @description OpportunityTriggerHandlerTest is the test class for Opportunity Trigger and Opportunity Trigger Handler Class.
 */
@isTest
private class OpportunityTriggerHandlerTest {
  static User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();

  @testSetup
  static void setup() {
    //CREATE Test Opportunity Records
    System.runAs(ccrmUser) {
      List<Opportunity> opps = CCRMTestDataFactory.createOpportunityRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        ccrmUser
      );
      System.assertEquals(
        opps.size(),
        Integer.valueOf(Label.Test_Bulk_Size),
        'Opportunity list size should be as expected.'
      );
    }
  }
}
