/**
 * @description       :
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 09-25-2024
 * @last modified by  :  Harshit Goyal | Salesforce
 **/
@isTest
public with sharing class SettlementActionsTest {
  static Lib_MockProvider rlarRepoMock = Lib_MockProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  @isTest
  static void testGetLoanApplicationIdFromSettlement() {
    List<Settlement__c> settlementList = createTestSettlement();
    String loanApplicationId = settlementList[0].Loan_Application_Number__c;
    Test.startTest();
    List<Id> loanApplicationIds = SettlementActions.getLoanApplicationIdFromSettlements(
      settlementList
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
  static void testpublishSettlementAccountCloudEvents() {
    List<Settlement__c> settlementList = createTestSettlement();
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>{
      new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.getSObjectType()
        ),
        Name = 'Test ResidentialLoanApplication'
      )
    };
    rlarRepoMock.mock('queryLoanApplications', loanApps);
    Test.startTest();
    SettlementActions.publishSettlementCloudEvents(settlementList, 'Add');
    Test.stopTest();
    Assert.isFalse(
      rlarRepoMock.getHistories('queryLoanApplications').isEmpty(),
      'ResidentialLoanApplications mock method should be called'
    );
  }

  static List<Settlement__c> createTestSettlement() {
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>{
      new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.getSObjectType()
        ),
        Name = 'Test ResidentialLoanApplication'
      )
    };

    String jsonSettlement =
      '{"Name":"TEST_NAME", "Loan_Application_Number__c":"' +
      loanApps[0].Id +
      '", "IsValidCloudEvent__c": true}';

    Settlement__c settlementSerialized = (Settlement__c) JSON.deserialize(
      jsonSettlement,
      Settlement__c.class
    );

    List<Settlement__c> settlementList = new List<Settlement__c>{
      settlementSerialized
    };
    return settlementList;
  }
}
