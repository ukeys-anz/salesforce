/**
 * @author Hrushikesh
 * @since 10/2025
 * @description Test class for AssistedTransferTriggerHandler
 */
@isTest
public with sharing class AssistedTransferTriggerHandlerTest {
  public static final Id FAKER_CASE_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static List<Case> getOpenAssistedTransferCases() {
    List<Case> openCases = new List<Case>();
    Case record = new Case();
    record.RecordTypeId = RTCase.assistedTransfer;
    record.Status = 'Open';
    record.Id = FAKER_CASE_RECORD_ID;
    openCases.add(record);
    return openCases;
  }

  @IsTest
  private static void testIsValidRecordNegative() {
    Case caseRecord = new Case();
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord.RecordTypeId = RTCase.generalInquiry;

    Test.startTest();
    AssistedTransferTriggerHandler handler = new AssistedTransferTriggerHandler();
    Boolean isValidCase = handler.isValidRecord(caseRecord);
    Test.stopTest();

    Assert.isFalse(
      isValidCase,
      'Should return false for General enquiry record type of cases'
    );
  }

  @IsTest
  private static void testIsValidRecordPositive() {
    Case caseRecord = new Case();
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord.RecordTypeId = RTCase.assistedTransfer;

    Test.startTest();
    AssistedTransferTriggerHandler handler = new AssistedTransferTriggerHandler();
    Boolean isValidCase = handler.isValidRecord(caseRecord);
    Test.stopTest();

    Assert.isTrue(
      isValidCase,
      'Should return true for Assisted Transfer record type of cases'
    );
  }

  @isTest
  private static void testOnBeforeInsert() {
    List<Case> records = getOpenAssistedTransferCases();
    Test.startTest();
    AssistedTransferTriggerHandler handler = new AssistedTransferTriggerHandler();
    handler.records = records;
    handler.onBeforeInsert();
    Test.stopTest();
    Assert.isTrue(
      records[0].Subject == 'Assisted Transfer',
      'Case subject should be default value - Assisted Transfer while insert of case'
    );
  }
}
