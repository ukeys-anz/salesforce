/**
 * @author CMOS
 * @date 03/2024
 * @description Test class for {@link IDRCaseActionsHelper}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class IDRCaseActionsHelperTest {
  @isTest
  static void testpopulateAfcaRegistrationResponseDate() {
    Id caseRecordId1 = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Id caseRecordId2 = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case caseRecord1 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord1.Id = caseRecordId1;
    caseRecord1.IDR_AFCA_Registration_Response_Provided__c = false;
    Case caseRecord2 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord2.Id = caseRecordId2;
    caseRecord2.IDR_AFCA_Registration_Response_Provided__c = true;
    Test.startTest();
    DateTime responseProvided = IDRCaseActionsHelper.populateAfcaRegistrationResponseDate(
      caseRecord1,
      caseRecord2
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      responseProvided,
      'Date/time flag should be updated'
    );
  }

  @isTest
  static void testAfcaDueDateNotPopulate() {
    Id caseRecordId1 = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Id caseRecordId2 = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case caseRecord1 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord1.Id = caseRecordId1;
    caseRecord1.IDR_AFCA_Registration_Response_Provided__c = false;
    Case caseRecord2 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord2.Id = caseRecordId2;
    caseRecord2.IDR_AFCA_Registration_Response_Provided__c = false;
    Test.startTest();
    DateTime responseProvided = IDRCaseActionsHelper.populateAfcaRegistrationResponseDate(
      caseRecord1,
      caseRecord2
    );
    Test.stopTest();
    System.assertEquals(
      null,
      responseProvided,
      'Date/time flag should be null'
    );
  }
  @isTest
  static void testAfcaDueDatewithResponseUncheckedPopulate() {
    Id caseRecordId1 = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Id caseRecordId2 = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case caseRecord1 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord1.Id = caseRecordId1;
    caseRecord1.IDR_AFCA_Registration_Response_Provided__c = true;
    Case caseRecord2 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord2.Id = caseRecordId2;
    caseRecord2.IDR_AFCA_Registration_Response_Provided__c = false;
    Test.startTest();
    DateTime responseProvided = IDRCaseActionsHelper.populateAfcaRegistrationResponseDate(
      caseRecord1,
      caseRecord2
    );
    Test.stopTest();
    System.assertEquals(
      null,
      responseProvided,
      'Date/time flag should be null'
    );
  }
}
