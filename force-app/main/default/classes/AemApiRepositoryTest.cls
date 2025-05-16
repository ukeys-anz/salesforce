/**
 * @author Kopal Goswami
 * @since October 2024
 * @description Test class for AemApiRepository Apex class
 * @group Repository
 */
@IsTest
public with sharing class AemApiRepositoryTest {
        private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
      Case.getSObjectType()
    );

    static Lib_MockProvider pushToAppRepoMock;
    static Lib_MockProvider userMock;
    static void registerMocks() {
      pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
    }

  @isTest
  static void testGetAemContentDataForNotificationValidResponse() {
    registerMocks();
    pushToAppRepoMock.mock('queryMergeFieldsData', mockqueryMergeFieldsData());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockNotificationConfiguration()
    );
  
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = true;
    response.statusCode = 200;
    response.body = AemServiceMock.AEM_CONTENT_DATA_SUCCESS;
    Lib_MockProvider.forType(AemService.class)
      .mock('getAemContentData', response);
    Exception ex = null;
    try {
      //AemApiRepository aemRepo = new AemApiRepository();
      AemApiRepository.getAemContentDataForNotification(
        'get_in_touch_complaint',
        FAKER_CASE_ID
      );
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testGetAemContentDataForNotificationServerError() {
    registerMocks();
    pushToAppRepoMock.mock('queryMergeFieldsData', mockqueryMergeFieldsData());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockNotificationConfiguration()
    );

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 500;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(AemService.class)
      .mock('getAemContentData', response);
    Exception ex;
    try {
     // AemApiRepository aemRepo = new AemApiRepository();
     AemApiRepository.getAemContentDataForNotification(
        'get_in_touch_complaint',
        FAKER_CASE_ID
      );
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof AemApiRepository.ServerErrorException,
      'Server Exception should be thrown.'
    );
  }

  @IsTest
  static void testGetAemContentDataForNotificationAccessError() {
    registerMocks();
    pushToAppRepoMock.mock('queryMergeFieldsData', mockqueryMergeFieldsData());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockNotificationConfiguration()
    );

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 401;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(AemService.class)
      .mock('getAemContentData', response);
    Exception ex;
    try {
     // AemApiRepository aemRepo = new AemApiRepository();
     AemApiRepository.getAemContentDataForNotification(
        'get_in_touch_complaint',
        FAKER_CASE_ID
      );
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof AemApiRepository.AccessErrorException,
      'Access Exception should be thrown.'
    );
  }

  @IsTest
  static void testGetAemContentDataForNotificationUnhandledError() {
    registerMocks();
    pushToAppRepoMock.mock('queryMergeFieldsData', mockqueryMergeFieldsData());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockNotificationConfiguration()
    );

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 404;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(AemService.class)
      .mock('getAemContentData', response);
    Exception ex;
    try {
     // AemApiRepository aemRepo = new AemApiRepository();
     AemApiRepository.getAemContentDataForNotification(
        'get_in_touch_complaint',
        FAKER_CASE_ID
      );
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof AemApiRepository.UnhandledException,
      'Unhandled Exception should be thrown.'
    );
  }



  private static sObject mockqueryMergeFieldsData(){
    Case caseRecord = (Case) TestUtil.setFields(
      new Case(
        Id = FAKER_CASE_ID,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)),
        new Map<String, Object>{ 'CaseNumber' => '1234567' }
      );
    return caseRecord;

  }

  private static Customer_Task_Configuration__c mockNotificationConfiguration() {
    Customer_Task_Configuration__c testRecordNotificationConfig = new Customer_Task_Configuration__c(
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
     return testRecordNotificationConfig;
  }
}
