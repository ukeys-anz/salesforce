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
    Account accnt = new Account(
      Name = 'TestAccount',
      OCV_ID__c = '1234567891',
      ANZx_Customer__c = true
    );
    insert accnt;
    Case newCase = new Case(
      RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
      AccountId = accnt.Id,
      Twilio_Channel_SID__c = 'CH123456789',
      Origin = 'Chat'
    );
    insert newCase;
  }

  /**
   * @description test method for getChatTopicsOnAccount when successful
   */
  @isTest
  public static void validResponseChatTopicsOnAccount() {
    // Query for pre-inserted Account record
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Test.startTest();
    ChatChannelModel response = ChatTopicRelatedListController.getChatTopicsOnAccount(
      acc.Id,
      ''
    );
    Test.stopTest();

    System.assertEquals(
      2,
      response.channels.size(),
      'Number of chat topics returned does not match with mock values size.'
    );
    System.assertEquals(
      'CH147c6128b4864e0aaadc58d87d74e50c',
      response.channels[0].id,
      'Id of 1st chat topic does not match.'
    );
  }

  /**
   * @description test method for getChatTopicsOnAccount when response is null
   */
  @isTest
  public static void nullsResponseChatTopicsOnAccount() {
    Test.startTest();
    ChatChannelModel response = ChatTopicRelatedListController.getChatTopicsOnAccount(
      '',
      ''
    );
    Test.stopTest();

    System.assertEquals(null, response, 'Response is not null.');
  }

  /**
   * @description test method for getChatTopicInfoOnCase when successful
   */
  @isTest
  public static void validResponseChatTopicOnCase() {
    // Query for pre-inserted Case record
    Case chatCase = [SELECT Id FROM Case WHERE AccountId != NULL LIMIT 1];
    Test.startTest();
    ChatChannelModel response = ChatTopicRelatedListController.getChatTopicInfoOnCase(
      chatCase.Id
    );
    Test.stopTest();

    System.assertEquals(
      2,
      response.channels.size(),
      'Number of chat topics returned does not match with mock values size.'
    );
    System.assertEquals(
      'CH147c6128b4864e0aaadc58d87d74e50c',
      response.channels[0].id,
      'Id of 1st chat topic does not match.'
    );
  }

  /**
   * @description test method for getChatTopicInfoOnCase when response is null
   */
  @isTest
  public static void nullsResponseChatTopicsOnCase() {
    Test.startTest();
    ChatChannelModel response = ChatTopicRelatedListController.getChatTopicInfoOnCase(
      ''
    );
    Test.stopTest();

    System.assertEquals(null, response, 'Response is not null.');
  }
}
