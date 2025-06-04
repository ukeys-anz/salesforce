/**
 * @description       : Test class for RBMAssociatedLoanApplicationActions
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 06-04-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/
@isTest
public with sharing class RBMAssociatedLoanApplicationActionsTest {
  static Lib_MockProvider repoMock = Lib_MockProvider.forType(
    AssociatedLoanApplicationRepository.class
  );
  static List<Interaction> interactions;
  static ResidentialLoanApplication application;
  static Associated_Loan_Application__c mockRecord;

  /*
   * @description Test Data Setup
   */
  public static void setup() {
    interactions = createMockInteraction(1);
    application = createTestLoanApplication();
    mockRecord = createAssociatedLoanApplication(
      interactions[0].id,
      application.id
    );
  }

  /*
   * @description unit test for calculateInteractionRelatedLoanApplications
   */
  @isTest
  static void calculateInteractionRelatedLoanApplicationsTest() {
    Associated_Loan_Application__c application = insertAssociatedLoanApplication();
    mockAggregateResult(application.interaction__c);
    Test.startTest();
    RBMAssociatedLoanApplicationActions.calculateInteractionRelatedLoanApplications(
      new List<Associated_Loan_Application__c>{ application }
    );

    Test.stopTest();
    System.assertEquals(
      false,
      application.hasErrors(),
      'Expected an error when the application count exceeds the limit.'
    );
  }

  /*
   * @description unit test for validateApplicationRecords
   */
  @isTest
  static void validateApplicationRecordsTest() {
    setup();
    Test.startTest();
    RBMAssociatedLoanApplicationActions.validateApplicationRecords(
      new List<Associated_Loan_Application__c>{ mockRecord }
    );
    Test.stopTest();
    System.assertEquals(
      mockRecord.Interaction__c +
        '_' +
        mockRecord.Residential_Loan_Application__c,
      mockRecord.UniqueKeyForAssociatedApplication__c,
      'Error'
    );
  }

  /*
   * @description unit test for validateApplicationLimit
   */
  @isTest
  static void validateApplicationLimitTest() {
    setup();
    Map<Id, Integer> interactionToAppCount = new Map<Id, Integer>();
    interactionToAppCount.put(interactions[0].id, 4);
    Test.startTest();
    RBMAssociatedLoanApplicationActions.validateApplicationLimit(
      new List<Associated_Loan_Application__c>{ mockRecord },
      interactionToAppCount
    );
    Test.stopTest();
    System.assert(
      mockRecord.hasErrors(),
      'App should have validation error due to count exceeding limit.'
    );
  }

  /*
   * @description mockData creation for Aggregated Data
   */
  private static void mockAggregateResult(Id interactionId) {
    List<AggregateResult> actualResults = [
      SELECT Interaction__c, COUNT(Id) appCount
      FROM Associated_Loan_Application__c
      WHERE Interaction__c = :interactionId
      GROUP BY Interaction__c
    ];
    repoMock.mock('queryAssociatedLoanApplicationsCount', actualResults);
  }

  /**
   * @description create the Loan Application Records
   * @param reqRecords Integer value for limit the number of mock records to create
   * @return List<Interaction>
   */
  private static List<Interaction> createMockInteraction(Integer reqRecords) {
    List<Interaction> interactions = new List<Interaction>();
    for (Integer i = 0; i < reqRecords; i++) {
      Boolean isOldRecord = (i > 0) ? true : false;
      Interaction mockInteraction = new Interaction();
      mockInteraction.Id = isOldRecord
        ? interactions[0].Id
        : Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
      mockInteraction.RecordTypeId = RTInteraction.rbmBrokerInteraction;
      mockInteraction.Name = isOldRecord
        ? 'Test Interaction Old'
        : 'Test Interaction';
      mockInteraction.Loan_Application__c = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      interactions.add(mockInteraction);
    }
    return interactions;
  }

  /**
   * @description create the Loan Application Records
   * @param interactionId Interaction Id
   * @param rlaId Associated residential Loan Application
   * @return Associated_Loan_Application__c
   */
  private static Associated_Loan_Application__c createAssociatedLoanApplication(
    Id interactionId,
    Id rlaId
  ) {
    Id assocLoanAppId = Lib_FakeIdGenerator.getMockId(
      Associated_Loan_Application__c.SObjectType
    );
    String jsonString =
      '[{"Id":"' +
      assocLoanAppId +
      '","Interaction__c":"' +
      interactionId +
      '", "Residential_Loan_Application__c":"' +
      rlaId +
      '"}]';
    List<Associated_Loan_Application__c> records = (List<Associated_Loan_Application__c>) JSON.deserialize(
      jsonString,
      List<Associated_Loan_Application__c>.class
    );
    return records[0];
  }

  /**
   * @description create the test Loan Application Records
   * @return ResidentialLoanApplication
   */
  private static ResidentialLoanApplication createTestLoanApplication() {
    ResidentialLoanApplication loan = new ResidentialLoanApplication(
      Name = 'TestLoanApplication',
      Id = Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType)
    );
    return loan;
  }

  private static Associated_Loan_Application__c insertAssociatedLoanApplication() {
    Account personAccount = new Account(
      FirstName = 'Person',
      LastName = 'AccountName',
      RecordTypeId = RTAccount.personAccount,
      OCV_ID__c = '1234'
    );
    insert personAccount;

    Contact broker = new Contact(
      FirstName = 'Person',
      LastName = 'BrokerContact',
      Broker_Customer_Profile__c = personAccount.Id,
      RecordTypeId = RTContact.Broker
    );
    insert broker;

    Interaction testInteraction = TestDataFactory.createInteraction(
      RTInteraction.rbmBrokerInteraction,
      InteractionConstants.NONCUSTOMER,
      'New Interaction',
      System.now(),
      false
    );
    testInteraction.Interaction_Purpose__c = null;
    testInteraction.Attendee_Category__c = 'Broker';
    testInteraction.Broker__c = broker.id;
    insert testInteraction;

    Account acc = TestDataFactory.createAccount('Test Account', true);
    ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication();
    rla.AccountId = acc.id;
    insert rla;

    ResidentialLoanApplication rla1 = TestDataFactory.createTestResidentialLoanApplication();
    rla1.AccountId = acc.id;
    insert rla1;

    Associated_Loan_Application__c application = new Associated_Loan_Application__c();
    application.interaction__c = testInteraction.id;
    application.Residential_Loan_Application__c = rla.id;
    insert application;

    Associated_Loan_Application__c application1 = new Associated_Loan_Application__c();
    application1.interaction__c = testInteraction.id;
    application1.Residential_Loan_Application__c = rla1.id;
    insert application1;

    return application1;
  }

  private static AggregateResult createAggregateResult(Id interactionId) {
    String jsonString =
      '{"Interaction__c":"' +
      String.valueOf(interactionId) +
      '", "appCount":4}';
    AggregateResult fakeResult = (AggregateResult) ((Object) JSON.deserializeUntyped(
      jsonString
    ));
    return fakeResult;
  }
}
