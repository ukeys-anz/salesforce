/**
 * @author Naman Garg
 * @since Feb 2025
 * @description This is test class for CCRMLogAResponseController
 */

@isTest
public with sharing class CommercialLogAResponseControllerTest {
  static Lib_MockProvider logAResponseRepoMock;
  static void registerMocks() {
    logAResponseRepoMock = Lib_MockProvider.forType(
      LogAResponseControllerRepository.class
    );
  }

  @isTest
  static void contactInfoNotRequired() {
    registerMocks();

    //Given Lead Id and lead rec
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.sObjectType);
    Lead leadRec = new Lead(
      Id = leadId,
      RecordTypeId = RTLead.commercialLead,
      Primary_Contact_Method__c = 'Home Phone',
      Home_Phone__c = '+61412345678'
    );

    logAResponseRepoMock.mock('getLeadInfo', leadRec);

    //WHEN calling a method
    Test.startTest();
    Boolean contactInfoNotRequired = CCRMLogAResponseController.contactInfoNotRequired(
      leadId,
      'Customer Not Contacted'
    );
    Test.stopTest();

    //THEN it should return true
    Assert.isTrue(
      contactInfoNotRequired,
      'On lead contact info should not be required when Response status is Customer Not Contacted.'
    );
  }

  @isTest
  static void contactInfoNotRequiredFalse() {
    registerMocks();

    //Given Lead Id and lead rec
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.sObjectType);
    Lead leadRec = new Lead(Id = leadId, RecordTypeId = RTLead.commercialLead);

    logAResponseRepoMock.mock('getLeadInfo', leadRec);

    //WHEN calling a method
    Test.startTest();
    Boolean contactInfoNotRequired = CCRMLogAResponseController.contactInfoNotRequired(
      leadId,
      'Accepted'
    );
    Test.stopTest();

    //THEN it should return false
    Assert.isFalse(
      contactInfoNotRequired,
      'On lead contact info should required when Response status is other than Customer Not Contacted.'
    );
  }
}
