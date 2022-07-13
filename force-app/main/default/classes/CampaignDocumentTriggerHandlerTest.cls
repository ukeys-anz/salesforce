/**
 * @author Sahil
 * @since  09/2021
 * @description Test class for CampaignDocumentTriggerHandler Class.
 */
@IsTest
public with sharing class CampaignDocumentTriggerHandlerTest {
  // Public Declaration
  static User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();

  @IsTest
  static void populateUUIDTest() {
    Test.startTest();
    //WHEN new Campaign Documents are created
    System.runAs(ccrmUser) {
      CCRMTestDataFactory.createCampaignDocumentRecords(
        Integer.valueOf(Label.Test_Bulk_Size)
      );
    }
    Test.stopTest();

    //THEN UUID gets autopopulated.
    List<Campaign_Document__C> campaignDocuments = [
      SELECT Id, UUID__C
      FROM Campaign_Document__C
      WHERE UUID__c != ''
    ];
    System.assertEquals(
      campaignDocuments.size() >= Integer.valueOf(Label.Test_Bulk_Size),
      true,
      'UUID on Campaign Documents are not getting populated properly.'
    );
  }
}
