/**
 *
 * @author Kopal Goswami
 * @since 07/2023
 * @description Tests InteractionRecordServiceController for LWC
 */

@isTest
public with sharing class InteractionRecordServiceControllerTest {
  public static final String CUSTOMER_PURPOSE = 'Customer';
  public static final String OPEN_STATUS = 'Open';
  public static final String STORE_LOCATION = 'Store';
  public static final String GENERAL_RECORD_TYPE = 'General';
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
      Status = OPEN_STATUS,
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID
    );
    insert newCase;

    Schema.Location testLocation = new Schema.Location();
    testLocation.LocationType = STORE_LOCATION;
    testLocation.Name = faker.randomString(10);
    insert testLocation;

    Coaching_Summary__c coachSummary = new Coaching_Summary__c();
    coachSummary.Name__c =
      CUSTOMER_PURPOSE + InteractionConstants.COACHING_SUMMARY_LABEL;
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
      RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      AccountId = testAcc.Id,
      CaseId__c = newCase.Id,
      StartTime = Datetime.now(),
      InteractionType = STORE_LOCATION,
      LocationId = testLocation.Id,
      Coaching_Summary__c = coachSummary.Id,
      Lead__c = testLead.Id,
      Loan_Application__c = testRLA.Id
    );
    List<Interaction> intList = new List<Interaction>{ testInteraction };
    insert intList;
    Test.stopTest();
    List<InteractionRecordServiceController.InteractionWrapper> wrapperList = InteractionRecordServiceController.getInteractionRecord(
      testAcc.Id,
      GENERAL_RECORD_TYPE,
      3
    );
    System.assertEquals(
      1,
      wrapperList.size(),
      'General interaction WrapperList size should be 1'
    );
    System.assertEquals(
      testInteraction.Id,
      wrapperList[0].interactId,
      'General Id should match returned Genreal interaction record'
    );

    List<InteractionRecordServiceController.InteractionWrapper> intWrapperList = InteractionRecordServiceController.getInteractionRecord(
      newCase.Id,
      GENERAL_RECORD_TYPE,
      3
    );
    System.assertEquals(
      1,
      intWrapperList.size(),
      'Interaction exists from case object page'
    );

    List<InteractionRecordServiceController.InteractionWrapper> csWrapperList = InteractionRecordServiceController.getInteractionRecord(
      coachSummary.Id,
      GENERAL_RECORD_TYPE,
      3
    );
    System.assertEquals(
      1,
      csWrapperList.size(),
      'Interaction exists from coaching summary object page'
    );

    List<InteractionRecordServiceController.InteractionWrapper> leadWrapperList = InteractionRecordServiceController.getInteractionRecord(
      testLead.Id,
      GENERAL_RECORD_TYPE,
      3
    );
    System.assertEquals(
      1,
      leadWrapperList.size(),
      'Interaction exists from lead object page'
    );

    List<InteractionRecordServiceController.InteractionWrapper> rlaWrapperList = InteractionRecordServiceController.getInteractionRecord(
      testRLA.Id,
      GENERAL_RECORD_TYPE,
      3
    );
    System.assertEquals(
      1,
      rlaWrapperList.size(),
      'Interaction exists from Residential Loan application object page'
    );
  }
}
