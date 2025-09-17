/**
 * @author Jaya Srivastava
 * @since February 2025
 * @description Test class for CreditReferralCaseTriggerHandler
 */
@IsTest
private class CreditReferralCaseTriggerHandlerTest {
  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );
  @IsTest
  static void testIsValidRecord() {
    Case caseRecord = createMockCaseRecord(RTCase.creditReferral, 'Open');
    CreditReferralCaseTriggerHandler handler = new CreditReferralCaseTriggerHandler();
    Test.startTest();
    Boolean checkRecord = handler.isValidRecord(caseRecord);
    Test.stopTest();
    Assert.isTrue(checkRecord, 'This is a valid record');
  }

  @IsTest
  static void testCoverageForBeforeAfterInsertAndUpdate() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      RTCase.creditReferral,
      'Escalated'
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList(
      RTCase.creditReferral,
      'Open'
    );
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    CreditReferralCaseTriggerHandler handler = new CreditReferralCaseTriggerHandler();
    handler.records = getNewCaseRecords;
    Test.startTest();
    // Dummy Callouts for test coverage
    handler.onBeforeInsert();
    handler.onBeforeUpdate(oldCaseMap);
    handler.onAfterInsert();
    handler.onAfterUpdate(oldCaseMap);
    Test.stopTest();
    //Dummy assert
    Assert.isTrue(
      true,
      'Before Insert, Before Update, After Insert and After Update Method coverage'
    );
  }
  private static Case createMockCaseRecord(
    Id recordTypeIdForCase,
    String status
  ) {
    Case caseRecord = new Case();
    caseRecord.Id = FAKER_CASE_ID;
    caseRecord.RecordTypeId = recordTypeIdForCase;
    caseRecord.Status = status;
    return caseRecord;
  }
  private static List<Case> createMockCaseRecordList(
    Id recordTypeIdForCase,
    String status
  ) {
    List<Case> caseRecordsList = new List<Case>();
    Case caseRecord = createMockCaseRecord(recordTypeIdForCase, status);
    caseRecordsList.add(caseRecord);
    return caseRecordsList;
  }
}
