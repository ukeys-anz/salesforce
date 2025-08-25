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

  /**
   * @description Setup common test data
   */
  @testSetup
  public static void setup() {
    interactions = createMockInteraction(1);
    application = createTestLoanApplication();
    mockRecord = new Associated_Loan_Application__c(
      Id = Lib_FakeIdGenerator.getMockId(
        Associated_Loan_Application__c.SObjectType
      ),
      Interaction__c = interactions[0].id,
      Residential_Loan_Application__c = application.id
    );
  }

  /*
   * @description unit test for calculateInteractionRelatedLoanApplications
   */
  @isTest
  static void calculateInteractionRelatedLoanApplicationsTest() {
    setup();
    repoMock.mock('getLoanApplicationsCount', new List<AggregateResult>());
    Test.startTest();
    RBMAssociatedLoanApplicationActions.calculateInteractionRelatedLoanApplications(
      new List<Associated_Loan_Application__c>{ mockRecord }
    );

    Test.stopTest();
    Assert.areEqual(
      false,
      application.hasErrors(),
      'Expected an error when the application count exceeds the limit.'
    );
  }

  /*
   * @description unit test for setApplicationUniqueKeys
   */
  @isTest
  static void setApplicationUniqueKeysTest() {
    setup();
    Test.startTest();
    RBMAssociatedLoanApplicationActions.setApplicationUniqueKeys(
      new List<Associated_Loan_Application__c>{ mockRecord }
    );
    Test.stopTest();
    Assert.areEqual(
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
    Assert.isTrue(
      mockRecord.hasErrors(),
      'App should have validation error due to count exceeding limit.'
    );
  }

  /**
   * @description create the Loan Application Records
   * @param reqRecords Integer value for limit the number of mock records to create
   * @return List<Interaction>
   */
  private static List<Interaction> createMockInteraction(Integer reqRecords) {
    List<Interaction> interactions = new List<Interaction>();
    for (Integer i = 0; i < reqRecords; i++) {
      Interaction mockInteraction = new Interaction();
      mockInteraction.Id = Lib_FakeIdGenerator.getMockId(
        Interaction.SObjectType
      );
      mockInteraction.RecordTypeId = RTInteraction.rbmBrokerInteraction;
      RTInteraction.get(mockInteraction.RecordTypeId);
      RTInteraction.getDeveloperName(mockInteraction.RecordTypeId);
      mockInteraction.Name = 'Test Interaction';
      mockInteraction.Loan_Application__c = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      interactions.add(mockInteraction);
    }
    return interactions;
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
}
