/**
 * @author       : Advait Yermalkar
 * @since        : 22-05-2024
 * @description  : Test Class for CCRMA2ZReviewActionHelper Class
 **/
@isTest
private with sharing class CCRMA2ZReviewActionHelperTest {
  @isTest
  static void testAssociateReviewsToOpportunity() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(ccrmBaseUser) {
      Id mockOpportunityID = Lib_FakeIdGenerator.getMockId(
        Opportunity.getSObjectType()
      );
      Id mockLeadID = Lib_FakeIdGenerator.getMockId(Lead.getSObjectType());
      Id mockA2ZReviewID = Lib_FakeIdGenerator.getMockId(
        A_Z_Review__C.getSObjectType()
      );

      Map<Id, Id> mapOfOppIdwithLeadId = new Map<Id, Id>{
        mockLeadID => mockOpportunityID
      };
      List<A_Z_Review__c> listOfA2ZReviews = CCRMTestDataFactory.createCCRMA2ZReviews(
        1,
        ccrmBaseUser
      );
      listOfA2ZReviews[0].Lead__c = mockLeadID;
      listOfA2ZReviews[0].Id = mockA2ZReviewID;

      Test.startTest();
      CCRMA2ZReviewActionHelper.associateReviewsToOpportunity(
        listOfA2ZReviews,
        mapOfOppIdwithLeadId
      );
      Test.stopTest();
      system.assertEquals(
        mockOpportunityID,
        listOfA2ZReviews[0].Opportunity__c,
        'testSetCustomerByLeadMap failed -  incorrect Lookup Assignment'
      );
    }
  }

  @isTest
  static void testAssociateReviewsToOpportunityNegative() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      List<A_Z_Review__c> getAZReviewList = CCRMA2ZReviewActionHelper.associateReviewsToOpportunity(
        new List<A_Z_Review__c>(),
        new Map<Id, Id>()
      );
      Test.stopTest();
      System.assertEquals(
        0,
        getAZReviewList.size(),
        'A-Z Review associated with Opportunity successfully.'
      );
    }
  }

  @isTest
  static void testAssociateReviewsToCustomer() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(ccrmBaseUser) {
      Id mockAccountID = Lib_FakeIdGenerator.getMockId(
        Account.getSObjectType()
      );
      Id mockLeadID = Lib_FakeIdGenerator.getMockId(Lead.getSObjectType());
      Id mockA2ZReviewID = Lib_FakeIdGenerator.getMockId(
        A_Z_Review__C.getSObjectType()
      );

      Map<Id, Id> mapOfCustomerIdWithLeadId = new Map<Id, Id>{
        mockLeadID => mockAccountID
      };
      List<A_Z_Review__c> listOfA2ZReviews = CCRMTestDataFactory.createCCRMA2ZReviews(
        1,
        ccrmBaseUser
      );
      listOfA2ZReviews[0].Lead__c = mockLeadID;
      listOfA2ZReviews[0].Id = mockA2ZReviewID;

      Test.startTest();
      CCRMA2ZReviewActionHelper.associateReviewsToCustomer(
        listOfA2ZReviews,
        mapOfCustomerIdWithLeadId
      );
      Test.stopTest();

      system.assertEquals(
        mockAccountID,
        listOfA2ZReviews[0].customer__c,
        'testSetCustomerByLeadMap failed -  incorrect Lookup Assignment'
      );
    }
  }

  @isTest
  static void testAssociateReviewsToCustomerNegative() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      List<A_Z_Review__c> getAZReviewList = CCRMA2ZReviewActionHelper.associateReviewsToCustomer(
        new List<A_Z_Review__c>(),
        new Map<Id, Id>()
      );
      Test.stopTest();
      System.assertEquals(
        0,
        getAZReviewList.size(),
        'A-Z Review associated with Customer successfully.'
      );
    }
  }

  @isTest
  static void testGetAccountChangedLeadIds() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    Id mockLeadID = Lib_FakeIdGenerator.getMockId(Lead.getSObjectType());
    Id mockAccountID = Lib_FakeIdGenerator.getMockId(Account.getSObjectType());
    System.runAs(ccrmBaseUser) {
      Map<Id, Lead> oldLeadMap = new Map<Id, Lead>{
        mockLeadID => (new Lead(
          Id = mockLeadID,
          OwnerId = ccrmBaseUser.Id,
          recordTypeId = CCRMConstants.CCRM_LEAD_RT_ID
        ))
      };

      Map<Id, Lead> newLeadMap = new Map<Id, Lead>{
        mockLeadID => (new Lead(
          Id = mockLeadID,
          OwnerId = ccrmBaseUser.Id,
          recordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
          FinServ__RelatedAccount__c = mockAccountID
        ))
      };

      Test.startTest();
      Set<Id> leadIds = CCRMA2ZReviewActionHelper.getAccountChangedLeadIds(
        oldLeadMap,
        newLeadMap
      );
      Test.stopTest();

      System.assertEquals(1, leadIds.size(), 'Changed Customer not found.');
    }
  }
}
