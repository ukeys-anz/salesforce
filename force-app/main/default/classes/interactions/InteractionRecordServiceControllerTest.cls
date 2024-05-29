/**
 *
 * @author Kopal Goswami
 * @since 07/2023
 * @description Tests InteractionRecordServiceController for LWC
 */

@isTest
public with sharing class InteractionRecordServiceControllerTest {
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = faker.randomString(10),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );
    insert acc;
  }

  /**
   * @description testGetInteractions tests query for interaction from different objects page.
   */
  @isTest
  static void testGetInteractionRecord() {
    Test.startTest();
    Account testAcc = [SELECT Id FROM Account LIMIT 1];
    Faker faker = new Faker('AU');

    Case newCase = new Case(
      Status = GetHelpConstants.OPEN_STATUS,
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID
    );
    insert newCase;

    Coaching_Summary__c coachSummary = new Coaching_Summary__c();
    coachSummary.Name__c = InteractionConstants.COACHING_SUMMARY_LABEL;
    coachSummary.Status__c = InteractionConstants.NEW_STATUS;
    coachSummary.Account__c = testAcc.Id;
    insert coachSummary;

    Lead testLead = new Lead();
    testLead.FirstName = 'New';
    testLead.LastName = 'Lead';
    testLead.Company = testLead.FirstName;
    testLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('General')
      .getRecordTypeId();
    testLead.Email =
      testLead.FirstName +
      '.' +
      testLead.LastName +
      '@test.test';
    insert testLead;

    ResidentialLoanApplication testRLA = new ResidentialLoanApplication();
    testRLA.accountid = testAcc.Id;
    testRLA.name = 'New RLA';
    insert testRLA;

    Interaction testInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_MESSAGE_RT_ID,
      AccountId = testAcc.Id,
      CaseId__c = newCase.Id,
      StartTime = Datetime.now(),
      InteractionType = InteractionConstants.CALL,
      Direction__c = 'Outbound',
      Coaching_Summary__c = coachSummary.Id,
      Lead__c = testLead.Id,
      Loan_Application__c = testRLA.Id,
      Status__c = 'Active'
    );
    List<Interaction> intList = new List<Interaction>{ testInteraction };
    insert intList;
    List<String> listOfStatusSearch = new List<String>{ 'Created', 'Linked' };
    InteractionSearchStringController.fetchDataForInteraction(
      testAcc.Id,
      InteractionConstants.MESSAGE,
      listOfStatusSearch
    );
    Test.stopTest();
    List<InteractionRecordServiceController.InteractionWrapper> wrapperList = InteractionRecordServiceController.getInteractionRecord(
      testAcc.Id,
      InteractionConstants.MESSAGE,
      3,
      false
    );
    System.assertEquals(
      1,
      wrapperList.size(),
      'Message interaction WrapperList size should be 1'
    );

    List<InteractionRecordServiceController.InteractionWrapper> activeInteractionList = InteractionRecordServiceController.getInteractionRecord(
      testAcc.Id,
      InteractionConstants.MESSAGE,
      3,
      true
    );
    System.assertEquals(
      1,
      activeInteractionList.size(),
      'Message interaction WrapperList size should be 1'
    );

    System.assertEquals(
      testInteraction.Id,
      wrapperList[0].interactId,
      'Message Id should match returned Genreal interaction record'
    );

    List<InteractionRecordServiceController.InteractionWrapper> intWrapperList = InteractionRecordServiceController.getInteractionRecord(
      newCase.Id,
      InteractionConstants.MESSAGE,
      3,
      false
    );
    System.assertEquals(
      1,
      intWrapperList.size(),
      'Interaction exists from case object page'
    );

    List<InteractionRecordServiceController.InteractionWrapper> csWrapperList = InteractionRecordServiceController.getInteractionRecord(
      coachSummary.Id,
      InteractionConstants.MESSAGE,
      3,
      false
    );
    System.assertEquals(
      1,
      csWrapperList.size(),
      'Interaction exists from coaching summary object page'
    );

    List<InteractionRecordServiceController.InteractionWrapper> leadWrapperList = InteractionRecordServiceController.getInteractionRecord(
      testLead.Id,
      InteractionConstants.MESSAGE,
      3,
      false
    );
    System.assertEquals(
      1,
      leadWrapperList.size(),
      'Interaction exists from lead object page'
    );

    List<InteractionRecordServiceController.InteractionWrapper> rlaWrapperList = InteractionRecordServiceController.getInteractionRecord(
      testRLA.Id,
      InteractionConstants.MESSAGE,
      3,
      false
    );
    System.assertEquals(
      1,
      rlaWrapperList.size(),
      'Interaction exists from Residential Loan application object page'
    );
  }
  @isTest
  static void testGetArgumentsMap() {
    List<String> statusSearchList = Label.Interaction_Status.split(',');
    Map<String, Object> inputOrgs = (Map<String, Object>) InteractionRecordServiceController.getArgumentsMap(
        Lib_FakeIdGenerator.getMockId(Interaction.getSObjectType()),
        InteractionConstants.MESSAGE,
        3,
        false,
        statusSearchList
      )
      .get('input');
    System.assertEquals(
      3,
      inputOrgs.get('maxNumber'),
      'MaxNumber value will be same as input'
    );
  }
  @isTest
  static void testGetArgumentsMapForOpen() {
    List<String> statusSearchList = Label.Interaction_Status.split(',');
    Map<String, Object> inputOrgs = (Map<String, Object>) InteractionRecordServiceController.getArgumentsMap(
        Lib_FakeIdGenerator.getMockId(Interaction.getSObjectType()),
        InteractionConstants.MESSAGE,
        3,
        true,
        statusSearchList
      )
      .get('input');
    System.assertEquals(
      4,
      inputOrgs.get('maxNumber'),
      'MaxNumber value will be plus one to the input maxNumber'
    );
  }
}
