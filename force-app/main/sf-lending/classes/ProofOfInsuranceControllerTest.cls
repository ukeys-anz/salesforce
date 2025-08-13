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
      rla.RecordTypeId = RTResidentialLoanApplication.anzxHomeLoan;
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
    Faker faker = new Faker('AU');
    String settlementId = Faker.randomString(10);
    String mortgageContractId = Faker.randomString(10);
    String propertyId = Faker.randomString(10);
    String documentId = Faker.randomString(10);
    String documentFileVersion = Faker.randomString(10);

    Test.startTest();
    VerifyInsuranceModel response = ProofOfInsuranceController.verifyInsurance(
      settlementId,
      mortgageContractId,
      propertyId,
      documentId,
      documentFileVersion
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
    String settlementId = '';
    String mortgageContractId = '';
    String propertyId = '';
    String documentId = '';
    String documentFileVersion = '';
    Test.startTest();
    try {
      ProofOfInsuranceController.verifyInsurance(
        settlementId,
        mortgageContractId,
        propertyId,
        documentId,
        documentFileVersion
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

  @isTest
  static void testGetDataSuccess() {
    // Use a valid settlement record from setup
    Settlement__c settlement = [
      SELECT Id, Settlement_ID__c, Loan_Application_Number__r.Account.OCV_ID__c
      FROM Settlement__c
      LIMIT 1
    ];
    Map<String, Object> params = new Map<String, Object>{
      'recordId' => settlement.Id
    };
    String paramJson = JSON.serialize(params);

    Test.startTest();
    Object result = new ProofOfInsuranceController().getData(paramJson);
    Test.stopTest();
    Assert.isNotNull(result, 'getData should return proof of insurance data');
  }

  @isTest
  static void testGetDataFailure() {
    // Pass an invalid recordId to trigger error
    Map<String, Object> params = new Map<String, Object>{
      'recordId' => 'invalidId'
    };
    String paramJson = JSON.serialize(params);

    Test.startTest();
    try {
      new ProofOfInsuranceController().getData(paramJson);
      Assert.fail('Exception should be thrown for invalid recordId');
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(ProofOfInsuranceController.ERROR_MSG),
        'Exception message should be for getData failure'
      );
    }
    Test.stopTest();
  }
}
