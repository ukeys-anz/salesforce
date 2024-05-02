/**
 * @author Peter Charalambous
 * @since Tue Apr 16 2024
 * @description test class for SettlementAccountTriggerHandler
 */

@IsTest
public with sharing class SettlementAccountTriggerHandlerTest {
  private static final String OCVID = '11223344';
  private static final String CUSTOMER = 'Test Customer';

  @TestSetup
  static void setup() {
    //Not using faker as we need to assert the names
    Account acc = TestDataFactory.createAccount(CUSTOMER, false);
    acc.OCV_ID__c = OCVID;
    insert acc;

    ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication();
    rla.AccountId = acc.Id;
    insert rla;

    LoanApplicationFinancial loanAppFinancial = TestDataFactory.createLoanApplicationFinancial(
      rla.Id
    );
    insert loanAppFinancial;

    //Create action plans before creating settlement
    TestDataFactory.createSettlementActionPlans();

    Settlement__c settlement = TestDataFactory.createSettlement(rla.Id);
    insert settlement;

    LoanApplicant applicant = new LoanApplicant(
      Account__c = acc.Id,
      LoanApplicationId = rla.Id,
      Name = CUSTOMER
    );
    insert applicant;

    Settlement_Account__c settleAcc = new Settlement_Account__c(
      Nominated_By_Id__c = OCVID,
      Settlement__c = settlement.Id
    );
    insert settleAcc;
  }
  @IsTest
  static void testNominatedByNameIsPopulated() {
    LoanApplicant applicant = [
      SELECT Id
      FROM LoanApplicant
      WHERE Name = :CUSTOMER
    ];
    Test.startTest();
    Settlement_Account__c settleAcc = [
      SELECT Nominated_By__c
      FROM Settlement_Account__c
      WHERE Nominated_By__c = :applicant.Id
    ];
    Test.stopTest();
    Assert.isNotNull(
      settleAcc.Nominated_By__c,
      'Nominated By should contain a value equal to loan applicant id'
    );
  }
}
