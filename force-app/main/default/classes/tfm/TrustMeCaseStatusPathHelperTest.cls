/**
 * @author Shivraj Kadam
 * @since Apr 2025
 * @description Test Class for - TrustMeCaseStatusPathHelper
 */
@isTest
public with sharing class TrustMeCaseStatusPathHelperTest {
  private static Map<String, String> sfValueToTrustXValue = new Map<String, String>{
    'ID and Selfie Check Passed' => 'MANUAL_REVIEW_STATE_APPROVED',
    'Failed' => 'MANUAL_REVIEW_STATE_DENIED',
    'No Defect' => 'QUALITY_ASSURANCE_REVIEW_STATE_CLOSED_NO_DEFECT',
    'Defect Identified' => 'QUALITY_ASSURANCE_REVIEW_STATE_DEFECT_IDENTIFIED',
    'Fraud Suspected' => 'QUALITY_ASSURANCE_REVIEW_STATE_FRAUD_SUSPECTED',
    'Selfie fail - selfie image is clear, but not the same person' => 'MANUAL_REVIEW_DENIED_REASON_SELFIE_FACIAL_COMPARISON_FAILED',
    'Selfie fail - selfie image is not clear enough to match' => 'MANUAL_REVIEW_DENIED_REASON_SELFIE_UNUSABLE_FOR_MATCHING',
    'Selfie fail - document image is not clear enough to match' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_POOR_PHOTO_QUALITY',
    'Doc fail - suspected fraud, based on document' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_SUSPECTED_FRAUD',
    'Doc fail - document is expired' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_EXPIRED',
    'Doc fail - document is a picture of a picture' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_PICTURE_OF_PICTURE',
    'Doc fail - document is ineligible type' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_TYPE_NOT_ACCEPTABLE',
    'Doc fail - document details unreadable' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_UNREADABLE'
  };
  static Faker faker = new Faker('AU');
  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Case> caseRecord {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Origin = 'Web',
          Type = 'Other',
          Priority = 'Standard',
          IDR_NC_Is_Consent_Obtained__c = false,
          IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
          IDR_Product_Category__c = 'Not product related',
          Description = faker.randomString(10),
          Evaluation_Id__c = '1234',
          Subject = 'TrustMe Manual Review - Document',
          RecordTypeId = RTCase.trustMeManualReview,
          Status = 'Refer to Fraud',
          OnboardingVerificationFailedReason__c = 'Doc fail - suspected fraud, based on document',
          SecondaryVerificationFailedReason__c = 'Doc fail - suspected fraud, based on document'
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  static List<Case> caseRecordQA {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Origin = 'Web',
          Type = 'Other',
          Priority = 'Standard',
          IDR_NC_Is_Consent_Obtained__c = false,
          IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
          IDR_Product_Category__c = 'Not product related',
          Description = faker.randomString(10),
          Evaluation_Id__c = '1234',
          Subject = 'TrustMe Manual Review - Document',
          RecordTypeId = RTCase.trustMeQA,
          Status = 'ID and Selfie Check Passed',
          OnboardingVerificationFailedReason__c = 'Doc fail - suspected fraud, based on document',
          SecondaryVerificationFailedReason__c = 'Doc fail - suspected fraud, based on document',
          Fraud_Customer_Details__c = 'Yes',
          Fraud_MiddleNameCheck__c = 'Yes',
          Fraud_Selfie_Comparison_Match__c = 'Yes',
          Fraud_Address_Valid__c = 'Yes',
          Fraud_ID_Legible__c = 'Yes',
          Fraud_ID_Not_Picture__c = 'Yes',
          Fraud_Customer_Photo_Modified__c = 'Yes'
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  @isTest
  static void testMakeAPICallout() {
    Test.startTest();
    TrustMeCaseStatusPathHelper.makeAPICallout(caseRecord[0]);
    Test.stopTest();
    Assert.areEqual(
      'Refer to Fraud',
      caseRecord[0].Status,
      'Case update failed'
    );
  }

  @isTest
  static void testHandleCaseUpdate() {
    Lib_MockProvider.forType(DmlRepository.class)
      .mock('doUpdate', TestUtil.getMockSaveResult('{"success":true}'));
    Test.startTest();
    TrustMeCaseStatusPathHelper.handleCaseUpdate(
      caseRecord[0],
      'comments testing'
    );
    Test.stopTest();
    Assert.areEqual('Refer to Fraud', caseRecord[0].Status, 'Case not updated');
  }

  @isTest
  static void testGetFlag() {
    Test.startTest();
    Boolean getFlag = TrustMeCaseStatusPathHelper.getFlag('Yes');
    Test.stopTest();
    Assert.isTrue(getFlag, 'Flag set to true');
  }

  @isTest
  static void testPopulateChecksForQACase() {
    Test.startTest();
    TrustMeCaseUpdateModel.Checks checks = TrustMeCaseStatusPathHelper.populateChecksForQACase(
      caseRecordQA[0]
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      checks.customer_photo_id_legibility,
      'Flag not set to true in TrustMeCaseUpdateModel.checks'
    );
  }

  @isTest
  static void testUpdateOwnerandStatus() {
    Lib_MockProvider.forType(DmlRepository.class)
      .mock('doUpdate', TestUtil.getMockSaveResult('{"success":true}'));
    Test.startTest();
    TrustMeCaseStatusPathHelper.updateOwnerandStatus(
      caseRecord[0].Id,
      'Refer to Fraud'
    );
    Test.stopTest();
    Assert.areEqual('Refer to Fraud', caseRecord[0].Status, 'Case not updated');
  }
}
