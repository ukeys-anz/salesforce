/**
 * @author Peter Charalambous
 * @since Mon Oct 23 2023
 * @description Test for ProofOfInsuranceController class
 */
@isTest
public with sharing class ProofOfInsuranceControllerTest {
  /**
   * @description This setup method creates the record(s) required for the test classes
   */
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');

    Account customer = TestDataFactory.createAccount(
      Faker.person.firstName(),
      true
    );
    ResidentialLoanApplication[] newRLA = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i)
      );
      rla.AccountId = customer.Id;

      newRLA.add(rla);
    }
    insert newRLA;

    //Setup the loan app financials
    List<LoanApplicationFinancial> loanAppFinancialList = new List<LoanApplicationFinancial>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      LoanApplicationFinancial loanAppFinancial = TestDataFactory.createLoanApplicationFinancial(
        newRLA[i].Id
      );
      loanAppFinancialList.add(loanAppFinancial);
    }

    insert loanAppFinancialList;

    //Create action plans before creating settlement
    TestDataFactory.createSettlementActionPlans();

    Settlement__c[] settlementList = new List<Settlement__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Settlement__c settlement = TestDataFactory.createSettlement(newRLA[i].Id);
      settlementList.add(settlement);
    }

    insert settlementList;

    Proof_of_Insurance__c[] poiList = new List<Proof_of_Insurance__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Proof_of_Insurance__c poi = TestDataFactory.createPOI(
        settlementList[i].Id
      );
      poi.Mortgage_Contract_ID__c = Faker.randomString(10);
      poi.Property_ID__c = Faker.randomString(10);
      poi.Document_Id__c = Faker.randomString(10);
      poi.Document_File_Version__c = Faker.randomString(10);
      poiList.add(poi);
    }

    //Create an invalid POI for negative tests too
    Proof_of_Insurance__c poi = TestDataFactory.createPOI(settlementList[0].Id);
    poiList.add(poi);
    insert poiList;
  }

  @isTest
  static void testSuccessVerifyInsurance() {
    List<Proof_of_Insurance__c> poi = [
      SELECT Id
      FROM Proof_of_Insurance__c
      WHERE Mortgage_Contract_ID__c != NULL
    ];
    Test.startTest();
    VerifyInsuranceModel response = ProofOfInsuranceController.verifyInsurance(
      poi[0].Id
    );
    Test.stopTest();
    Assert.areEqual(
      'STATE_VERIFIED',
      response.proofOfInsuranceVerification.state,
      'State should be verified'
    );
  }

  @isTest
  static void testInvalidVerifyInsurance() {
    List<Proof_of_Insurance__c> poi = [
      SELECT Id
      FROM Proof_of_Insurance__c
      WHERE Mortgage_Contract_ID__c = NULL
    ];
    Test.startTest();
    try {
      VerifyInsuranceModel response = ProofOfInsuranceController.verifyInsurance(
        poi[0].Id
      );
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(ProofOfInsuranceController.TECH_ASSIST_ERROR),
        'Exception message should be thrown for processing'
      );
    }
    Test.stopTest();
  }
}
