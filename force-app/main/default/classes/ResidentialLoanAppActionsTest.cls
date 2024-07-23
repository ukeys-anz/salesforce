/**
 * @author Jason Zhiren Guan
 * @since April 2024
 * @description Test class for Residential Loan Application actions
 */

@IsTest
private class ResidentialLoanAppActionsTest {
  private static final String BROKER_CODE = 'TPMI123456789';

  @IsTest
  static void testPopulateAssistedBroker() {
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.populateRetailLoanAssistedBroker(
      new List<ResidentialLoanApplication>(),
      new Map<Id, ResidentialLoanApplication>()
    );
    Test.stopTest();
    Assert.isTrue(results.isEmpty(), 'Results should be empty without input');
  }

  @IsTest
  static void testGetRecordsForAssistedBrokerOnInsert() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.getRecordsToUpdateAssistedBroker(
      loanApps,
      new Map<Id, ResidentialLoanApplication>()
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      loanApps.size(),
      'Results should be the same size as input'
    );
  }

  @IsTest
  static void testGetRecordsForAssistedBrokerOnUpdate() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Map<Id, ResidentialLoanApplication> loanAppMap = convertRecordsToOldMap(
      loanApps
    );
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.getRecordsToUpdateAssistedBroker(
      loanApps,
      loanAppMap
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      loanApps.size(),
      'Results should be the same size as input'
    );
  }

  @IsTest
  static void testProcessEmptyAssistedBroker() {
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.processAssistedBrokerPopulation(
      new List<ResidentialLoanApplication>(),
      ResidentialLoanApplicationActions.ACCREDITATION_RETAIL
    );
    Test.stopTest();
    Assert.isTrue(results.isEmpty(), 'Results should be empty without input');
  }

  @IsTest
  static void testProcessAssistedBroker() {
    ResidentialLoanApplicationActions.mockBrokerCodes = createBrokerCodes(10);
    Id testContactId = ResidentialLoanApplicationActions.mockBrokerCodes[0]
      .Broker_Name__c;
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.processAssistedBrokerPopulation(
      loanApps,
      ResidentialLoanApplicationActions.ACCREDITATION_RETAIL
    );
    Test.stopTest();
    Assert.areEqual(
      results.size(),
      loanApps.size(),
      'Results should be the same size as input'
    );
    for (ResidentialLoanApplication loanApp : results) {
      Assert.areEqual(
        loanApp.Assisted_Broker__c,
        testContactId,
        'Assisted Broker should be populated with Broker_Name__c value'
      );
    }
  }

  @IsTest
  static void testGetBrokerCodesByTPMISAO() {
    List<String> brokerIdentifiers = new List<String>{ 'EXT-1234_Retail' };
    Test.startTest();
    List<Broker_Code__c> brokerCodes = ResidentialLoanApplicationActions.getBrokerCodesByTPMISAO(
      brokerIdentifiers
    );
    Assert.isTrue(
      brokerCodes.isEmpty(),
      'Broker Codes should be empty without DML in unit tests'
    );
    ResidentialLoanApplicationActions.mockBrokerCodes = createBrokerCodes(10);
    brokerCodes = ResidentialLoanApplicationActions.getBrokerCodesByTPMISAO(
      brokerIdentifiers
    );
    Test.stopTest();
    Assert.areEqual(brokerCodes.size(), 10, 'Broker Codes should be populated');
  }

  static List<ResidentialLoanApplication> createResidentialLoanApplications(
    Integer count
  ) {
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < count; i++) {
      ResidentialLoanApplication loanApp = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i + 1)
      );
      loanApp.Id = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      loanApp.Assisted_Broker_TPMI_SAO__c = BROKER_CODE;
      loanApps.add(loanApp);
    }
    return loanApps;
  }

  static List<Broker_Code__c> createBrokerCodes(Integer count) {
    Contact testContact = createTestContact();
    List<Broker_Code__c> brokerCodes = new List<Broker_Code__c>();
    for (Integer i = 0; i < count; i++) {
      Broker_Code__c brokerCode = new Broker_Code__c();
      brokerCode.Id = Lib_FakeIdGenerator.getMockId(Broker_Code__c.SObjectType);
      brokerCode.Accreditation_Type__c = 'Retail';
      brokerCode.Broker_Name__c = testContact.Id;
      brokerCode.External_Id__c =
        BROKER_CODE +
        '_' +
        ResidentialLoanApplicationActions.ACCREDITATION_RETAIL;
      brokerCodes.add(brokerCode);
    }
    return brokerCodes;
  }

  static Contact createTestContact() {
    Contact testContact = new Contact();
    testContact.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    testContact.FirstName = 'Broker01';
    testContact.LastName = 'ANZX-6197';
    testContact.Email = 'contactbroker@anzx.abc';
    testContact.MobilePhone = '123456789';
    testContact.RetailTPMISAO__c = BROKER_CODE;
    testContact.OCV_ID__c = 'OCV123456789';
    return testContact;
  }

  static Map<Id, ResidentialLoanApplication> convertRecordsToOldMap(
    List<ResidentialLoanApplication> loanApps
  ) {
    List<ResidentialLoanApplication> oldLoanApps = loanApps.deepClone(true);
    for (ResidentialLoanApplication loanApp : oldLoanApps) {
      loanApp.Assisted_Broker_TPMI_SAO__c =
        loanApp.Assisted_Broker_TPMI_SAO__c + '_Old';
    }
    return new Map<Id, ResidentialLoanApplication>(oldLoanApps);
  }
}
