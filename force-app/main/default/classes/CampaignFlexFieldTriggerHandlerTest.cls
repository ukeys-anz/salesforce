/**
 * @author Sahil
 * @since  09/2021
 * @description Test class for CampaignFlexFieldTriggerHandler Class.
 */
@IsTest
public with sharing class CampaignFlexFieldTriggerHandlerTest {
  // Public Declaration
  static User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();

  @IsTest
  static void populateUUIDTest() {
    Test.startTest();
    //WHEN new Campaign Flex Field are created
    System.runAs(ccrmUser) {
      CCRMTestDataFactory.createCampaignFlexFieldRecords(
        Integer.valueOf(Label.Test_Bulk_Size)
      );
    }
    Test.stopTest();

    //THEN UUID gets autopopulated.
    List<Campaign_Flex_Field__c> campaignFlexFields = [
      SELECT Id, UUID__C
      FROM Campaign_Flex_Field__c
      WHERE UUID__c != ''
    ];
    System.assertEquals(
      campaignFlexFields.size() >= Integer.valueOf(Label.Test_Bulk_Size),
      true,
      'UUID on Campaign Flex Fields are not getting populated properly.'
    );
  }
}
