@IsTest
public with sharing class SettlementAccountActionsTest {
  static Lib_MockProvider rlarRepoMock = Lib_MockProvider.forType(
    ResidentialLoanApplicationRepository.class
  );

  @isTest
  static void testGetLoanApplicationIdFromSettlementAccounts() {
    List<Settlement_Account__c> settlementAccountList = createTestSettlementAccount();
    String loanApplicationId = settlementAccountList[0]?.Loan_Application_Id__c;
    Test.startTest();
    List<Id> loanApplicationIds = SettlementAccountActions.getLoanApplicationIdFromSettlementAccounts(
      settlementAccountList
    );
    Test.stopTest();
    System.assertEquals(
      loanApplicationId,
      loanApplicationIds[0],
      'Loan application Ids should match'
    );
    Assert.areEqual(
      1,
      loanApplicationIds.size(),
      'is valid cloud event is true, hence loan application Id should be 2'
    );
  }
  @isTest
  static void testPublishSettlementAccountCloudEvents() {
    List<Settlement_Account__c> settlementAccountList = createTestSettlementAccount();
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>{
      new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.getSObjectType()
        ),
        Name = 'Test ResidentialLoanApplication'
      )
    };
    rlarRepoMock.mock('queryMultipleLoanApplications', loanApps);
    Test.startTest();
    SettlementAccountActions.publishSettlementAccountCloudEvents(
      settlementAccountList,
      'Add'
    );
    Test.stopTest();
    Assert.isFalse(
      rlarRepoMock.getHistories('queryMultipleLoanApplications').isEmpty(),
      'ResidentialLoanApplications mock method should be called'
    );
  }

  static List<Settlement_Account__c> createTestSettlementAccount() {
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>{
      new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.getSObjectType()
        ),
        Name = 'Test ResidentialLoanApplication'
      )
    };
    Settlement__c settlement = new Settlement__c(
      Id = Lib_FakeIdGenerator.getMockId(Settlement__c.SObjectType),
      Loan_Application_Number__c = loanApps[0].Id,
      Type__c = 'TYPE_REFINANCE_OFI'
    );

    String jsonSettlementAccount =
      '{"Name":"TEST_NAME", "Settlement__c":"' +
      settlement.Id +
      '", "Loan_Application_Id__c":"' +
      loanApps[0].Id +
      '", "IsValidCloudEvent__c": true}';

    Settlement_Account__c settlementAcc = (Settlement_Account__c) JSON.deserialize(
      jsonSettlementAccount,
      Settlement_Account__c.class
    );

    List<Settlement_Account__c> settlementAccountList = new List<Settlement_Account__c>{
      settlementAcc
    };
    return settlementAccountList;
  }
}
