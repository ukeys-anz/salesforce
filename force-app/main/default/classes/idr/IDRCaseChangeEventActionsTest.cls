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
    Assert.areEqual(1, caseRecords.size(), '1 case record updated');
  }
  @isTest
  static void testUpdateCaseRestrictionsForNoRestrictedStatus() {
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
    Assert.areEqual(1, caseRecords.size(), '1 case record updated');
  }

  @isTest
  static void testgetChangeCaseIdsForRestrictionStatusNull() {
    CaseChangeEvent event = getEvent(null);
    event.ChangeEventHeader = getHeader(
      'CREATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    Map<String, List<Case>> result = IDRCaseChangeEventActions.getChangeCaseIds(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      result.get('nonRestricted').isEmpty(),
      'No Case records should be returned for IDR_Restriction_Level__c field value as null and only IDR_Restriction_Level__c field change'
    );
    Assert.areEqual(
      true,
      result.get('restricted').isEmpty(),
      'No Case records should be returned for IDR_Restriction_Level__c field value as null and only IDR_Restriction_Level__c field change'
    );
  }
  @isTest
  static void testgetChangeCaseIdsForNonRestrictionField() {
    CaseChangeEvent event = getEvent(null);
    event.ChangeEventHeader = getHeader(
      'UPDATE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'Status' }
    );
    Test.startTest();
    Map<String, List<Case>> result = IDRCaseChangeEventActions.getChangeCaseIds(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      result.get('nonRestricted').isEmpty(),
      'No Case records should be returned for IDR_Restriction_Level__c field value as null and only Status field change'
    );
    Assert.areEqual(
      true,
      result.get('restricted').isEmpty(),
      'No Case records should be returned for IDR_Restriction_Level__c field value as null and only Status field change'
    );
  }

  @isTest
  static void testgetChangeCaseIdsForDeleteDml() {
    CaseChangeEvent event = getEvent('No Restriction');
    event.ChangeEventHeader = getHeader(
      'DELETE',
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      new List<String>{ 'IDR_Restriction_Level__c' }
    );
    Test.startTest();
    Map<String, List<Case>> result = IDRCaseChangeEventActions.getChangeCaseIds(
      new List<CaseChangeEvent>{ event }
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      result.get('nonRestricted').isEmpty(),
      'No Case records should be returned for DELETE DML operation'
    );
    Assert.areEqual(
      true,
      result.get('restricted').isEmpty(),
      'No Case records should be returned for DELETE DML operation'
    );
  }
}
