/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description  Model Test class AemDataModel
 */
@IsTest
public with sharing class AemDataModelTest {
  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  static Lib_MockProvider pushToAppRepoMock;

  static void registerMocks() {
    pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
  }

  @isTest
  static void testParse() {
    registerMocks();
    pushToAppRepoMock.mock('queryMergeFieldsData', mockqueryMergeFieldsData());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockNotificationConfiguration()
    );
    AemDataModel obj = AemDataModel.parse(
      AemServiceMock.AEM_CONTENT_DATA_SUCCESS,
      FAKER_CASE_ID
    );
    Assert.isTrue(
      obj.data.pushToAppList.items[0].id == 'get_in_touch_complaint',
      'Item Id should be get_in_touch_complaint'
    );

    Assert.isFalse(
      obj.data.pushToAppList.items[0].reference == 'Complaint Ref 1234567',
      'Case Number should be 1234567'
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

  private static Customer_Task_Configuration__c mockNotificationConfiguration() {
    Customer_Task_Configuration__c testNotificConfig = new Customer_Task_Configuration__c(
      AEM_Content_Id__c = 'get_in_touch_complaint',
      Applicable_Record_Types__c = 'Account Closure',
      Applicable_User_Role__c = 'Coach',
      SObject_Type__c = 'Case',
      Name = 'Get In Touch',
      Expire_After_Days__c = 12,
      Id = Lib_FakeIdGenerator.getMockId(
        Customer_Task_Configuration__c.SObjectType
      )
    );
    return testNotificConfig;
  }
}
