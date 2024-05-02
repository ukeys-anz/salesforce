/**
 * @author Peter Charalambous
 * @since Mon Mar 25 2024
 * @description test class for proof of insurance trigger handler
 */
@isTest
public with sharing class ProofOfInsuranceTriggerHandlerTest {
  private static final String OCVID = '11223344';
  private static final String CUSTOMER = 'Peter Charalambous';
  @TestSetup
  static void setup() {
    //Not using faker as we need to assert the names
    Account customer = TestDataFactory.createAccount(CUSTOMER, false);
    customer.OCV_ID__c = OCVID;
    insert customer;

    ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication();
    rla.AccountId = customer.Id;
    insert rla;

    LoanApplicationFinancial loanAppFinancial = TestDataFactory.createLoanApplicationFinancial(
      rla.Id
    );
    insert loanAppFinancial;

    //Create action plans before creating settlement
    TestDataFactory.createSettlementActionPlans();

    Settlement__c settlement = TestDataFactory.createSettlement(rla.Id);
    insert settlement;

    Proof_of_Insurance__c poi = new Proof_of_Insurance__c(
      Settlement_ID__c = settlement.Id,
      Verified_By__c = OCVID
    );
    insert poi;
  }

  @IsTest
  static void testCustomerNamePopulated() {
    Test.startTest();
    Proof_of_Insurance__c poi = [
      SELECT Verified_By__c
      FROM Proof_of_Insurance__c
      LIMIT 1
    ];
    Assert.areEqual(CUSTOMER, poi.Verified_By__c);

    Test.stopTest();
  }
}
