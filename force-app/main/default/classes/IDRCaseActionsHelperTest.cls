/**
 * @author CMOS
 * @date 03/2024
 * @description Test class for {@link IDRCaseActionsHelper}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class IDRCaseActionsHelperTest {
  @isTest
  static void testHardshipUpdateDateTimeFlagUpdated() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case oldCase = IDRTestDataFactory.createCaseWithIssueTyes();
    oldCase.Id = caseRecordId;

    Case newCase = IDRTestDataFactory.createCaseWithIssueTyes();
    newCase.IDR_Is_Hardship_Resolution_Letter_Sent__c = 'Test1';
    newCase.IDR_Final_Letter_Outcome__c = 'Test2';
    newCase.Id = caseRecordId;

    Test.startTest();

    Datetime dt = IDRCaseActionsHelper.populateHardshipUpdateDate(
      newCase,
      oldCase
    );

    Test.stopTest();

    System.assertNotEquals(null, dt, 'Date/time flag should be updated');
  }

  @isTest
  static void testHardshipUpdateDateTimeFlagNotUpdated() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case oldCase = IDRTestDataFactory.createCaseWithIssueTyes();
    oldCase.Id = caseRecordId;

    Case newCase = IDRTestDataFactory.createCaseWithIssueTyes();
    newCase.Id = caseRecordId;

    Test.startTest();

    Datetime dt = IDRCaseActionsHelper.populateHardshipUpdateDate(
      newCase,
      oldCase
    );

    Test.stopTest();

    System.assertEquals(null, dt, 'Date/time flag should be null');
  }

  @isTest
  static void testPopulateDateCaseAllocatedToCM() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    ID userRecordID = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID userRecordID2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID groupRecordID = Lib_FakeIdGenerator.getMockId(Group.SObjectType);
    Case caseRecord = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord.Id = caseRecordId;
    caseRecord.OwnerId = userRecordID;
    Case caseRecord1 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord1.Id = caseRecordId;
    caseRecord1.OwnerId = userRecordID2;
    Case caseRecord2 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord2.Id = caseRecordId;
    caseRecord2.OwnerId = groupRecordID;
    Test.startTest();
    DateTime dt1 = IDRCaseActionsHelper.populateDateCaseAllocatedToCM(
      caseRecord1,
      caseRecord
    );
    DateTime dt2 = IDRCaseActionsHelper.populateDateCaseAllocatedToCM(
      caseRecord2,
      caseRecord
    );
    Test.stopTest();

    System.assertNotEquals(null, dt1, 'Date/time flag should be updated');
    System.assertEquals(
      null,
      dt2,
      'DateTime must be blank if user is updated to a group'
    );
  }
  @isTest
  static void testPopulateOldOwnerID() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    ID userRecordID = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID userRecordID2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID groupRecordID = Lib_FakeIdGenerator.getMockId(Group.SObjectType);
    Case caseRecord = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord.Id = caseRecordId;
    caseRecord.OwnerId = userRecordID;
    Case caseRecord1 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord1.Id = caseRecordId;
    caseRecord1.OwnerId = userRecordID2;
    Case caseRecord2 = IDRTestDataFactory.createCaseWithIssueTyes();
    caseRecord2.Id = caseRecordId;
    caseRecord2.OwnerId = groupRecordID;
    Test.startTest();
    ID pco = IDRCaseActionsHelper.populateOldOwnerID(caseRecord1, caseRecord);
    Test.stopTest();
    System.assertEquals(
      userRecordID,
      pco,
      'Previous Case Owner must be User Record 1'
    );
  }

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
