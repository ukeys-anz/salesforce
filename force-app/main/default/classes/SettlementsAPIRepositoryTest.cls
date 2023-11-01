/**
 * @author Peter Charalambous
 * @since Mon Oct 23 2023
 * @description
 */
@isTest
public with sharing class SettlementsAPIRepositoryTest {
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
    insert poiList;
  }

  @isTest
  static void testVerifyInsurance() {
    List<Proof_of_Insurance__c> poiDetails = [
      SELECT
        Settlement_ID__c,
        Mortgage_Contract_ID__c,
        Property_ID__c,
        Document_Id__c,
        Document_File_Version__c,
        Settlement_ID__r.Loan_Application_Number__r.Account.OCV_ID__c
      FROM Proof_of_Insurance__c
    ];
    Test.startTest();
    SettlementsAPIRespository api = new SettlementsAPIRespository();
    VerifyInsuranceModel response = api.verifyInsurance(poiDetails[0]);
    Test.stopTest();

    Assert.areEqual(
      'STATE_VERIFIED',
      response.proof_of_insurance_verification.state,
      'State should be verified'
    );
  }
}
