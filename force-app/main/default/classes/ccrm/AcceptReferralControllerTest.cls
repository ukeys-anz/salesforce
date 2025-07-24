/**
 * @author Ayushi Gupta
 * @since  07/2025
 * @description Test class of AcceptReferralController class
 */
@isTest
private class AcceptReferralControllerTest {
  static Lib_MockProvider acceptReferralRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider leadMockProvider;

  static void registerMocks() {
    acceptReferralRepoMock = Lib_MockProvider.forType(
      AcceptReferralRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    leadMockProvider = Lib_MockProvider.forType(LeadActionsRepository.class);
  }

  @isTest
  static void checkCampaignMemberTestWithMember() {
    registerMocks();
    Id memberId = Lib_FakeIdGenerator.getMockId(CampaignMember.SObjectType);
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    CampaignMember member = new CampaignMember(Id = memberId, LeadId = leadId);
    acceptReferralRepoMock.mock(
      'getCampaignMember',
      new List<CampaignMember>{ member }
    );
    Test.startTest();
    AcceptReferralController.checkCampaignMember(leadId);
    Test.stopTest();
    Assert.isNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have not been invoked'
    );
  }

  @isTest
  static void checkCampaignMemberTestWithNoMember() {
    registerMocks();
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    acceptReferralRepoMock.mock(
      'getCampaignMember',
      new List<CampaignMember>()
    );
    acceptReferralRepoMock.mock(
      'getLeadRecord',
      new Lead(Id = leadId, Campaign_Code__c = '')
    );
    leadMockProvider.mock(
      'getCampaignRecords',
      new List<Campaign>{
        new Campaign(Code__c = 'IKCMP-1670', Description = 'New Campaign')
      }
    );
    Test.startTest();
    AcceptReferralController.checkCampaignMember(leadId);
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );
  }
}
