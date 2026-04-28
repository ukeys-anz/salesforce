/**
 * @author       : Kritika Sharma
 * @since        : Feb 2026
 * @description  : Test class for ExportFailedReferralsController
 **/
@isTest
public with sharing class ExportFailedReferralsControllerTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider leadRepoMock;

  static void registerMocks() {
    // Just call forType; the library handles the rest of the registration internally
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    leadRepoMock = Lib_MockProvider.forType(
      CommercialReferralLeadRepository.class
    );
  }

  @isTest
  static void retryReferralExportFailedTest() {
    registerMocks();
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);

    Lead mockLead = new Lead(
      Id = leadId,
      Referral_Status__c = ExportFailedReferralsController.STATUS_EXPORT_FAILED
    );
    leadRepoMock.mock('getLeadsById', new List<Lead>{ mockLead });

    dmlRepoMock.mockException('doUpdate', new DmLException('DML Failed'));

    Boolean exceptionThrown = false;
    Test.startTest();
    try {
      ExportFailedReferralsController.retryReferralExport(leadId);
    } catch (AuraHandledException e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    Assert.isTrue(
      exceptionThrown,
      'Should throw AuraHandledException on DML failure'
    );
  }
}
