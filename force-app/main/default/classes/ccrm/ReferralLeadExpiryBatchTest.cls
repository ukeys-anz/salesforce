/**
 * @author Ayushi Gupta
 * @since  03/2025
 * @group CCRM (Commercial CRM)
 * @description ReferralLeadExpiryBatchTest is Test class to test ReferralLeadExpiryBatch.
 */

@isTest
public class ReferralLeadExpiryBatchTest {
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
  }
  @isTest
  static void testExecute() {
    registerMocks();
    List<Lead> leads = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.getSobjectType()),
        LastName = 'Test Lead',
        RecordTypeId = RTLead.referralLead,
        Expiry_Date__c = System.today() - 1,
        Referral_Status__c = 'New'
      )
    };
    Test.startTest();
    ReferralLeadExpiryBatch.execute(null, leads);
    Test.stopTest();

    List<Lead> updatedLeads = (List<Lead>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.areEqual(1, updatedLeads.size(), 'No leads updated.');
    Assert.areEqual(
      'Cancelled',
      updatedLeads[0].Referral_Status__c,
      'Referral status is not updated.'
    );
  }

  @isTest
  static void testExecuteWithNoLeads() {
    registerMocks();
    Test.startTest();
    ReferralLeadExpiryBatch.execute(null, new List<Lead>{});
    Test.stopTest();

    Assert.isTrue(
      dmlRepoMock.getHistories('updateRecords').isEmpty(),
      'updateRecords was executed'
    );
  }
}
