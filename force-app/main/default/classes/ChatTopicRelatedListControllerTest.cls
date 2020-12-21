/**
 * @author Boobalakrishnan Duraisamy
 * @since 10 2020
 * @description ChatTopicRelatedListControllerTest is the test class to cover tests for {@link ChatTopicRelatedListController}
 */
@isTest
public with sharing class ChatTopicRelatedListControllerTest {
  /**
   * @description setup is to setup test data
   */
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    insert accnt;

    List<Chat_Topic__c> chatTopicList = new List<Chat_Topic__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      chatTopicList.add(
        new Chat_Topic__c(
          Name = faker.randomString(10),
          Status__c = 'Active',
          Twilio_Channel_SID__c = faker.randomString(34),
          Related_Customer__c = accnt.Id
        )
      );
    }
    insert chatTopicList;

    Case newCase = new Case();
    newCase.RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID;
    newCase.AccountId = accnt.Id;
    newCase.Chat_Topic__c = chatTopicList[0].id;
    insert newCase;
  }

  /**
   * @description testFetchChatTopicFromAccount is to test chat topics related to account are retrieved successfully
   */
  @isTest
  public static void testFetchChatTopicFromAccount() {
    Account accnt = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

    List<Chat_Topic__C> chatTopicList = [
      SELECT Id, Twilio_Channel_SID__c
      FROM Chat_Topic__c
    ];

    Test.startTest();

    List<Chat_Topic__c> chatTopicsFromAccount = ChatTopicRelatedListController.getChatTopicsFromAccount(
      accnt.Id
    );

    Test.stopTest();

    System.assertEquals(
      chatTopicList[0].Twilio_Channel_SID__c,
      chatTopicsFromAccount[0].Twilio_Channel_SID__c
    );
  }

  /**
   * @description testFetchChatTopicFromCase is to test chat topics related to case are retrieved successfully
   */
  @isTest
  public static void testFetchChatTopicFromCase() {
    Case testCase = [SELECT Id FROM Case LIMIT 1];

    List<Chat_Topic__C> chatTopicList = [
      SELECT Id, Twilio_Channel_SID__c
      FROM Chat_Topic__c
    ];

    Test.startTest();

    List<Case> chatTopicsFromCase = ChatTopicRelatedListController.getChatTopicFromCase(
      testCase.Id
    );

    Test.stopTest();

    System.assertEquals(
      chatTopicList[0].Twilio_Channel_SID__c,
      chatTopicsFromCase[0].Chat_Topic__r.Twilio_Channel_SID__c
    );
  }
}
