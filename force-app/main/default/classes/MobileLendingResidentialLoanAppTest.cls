/**
 * Ashish Kumar
 * @since June 2025
 * @description Test class for Mobile Lending Residential Loan Application actions
 */
@IsTest
public class MobileLendingResidentialLoanAppTest {
  static Lib_MockProvider dmlMockProvider;
  static Lib_MockProvider rlaMockProvider;
  static void registerMocks() {
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
    rlaMockProvider = Lib_MockProvider.forType(
      ResidentialLoanApplicationRepository.class
    );
  }
  /**
   * @description test method for updateMLOpportunityFromRLA
   */
  @isTest
  static void updateMLOpportunityFromRLATest() {
    registerMocks();
    Id newRLAId = Lib_FakeIdGenerator.getMockId(
      Schema.ResidentialLoanApplication.getSObjectType()
    );
    ResidentialLoanApplication objRLA = new ResidentialLoanApplication(
      Id = newRLAId,
      Status = 'Declined'
    );

    Test.startTest();
    MobileLendingResidentialLoanApplication.updateOpportunity(
      new List<ResidentialLoanApplication>{ ObjRLA }
    );
    Test.stopTest();
    List<Opportunity> lstOfOpp = (List<Opportunity>) dmlMockProvider.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      lstOfOpp[0].StageName,
      'Closed - Lost',
      'Opportunity StageName not updated properly'
    );
    Assert.areEqual(
      lstOfOpp[0].Lost_Reason__c,
      'Declined by Credit',
      'Opportunity lost reason not updated properly'
    );
  }
  /**
   * @description test method for updateMLOpportunityFromRLA
   */
  @IsTest
  static void testPopulateRetailLoanAssistedLender() {
    registerMocks();
    Id rlaId = Lib_FakeIdGenerator.getMockId(
      Schema.ResidentialLoanApplication.getSObjectType()
    );
    List<ResidentialLoanApplication> rlaList = new List<ResidentialLoanApplication>{
      new ResidentialLoanApplication(
        Id = rlaId,
        Name = 'Test RLA',
        Status = 'Declined',
        Assisted_Broker_TPMI_SAO__c = '1234',
        LANID__c = 'TestLANID'
      )
    };
    Map<Id, ResidentialLoanApplication> oldMap = new Map<Id, ResidentialLoanApplication>{
      rlaId => (new ResidentialLoanApplication(
        Id = rlaId,
        Name = 'Test RLA',
        Status = 'Declined',
        Assisted_Broker_TPMI_SAO__c = '1234',
        LANID__c = 'TestLANID1'
      ))
    };
    List<User> userList = new List<User>{
      new User(
        Id = Lib_FakeIdGenerator.getMockId(Schema.User.getSObjectType()),
        FirstName = 'Test',
        LastName = 'User',
        isActive = true,
        Lan_Id__c = 'TestLANID'
      )
    };
    rlaMockProvider.mock('getAssistedLendersByLanId', userList);
    Test.startTest();
    MobileLendingResidentialLoanApplication.populateRetailLoanAssistedLender(
      rlaList,
      oldMap
    );
    Test.stopTest();
    System.Assert.areEqual(
      rlaList[0].Assisted_Lender__c,
      userList[0].Id,
      'Assisted Broker is not populated correctly'
    );
  }
}
