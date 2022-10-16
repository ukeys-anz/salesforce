/**
 * @description       : Test class for Quality Assesment task actions class
 * @group             :
 * @last modified on  : 09-30-2022
 **/
@isTest
public class QualityAssessmentTaskActionsTest {
  //mehtod to test positive case (return true) when calling isBreachedQA method
  @isTest
  private static void testIsBreachedQAPositive() {
    Test.startTest();

    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
      Status__c = QualityAssessmentActions.STATUS_REFERRED,
      Sub_Status__c = QualityAssessmentActions.SUB_STATUS_COMPLIANCE_REVIEW,
      Reference__c = 'TestRef'
    );

    insert qaRecord;

    Boolean isBreachedQA = QualityAssessmentTaskActions.isBreachedQA(
      qaRecord,
      null
    );

    Test.stopTest();

    System.assert(
      isBreachedQA,
      'Passing breached Quality Assessment record into testIsBreachedQAPositive method should return true.'
    );
  }

  //mehtod to test negative case (return false) when calling isBreachedQA method
  @isTest
  private static void testIsBreachedQANegative() {
    Test.startTest();

    Quality_Assessment__c qaRecord = new Quality_Assessment__c(
      RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID,
      Status__c = 'Unassigned',
      Reference__c = 'TestRef'
    );

    insert qaRecord;

    Boolean isBreachedQA = QualityAssessmentTaskActions.isBreachedQA(
      qaRecord,
      null
    );

    Test.stopTest();

    System.assert(
      !isBreachedQA,
      'Passing not breached Quality Assessment record into testIsBreachedQAPositive method should return false.'
    );
  }
}
