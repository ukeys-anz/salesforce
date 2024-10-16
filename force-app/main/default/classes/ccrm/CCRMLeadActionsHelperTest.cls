/**
 * @author Naman Garg
 * @since  30/2023
 * @description This class is to provide generic test data setups CCRM test classes.
 * @group Utils
 */

@isTest
private class CCRMLeadActionsHelperTest {
  static Lib_MockProvider leadRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    leadRepoMock = Lib_MockProvider.forType(CCRMLeadRepository.class);
  }

  @TestSetup
  static void setup() {
    User ccrmUserBB = CCRMTestDataFactory.createCCRMRelManagerUser();
    update ccrmUserBB;
    User ccrmUserSBB = CCRMTestDataFactory.createCCRMSmallBusinessBankingUser();
    update ccrmUserSBB;

    System.runAs(ccrmUserBB) {
      CCRMTestDataFactory.createLeadRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        ccrmUserBB
      );
    }
  }

  @isTest
  static void testvalidateLeadTypeForDeletion() {
    Lib_MockProvider.forType(CCRMLeadRepository.class)
      .mock(
        'getUserProfileId',
        CommonUtil.getProfileByName(CCRMConstants.CCRM_PROFILE_NAME).Id
      );
    String mockLeadID = (String) Lib_FakeIdGenerator.getMockId(
      Lead.getSObjectType()
    );
    List<lead> leadList = new List<Lead>{
      new Lead(Id = mockLeadID, RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID)
    };
    Test.startTest();
    CCRMLeadActionsHelper.validateLeadTypeForDeletion(leadList);
    Test.stopTest();
    Assert.isTrue(
      leadList[0].hasErrors(),
      'Lead record should have an error to prevent deletion.'
    );
  }

  @isTest
  static void testisCCRMUser() {
    Lib_MockProvider.forType(CCRMLeadRepository.class)
      .mock(
        'getUserProfileId',
        CommonUtil.getProfileByName(CCRMConstants.CCRM_PROFILE_NAME).Id
      );
    Test.startTest();
    boolean checkccrm = CCRMLeadActionsHelper.isCCRMUser();
    Test.stopTest();
    Assert.areEqual(true, checkccrm, 'User should be CCRM User.');
  }
}
