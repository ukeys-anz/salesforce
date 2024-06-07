/**
 * @author       : Advait Yermalkar
 * @since        : 05/2024
 * @description  : unit testing class for CCRMA2ZReviewActions
 **/
@isTest
private class CCRMA2ZReviewActionsTest {
  @isTest
  static void testPerformRedactionTest() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(ccrmBaseUser) {
      List<A_Z_Review__c> lstReviews = CCRMTestDataFactory.createCCRMA2ZReviews(
        1,
        ccrmBaseUser
      );
      lstReviews[0].Name = 'Test 1234123412341234';

      String expectedResult = 'Test ************1234';

      Test.startTest();
      CCRMA2ZReviewActions.performRedaction(lstReviews);
      Test.stopTest();

      A_Z_Review__c actualResultReviewInstance = lstReviews[0];

      System.assertEquals(
        expectedResult,
        actualResultReviewInstance.Name,
        'Redaction is Not Completed'
      );
      System.assertEquals(
        expectedResult,
        actualResultReviewInstance.Business_Details__c,
        'Redaction is Not Completed'
      );
      System.assertEquals(
        expectedResult,
        actualResultReviewInstance.Personal_Banking__c,
        'Redaction is Not Completed'
      );
      System.assertEquals(
        expectedResult,
        actualResultReviewInstance.Transaction_Banking__c,
        'Redaction is Not Completed'
      );
      System.assertEquals(
        expectedResult,
        actualResultReviewInstance.Borrowing_OFI_Relationship__c,
        'Redaction is Not Completed'
      );
    }
  }

  @isTest
  public static void testCompletedDateOnUpdate() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    String azId = (String) Lib_FakeIdGenerator.getMockId(
      A_Z_Review__c.getSobjectType()
    );

    System.runAs(ccrmUser) {
      Map<Id, A_Z_Review__c> oldRecordMap = new Map<Id, A_Z_Review__c>{
        azId => new A_Z_Review__c(
          Id = azId,
          Name = 'A-Z Review Record',
          Status__c = 'In Progress',
          RecordTypeId = CCRMConstants.AZ_REVIEW_RT_ID,
          OwnerId = ccrmUser.Id
        )
      };

      List<A_Z_Review__c> azReviewList = new List<A_Z_Review__c>{
        new A_Z_Review__c(
          Id = azId,
          Name = 'A-Z Review Record',
          Status__c = 'Completed',
          RecordTypeId = CCRMConstants.AZ_REVIEW_RT_ID,
          OwnerId = ccrmUser.Id
        )
      };

      Test.startTest();
      CCRMA2ZReviewActions.updateCompletedDate(azReviewList, oldRecordMap);
      Test.stopTest();

      System.assertEquals(
        azReviewList[0].Completed_Date__c,
        Date.Today(),
        'Completed date not updated when status changes'
      );
    }
  }

  @isTest
  static void testIntegration() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(ccrmBaseUser) {
      Opportunity oppRec = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser
      )[0];

      Lead objLead = CCRMTestDataFactory.createLeadRecords(
        1,
        ccrmBaseUser,
        false
      )[0];
      objLead.FinServ__RelatedAccount__c = oppRec.AccountId;
      objLead.New_to_Bank__c = 'No';
      insert objLead;

      List<A_Z_Review__c> azReviewList = CCRMTestDataFactory.createCCRMA2ZReviews(
        2,
        ccrmBaseUser
      );
      azReviewList[0].Status__c = 'Completed';
      azReviewList[0].Opportunity__c = oppRec.id;

      azReviewList[1].Status__c = 'Completed';
      azReviewList[1].Lead__c = objLead.Id;

      Test.startTest();
      insert azReviewList;
      Test.stopTest();

      List<A_Z_Review__c> getAZReview = new List<A_Z_Review__c>(
        [
          SELECT Id, Completed_Date__c, Customer__c
          FROM A_Z_Review__c
          WHERE Id IN :azReviewList
        ]
      );
      System.assertEquals(
        2,
        getAZReview.size(),
        'Customer not associated on A-Z Review properly'
      );
      System.assertEquals(
        Date.Today(),
        getAZReview[0].Completed_Date__c,
        'Completed date not updated when status changes on Insert.'
      );
    }
  }
}
