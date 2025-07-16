/**
 * @author       : Naman Garg
 * @since        : March 2025
 * @description  : ReferralLeadExpiryReminderBatchTest is the test class for ReferralLeadExpiryReminderBatch
 **/
@isTest
public class ReferralLeadExpiryReminderBatchTest {
  @isTest
  static void executeTest() {
    //GIVEN list of referral records
    List<Lead> referralLeadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        ),
        Referral_Status__c = 'In Progress',
        RecordTypeId = RTLead.referralLead,
        Expiry_Date__c = Date.Today().addDays(2)
      )
    };
    Exception ex;

    //WHEN calling a method
    Test.startTest();
    try {
      new ReferralLeadExpiryReminderBatch().execute(null, referralLeadList);
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN assert should return null
    Assert.isNull(ex, 'Exception should not be thrown');
  }
}
