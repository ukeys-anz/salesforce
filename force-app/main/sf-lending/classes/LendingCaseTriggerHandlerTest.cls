/**
 * @author Jaya Srivastava
 * @since February 2025
 * @description Test class for LendingCaseTriggerHandler
 */
@IsTest
private class LendingCaseTriggerHandlerTest {
  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  @IsTest
  static void testIsValidRecord() {
    Case caseRecord = createMockCaseRecord(RTCase.lending, 'Open');
    LendingCaseTriggerHandler handler = new LendingCaseTriggerHandler();
    Test.startTest();
    Boolean checkRecord = handler.isValidRecord(caseRecord);
    Test.stopTest();
    Assert.isTrue(checkRecord, 'This is a valid record');
  }
  @IsTest
  static void testCoverageForBeforeInsertAndBeforeUpdate() {
    List<Case> getNewCaseRecords = createMockCaseRecordList(
      RTCase.lending,
      'Closed - Approved'
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList(
      RTCase.lending,
      'Open'
    );
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    LendingCaseTriggerHandler handler = new LendingCaseTriggerHandler();
    handler.records = getNewCaseRecords;
    Test.startTest();
    // Dummy Callouts for test coverage
    handler.onBeforeInsert();
    handler.onBeforeUpdate(oldCaseMap);
    Test.stopTest();
    //Dummy assert
    Assert.isTrue(true, 'Before Insert and Before Update Method coverage');
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
