/**
 * @author Peter Charalambous
 * @since Mon Jun 24 2024
 * @description test class for LoanApplicationPropertyController
 */

@isTest
public with sharing class LoanApplicationPropertyControllerTest {
  static Lib_MockProvider loanPropRepoMock;

  static void registerMocks() {
    loanPropRepoMock = Lib_MockProvider.forType(
        LoanApplicationPropertyRepository.class
      )
      .mock('getLoanAppProperty', loanAppProperty);
  }

  static Faker faker = new Faker('AU');
  static Account accnt = new Account(
    OCV_ID__c = faker.randomString(10),
    Id = Lib_FakeIdGenerator.getMockId(Account.getSObjectType())
  );

  static ResidentialLoanApplication loanApp = new ResidentialLoanApplication(
    AccountId = accnt.Id,
    Id = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.getSObjectType()
    )
  );

  static LoanApplicationProperty loanAppProperty = new LoanApplicationProperty(
    Id = Lib_FakeIdGenerator.getMockId(
      LoanApplicationProperty.getSObjectType()
    ),
    Name = faker.person.name(),
    Collateral_Assessment_ID__c = faker.randomString(20),
    LoanApplicationId = loanApp.Id
  );

  @isTest
  static void testReassessCollateralAssessment() {
    registerMocks();
    Test.startTest();
    LoanApplicationPropertyController.reassessCollateralAssessment(
      loanAppProperty.Id
    );
    Test.stopTest();
    Assert.isFalse(
      loanPropRepoMock.getHistories('getLoanAppProperty').isEmpty(),
      'getLoanAppProperty should have been called'
    );
  }

  @isTest
  static void testReassessCollateralAssessmentInvalidUser() {
    // registerMocks();
    NoAccessException accessError = new System.NoAccessException();
    accessError.setMessage(
      'User does not have the permissions to query LoanApplicationProperty'
    );
    Lib_MockProvider.forType(LoanApplicationPropertyRepository.class)
      .mockException('getLoanAppProperty', accessError);
    Test.startTest();
    try {
      LoanApplicationPropertyController.reassessCollateralAssessment(
        loanAppProperty.Id
      );
      Assert.fail('Permission exception should be thrown');
    } catch (Exception e) {
      Assert.areEqual(
        'User does not have the permissions to query LoanApplicationProperty',
        e.getMessage()
      );
    }
    Test.stopTest();
  }
}
