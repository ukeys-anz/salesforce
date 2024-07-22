/**
 * @author Peter Charalambous
 * @since 08/2023
 * @description test class for Residential Loan Application trigger handler
 */
@isTest
public with sharing class ResidentialLoanAppTriggerHandlerTest {
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');

    Account accnt = TestDataFactory.createAccount(true);

    //Create RLA records with no owner
    List<ResidentialLoanApplication> rlaList = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      rlaList.add(
        new ResidentialLoanApplication(
          Name = faker.randomString(5),
          Credit_ID__c = faker.randomString(4),
          Assessment_Outcome__c = 'Approved',
          AccountId = accnt.Id,
          Sync_Status__c = 'Broker Org',
          ApplicationExtIdentifier = faker.randomString(4),
          RecordTypeId = GetHelpConstants.LOAN_APPLICATION_RT_ID
        )
      );
    }
    insert rlaList;
  }

  @isTest
  static void testLoanAppOwnerAssignment() {
    Faker faker = new Faker('AU');

    Group homeLoanAppQueue = [
      SELECT Id
      FROM Group
      WHERE developername = 'Home_Loan_Applications_Queue' AND Type = 'Queue'
    ];

    Test.startTest();

    List<ResidentialLoanApplication> rlaList = [
      SELECT OwnerId
      FROM ResidentialLoanApplication
      LIMIT :Integer.valueOf(Label.Test_Bulk_Size)
    ];

    for (ResidentialLoanApplication rla : rlaList) {
      Assert.areEqual(
        rla.OwnerId,
        homeLoanAppQueue.Id,
        'Owner should be Home Loan Applications Queue'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void testBeforeInsert() {
    ResidentialLoanApplicationTriggerHandler handler = new ResidentialLoanApplicationTriggerHandler();
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    handler.records = loanApps;
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();
    Assert.areEqual(
      loanApps.size(),
      handler.records.size(),
      'Loan Applications should be 10'
    );
  }

  @IsTest
  static void testBeforeUpdate() {
    ResidentialLoanApplicationTriggerHandler handler = new ResidentialLoanApplicationTriggerHandler();
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Map<Id, ResidentialLoanApplication> loanAppMap = new Map<Id, ResidentialLoanApplication>(
      loanApps
    );
    handler.records = loanApps;
    Test.startTest();
    handler.onBeforeUpdate(loanAppMap);
    Test.stopTest();
    Assert.areEqual(
      loanAppMap.size(),
      handler.records.size(),
      'Loan Applications should be 10'
    );
  }

  /**
   * @description Method for testing afterUpdate method
   * @author Deepro De | 06-03-2024
   **/
  @IsTest
  static void testAfterUpdate() {
    ResidentialLoanApplicationTriggerHandler handler = new ResidentialLoanApplicationTriggerHandler();
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Map<Id, ResidentialLoanApplication> loanAppMap = new Map<Id, ResidentialLoanApplication>(
      loanApps
    );
    handler.records = loanApps;
    Test.startTest();
    handler.onAfterUpdate(loanAppMap);
    Test.stopTest();
  }

  /**
   * @description Create a list of Residential Loan Applications
   * @param count - number of loan applications to create
   * @return List<ResidentialLoanApplication>
   */
  static List<ResidentialLoanApplication> createResidentialLoanApplications(
    Integer count
  ) {
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < count; i++) {
      ResidentialLoanApplication loanApp = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i + 1)
      );
      loanApp.Id = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      loanApps.add(loanApp);
    }
    return loanApps;
  }
}
