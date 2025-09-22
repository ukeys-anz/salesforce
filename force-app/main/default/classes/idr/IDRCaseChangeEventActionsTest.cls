/**
 * @description Test class to cover tests for {@link IDRCaseChangeEventActions}
 * @author Olivier Saier
 * @since 06/2021
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private class IDRCaseChangeEventActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }
  private static EventBus.ChangeEventHeader getHeader(
    String dmlType,
    String recordId,
    List<String> fields
  ) {
    EventBus.ChangeEventHeader header = new EventBus.ChangeEventHeader();
    header.entityName = 'Case';
    header.changeType = dmlType;
    header.changeOrigin = 'com/salesforce/api/soap/64.0';
    header.transactionKey = String.valueOf(new Faker('0-9').randomInteger(9));
    header.sequenceNumber = 1;
    header.commitTimestamp = System.now().getTime();
    header.commitUser = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    header.commitnumber = 1082985383811L;
    header.nulledfields = new List<String>();
    header.recordIds = new List<String>{ recordId };
    header.diffFields = new List<String>();
    header.changedFields = fields;
    return header;
  }

  private static CaseChangeEvent getEvent(String value) {
    return (CaseChangeEvent) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{ 'IDR_Restriction_Level__c' => value }
      ),
      CaseChangeEvent.class
    );
  }

  @isTest
  static void testUpdateCaseRestrictionsForRestrictedStatus() {
    registerMocks();
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + caseId + '","errors":[]}'
        )
      }
    );
    CaseChangeEvent event = getEvent('Restricted Case');
    event.ChangeEventHeader = getHeader(
      'UPDATE',
      caseId,
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    IDRCaseChangeEventActions.updateCaseRestrictions(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    List<Case> caseRecords = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.isTrue(
      caseRecords[0].IDR_Is_Restricted__c,
      'Case Should be restricted'
    );
  }
  @isTest
  static void testUpdateCaseRestrictionsForNoRestrictedInsert() {
    registerMocks();
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + caseId + '","errors":[]}'
        )
      }
    );
    CaseChangeEvent event = getEvent('No Restriction');
    event.ChangeEventHeader = getHeader(
      'CREATE',
      caseId,
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    IDRCaseChangeEventActions.updateCaseRestrictions(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    List<Case> caseRecords = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.isTrue(caseRecords.isEmpty(), 'Case Should not be updated');
  }
  @isTest
  static void testUpdateCaseRestrictionsForNoRestrictedUpdate() {
    registerMocks();
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(
          '{"success":true,"id":"' + caseId + '","errors":[]}'
        )
      }
    );
    CaseChangeEvent event = getEvent('No Restriction');
    event.ChangeEventHeader = getHeader(
      'UPDATE',
      caseId,
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    IDRCaseChangeEventActions.updateCaseRestrictions(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    List<Case> caseRecords = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.isFalse(
      caseRecords[0].IDR_Is_Restricted__c,
      'Case Should be restricted'
    );
  }
  @isTest
  static void testValidEventsWithNull() {
    CaseChangeEvent event = getEvent(null);
    event.ChangeEventHeader = getHeader(
      'UPDATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    List<CaseChangeEvent> results = IDRCaseChangeEventActions.validEvents(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.isTrue(
      results.isEmpty(),
      'No Case Event records should be returned as IDR_Restriction_Level__c field value is null'
    );
  }
  @isTest
  static void testValidEventsForNotRestrictionField() {
    CaseChangeEvent event = getEvent('Restricted Case');
    event.ChangeEventHeader = getHeader(
      'UPDATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'Status' }
    );
    Test.startTest();
    List<CaseChangeEvent> results = IDRCaseChangeEventActions.validEvents(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.isTrue(
      results.isEmpty(),
      'No Case Event records should be returned as only Status field change'
    );
  }
  @isTest
  static void testValidEventsForRestrictedStatus() {
    CaseChangeEvent event = getEvent('Restricted Case');
    event.ChangeEventHeader = getHeader(
      'CREATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    List<CaseChangeEvent> results = IDRCaseChangeEventActions.validEvents(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      1,
      'Valid Event as IDR_Restriction_Level__c field is changed with CREATE dml'
    );
  }
  @isTest
  static void testGetRestrictedCasesWithStatusAsRestricted() {
    CaseChangeEvent event = getEvent('Restricted Case');
    event.ChangeEventHeader = getHeader(
      'CREATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    List<Case> results = IDRCaseChangeEventActions.getRestrictedCases(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.isFalse(
      results.isEmpty(),
      'ValidEvents method should return a restricted case'
    );
  }
  @isTest
  static void testGetRestrictedCasesWithStatusAsNonRestricted() {
    CaseChangeEvent event = getEvent('No Restriction');
    event.ChangeEventHeader = getHeader(
      'CREATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    List<Case> results = IDRCaseChangeEventActions.getRestrictedCases(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.isTrue(
      results.isEmpty(),
      'ValidEvents method should return an empty list of cases'
    );
  }
  @isTest
  static void testGetNonRestrictedCasesWithStatusAsNonRestricted() {
    CaseChangeEvent event = getEvent('No Restriction');
    event.ChangeEventHeader = getHeader(
      'CREATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    List<Case> results = IDRCaseChangeEventActions.getNonRestrictedCases(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.isFalse(
      results.isEmpty(),
      'ValidEvents method should return a non-restricted case'
    );
  }
  @isTest
  static void testGetNonRestrictedCasesWithStatusAsRestricted() {
    CaseChangeEvent event = getEvent('Restricted Case');
    event.ChangeEventHeader = getHeader(
      'CREATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    List<Case> results = IDRCaseChangeEventActions.getNonRestrictedCases(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.isTrue(
      results.isEmpty(),
      'ValidEvents method should return a empty list of cases'
    );
  }
}
