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

    Case caseRecord = createCaseWithIssueTyes();
    caseRecord.Id = caseRecordId;

    Case caseRecord1 = createCaseWithIssueTyes();
    caseRecord1.IDR_Is_Hardship_Resolution_Letter_Sent__c = 'Test1';
    caseRecord1.IDR_Final_Letter_Outcome__c = 'Test2';
    caseRecord1.Id = caseRecordId;

    Case caseRecord2 = createCaseWithIssueTyes();
    caseRecord2.Id = caseRecordId;

    Test.startTest();

    Datetime dt = IDRCaseActionsHelper.populateHardshipUpdateDate(
      caseRecord1,
      caseRecord
    );

    Test.stopTest();

    System.assertNotEquals(null, dt, 'Date/time flag should be updated');
  }

  @isTest
  static void testHardshipUpdateDateTimeFlagNotUpdated() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case caseRecord = createCaseWithIssueTyes();
    caseRecord.Id = caseRecordId;

    Case caseRecord2 = createCaseWithIssueTyes();
    caseRecord2.Id = caseRecordId;

    Test.startTest();

    Datetime dt = IDRCaseActionsHelper.populateHardshipUpdateDate(
      caseRecord2,
      caseRecord
    );

    Test.stopTest();

    System.assertEquals(null, dt, 'Date/time flag should be null');
  }
  /**
   * @description Create Case record with different issue types
   * @return Case
   */

  private static Case createCaseWithIssueTyes() {
    Case caseRecord = new Case();
    caseRecord.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    caseRecord.IDR_Customer_Number__c = '1234567890';
    caseRecord.Status = 'Open';
    caseRecord.IDR_Account_Card_Policy_Number__c = 'N/A';
    caseRecord.isEscalated = false;
    caseRecord.IDR_Second_Issue__c = true;
    caseRecord.IDR_Third_Issue__c = true;
    caseRecord.Type = '4';
    caseRecord.IDR_Issue_Type_2__c = '9';
    caseRecord.IDR_Issue_Type_3__c = '17';
    caseRecord.IDR_Subsequent_Issue__c = '20';
    caseRecord.IDR_Subsequent_Issue_2__c = '57';
    caseRecord.IDR_Subsequent_Issue_3__c = '24';
    caseRecord.IDR_Product_Category__c = 'Asset finance';
    caseRecord.IDR_Account_Card_Policy_Number_2__c = 'N/A';
    caseRecord.IDR_Account_Card_Policy_Number_3__c = 'N/A';
    caseRecord.Description = 'Test';
    caseRecord.IDR_Complainant_Desired_Outcome__c = 'Test';
    return caseRecord;
  }

  @isTest
  static void testPopulateDateCaseAllocatedToCM() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    ID userRecordID = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID userRecordID2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID groupRecordID = Lib_FakeIdGenerator.getMockId(Group.SObjectType);
    Case caseRecord = createCaseWithIssueTyes();
    caseRecord.Id = caseRecordId;
    caseRecord.OwnerId = userRecordID;
    Case caseRecord1 = createCaseWithIssueTyes();
    caseRecord1.Id = caseRecordId;
    caseRecord1.OwnerId = userRecordID2;
    Case caseRecord2 = createCaseWithIssueTyes();
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
    Case caseRecord = createCaseWithIssueTyes();
    caseRecord.Id = caseRecordId;
    caseRecord.OwnerId = userRecordID;
    Case caseRecord1 = createCaseWithIssueTyes();
    caseRecord1.Id = caseRecordId;
    caseRecord1.OwnerId = userRecordID2;
    Case caseRecord2 = createCaseWithIssueTyes();
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
}
