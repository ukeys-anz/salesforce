@isTest
public with sharing class RecordAccessLogControllerTest {
  /**
   * @description setup test data
   */
  static void setup() {
    Faker faker = new Faker('AU');

    Account accnt = new Account(
      Name = 'Test Account',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );

    insert accnt;

    BigObjectHelper bigObjectHelper = (BigObjectHelper) Lib_MockService.createMock(
      BigObjectHelper.class,
      new Map<String, Object>{ 'insertBigObject' => true }
    );

    RecordAccessLogController.bigObjectHelper = bigObjectHelper;
  }
  @isTest
  public static void testAccessLogCreation() {
    setup();

    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    String browserDetails = 'Chrome 80';

    Account accnt = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    Test.startTest();

    Boolean success = RecordAccessLogController.createLog(
      browserDetails,
      'Account',
      accnt.Id,
      thisUser.Id
    );

    System.assertEquals(true, success, 'Log should be created successfully.');

    Test.stopTest();
  }
}
