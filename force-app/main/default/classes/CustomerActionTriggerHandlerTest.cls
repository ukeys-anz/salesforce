/**
 * @author Peter Charalambous
 * @since Mon Mar 25 2024
 * @description Test class for CustomerActionTriggerHandler
 */
@isTest
public with sharing class CustomerActionTriggerHandlerTest {
  private static final String OCVID = '11223344';
  private static final String CUSTOMER = 'Peter Charalambous';
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

    Customer_Action__c customerAction = new Customer_Action__c(
      Accepted_By__c = OCVID,
      Settlement__c = settlement.Id,
      RecordTypeId = SObjectType.Customer_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Loan_Offer_Acceptance')
        .recordTypeId
    );
    insert customerAction;
  }

  @IsTest
  static void testLoanApplicantIsPopulated() {
    LoanApplicant applicant = [
      SELECT Id
      FROM LoanApplicant
      WHERE Name = :CUSTOMER
    ];
    Test.startTest();
    Customer_Action__c customerAction = [
      SELECT Loan_Applicant__c
      FROM Customer_Action__c
      WHERE Loan_Applicant__c = :applicant.Id
    ];
    Test.stopTest();
    Assert.isNotNull(
      customerAction.Loan_Applicant__c,
      'Loan Applicant should contain a value equal to loan applicant id'
    );
  }
}
