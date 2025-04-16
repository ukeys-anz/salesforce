/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description  Test class for AemDataMergeFieldProcessorTest
 */
@IsTest
public with sharing class AemDataMergeFieldProcessorTest {
  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  static void registerMocks() {
    Lib_MockProvider.forType(PushToAppRepository.class)
      .mock('queryMergeFieldsData', mockqueryMergeFieldsData());
  }

  @isTest
  static void testReplaceMergedFields() {
    registerMocks();
    String objBefore = AemServiceTest.mockAemData;
    Assert.isFalse(
      objBefore.contains('1234567') == true,
      'Case Number should not be updated'
    );

    String obj = AemDataMergeFieldProcessor.replaceMergedFields(
      AemServiceTest.mockAemData,
      FAKER_CASE_ID
    );

    Assert.isTrue(
      obj.contains('1234567') == true,
      'Case Number should be updated'
    );
  }

  @isTest
  static void testReplaceFieldsInJson() {
    List<sObject> recordsFromDatabase = mockqueryMergeFieldsData();
    String replacedMergedFields = AemDataMergeFieldProcessor.replaceFieldsInJson(
      AemServiceTest.mockAemData,
      recordsFromDatabase
    );

    Assert.isTrue(
      replacedMergedFields.contains('1234567') == true,
      'Case Number should be updated'
    );
  }

  private static List<sObject> mockqueryMergeFieldsData() {
    List<SObject> listofSObject = new List<SObject>();

    Case caseRecord = (Case) TestUtil.setFields(
      new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
      ),
      new Map<String, Object>{ 'CaseNumber' => '1234567' }
    );

    listofSObject.add(caseRecord);
    return listofSObject;
  }
}
