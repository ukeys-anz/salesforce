/**
 * @author cruzb
 * @since May 2023
 * @description Credit Referral API repository for all Gearbox callouts
 * @group Repository
 */
@isTest
public with sharing class CreditAssessmentAPIRepositoryTest {
  @isTest
  static void testGetCreditAssessments() {
    Test.startTest();
    CreditAssessmentAPIRepository api = new CreditAssessmentAPIRepository();
    CreditReferralModel cr = api.getCreditAssessments(
      '9610b1d5-af42-d5a9-805d-9e5116ee6723',
      '12312'
    );
    Test.stopTest();

    // Verify response received contains fake values
    System.assertEquals(
      '9610b1d5-af42-d5a9-805d-9e5116ee6723',
      cr.assessments[0].id,
      'Current assessment id match was expected'
    );
  }
}
