/**
 * Ashish Kumar
 * @since June 2025
 * @description Test class for Mobile Lending Settlement actions
 */
@isTest
public with sharing class MobileLendingSettlementActionsTest {
  static Lib_MockProvider rlarRepoMock = Lib_MockProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
  }

  /**
   * @description test method for updateMLOpportunityFromSettlement
   */
  @isTest
  static void updateMLOpportunityFromSettlementTest() {
    registerMocks();
    Id newRLAId = Lib_FakeIdGenerator.getMockId(
      Schema.ResidentialLoanApplication.getSObjectType()
    );
    Id newSettlementId = Lib_FakeIdGenerator.getMockId(
      Schema.Settlement__c.getSObjectType()
    );

    Map<Id, ResidentialLoanApplication> rlaMap = new Map<Id, ResidentialLoanApplication>();

    ResidentialLoanApplication objRLA = new ResidentialLoanApplication(
      Id = newRLAId,
      Status = 'Declined',
      Assisted_Broker_TPMI_SAO__c = '12345',
      LANID__c = 'Kunn209'
    );

    Settlement__c objSettlement = new Settlement__c(
      Id = newSettlementId,
      Status__c = 'Unspecified',
      Loan_Application_Number__c = newRLAId
    );

    rlaMap.put(newRLAId, objRLA);

    rlarRepoMock.mock(
      'queryResidentialLoanApplication',
      new List<ResidentialLoanApplication>{ objRLA }
    );

    Test.startTest();
    MobileLendingSettlementActions.updateOpportunity(
      new List<Settlement__c>{ objSettlement },
      rlaMap
    );
    Test.stopTest();
    List<Opportunity> lstOfOpp = (List<Opportunity>) dmlMockProvider.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      lstOfOpp[0].StageName,
      'Documents',
      'Opportunity StageName not updated properly'
    );
  }
}
