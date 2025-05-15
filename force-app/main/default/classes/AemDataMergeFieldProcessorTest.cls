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
      String objBefore = AemServiceMock.AEM_CONTENT_DATA_SUCCESS;
      Assert.isFalse(
        objBefore.contains('1234567') == true,
        'Case Number should not be updated'
    );

       String obj = AemDataMergeFieldProcessor.replaceMergedFields(
      AemServiceMock.AEM_CONTENT_DATA_SUCCESS,
      FAKER_CASE_ID
    );

      Assert.isTrue(
        obj.contains('1234567') == true,
          'Case Number should be updated'
        );
    }

    private static SObject mockqueryMergeFieldsData(){
        Case caseRecord = (Case) TestUtil.setFields(
         new Case(
           Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
           AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
         ),
         new Map<String, Object>{ 'CaseNumber' => '1234567' }
       );
       return caseRecord;
       }
}
