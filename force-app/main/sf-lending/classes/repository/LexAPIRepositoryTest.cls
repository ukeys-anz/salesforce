/**
 * @author Peter Charalambous
 * @since June 2025
 * @description
 */
@isTest
public with sharing class LexAPIRepositoryTest {
  @isTest
  static void testVerifyInsurance() {
    Faker faker = new Faker('AU');
    ProofOfInsuranceController.VerifyInsuranceWrapper poi = new ProofOfInsuranceController.VerifyInsuranceWrapper();
    poi.settlementId = faker.randomString(10);
    poi.mortgageContractId = faker.randomString(10);
    poi.propertyId = faker.randomString(10);
    poi.documentId = faker.randomString(10);
    poi.documentFileVersion = faker.randomString(10);
    poi.ocvId = faker.randomString(10);
    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    VerifyInsuranceModel response = api.verifyInsurance(poi);
    Test.stopTest();

    Assert.areEqual(
      'STATE_VERIFIED',
      response.proofOfInsuranceVerification.state,
      'State should be verified'
    );
  }

  @isTest
  static void testGetSettlement() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    String ocvId = faker.randomString(10);

    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    LexSettlementV1b1SettlementTypes.Settlement settlement = api.getSettlement(
      settlementId,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(settlement, 'Settlement should not be null');
  }

  @isTest
  static void testListLoanFacilityConfigs() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    String ocvId = faker.randomString(10);

    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    LexAPIRepository.ListLoanFacilityConfigsResponse response = api.listLoanFacilityConfigs(
      settlementId,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(response, 'Response should not be null');
    Assert.isNotNull(
      response.loanFacilityConfigs,
      'LoanFacilityConfigs should not be null'
    );
  }

  @isTest
  static void testListAutomaticRepaymentPreferences() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    String ocvId = faker.randomString(10);

    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    LexAPIRepository.ListAutomaticRepaymentPreferencesResponse response = api.listAutomaticRepaymentPreferences(
      settlementId,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(response, 'Response should not be null');
    Assert.isNotNull(
      response.automaticRepaymentPreferences,
      'AutomaticRepaymentPreferences should not be null'
    );
  }

  @isTest
  static void testGetProofOfInsurance() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    String ocvId = faker.randomString(10);

    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    List<LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument> pois = api.getProofOfInsurance(
      settlementId,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(pois, 'ProofOfInsurance list should not be null');
  }

  @isTest
  static void testGetListMortgageContracts() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    String ocvId = faker.randomString(10);

    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    LexAPIRepository.MortgageContractResponse response = api.getListMortgageContracts(
      settlementId,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(response, 'Response should not be null');
    Assert.isNotNull(
      response.mortgageContracts,
      'MortgageContracts should not be null'
    );
  }

  @isTest
  static void testGetSettlementAccount() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    String ocvId = faker.randomString(10);

    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    LexAPIRepository.SettlementAccountResponse response = api.getSettlementAccount(
      settlementId,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(response, 'Response should not be null');
    Assert.isNotNull(
      response.settlementAccounts,
      'SettlementAccounts should not be null'
    );
  }

  @isTest
  static void testGetListDrawdowns() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    String ocvId = faker.randomString(10);

    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    LexAPIRepository.DrawdownResponse response = api.getListDrawdowns(
      settlementId,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(response, 'Response should not be null');
    Assert.isNotNull(response.drawdowns, 'Drawdowns should not be null');
  }

  @isTest
  static void testGetDrawdown() {
    Faker faker = new Faker('AU');
    String drawdownId = faker.randomString(10);
    String ocvId = faker.randomString(10);

    Test.startTest();
    LexAPIRepository api = new LexAPIRepository();
    LexSLMV1alpha2LoanManagementTypes.Drawdown drawdown = api.getDrawdown(
      drawdownId,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(drawdown, 'Drawdown should not be null');
  }
}
