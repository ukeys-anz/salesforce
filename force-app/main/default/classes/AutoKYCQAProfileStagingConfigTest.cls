/**
 * @author Tan Phan
 * @since 06/2024
 * @description tests for {@link AutoKYCQAProfileStagingConfig}
 */
@isTest
private class AutoKYCQAProfileStagingConfigTest {
  static final Faker FAKER = new Faker('en-AU');

  static Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c();
  static Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
  static Account record = new Account(
    Id = accountId,
    FinServ__KYCStatus__c = 'CO',
    KYC_Verification_Level__c = 'RR'
  );
  static Account oldRecord = new Account(
    Id = accountId,
    FinServ__KYCStatus__c = 'PC',
    KYC_Verification_Level__c = 'VE'
  );
  static Case kycQaCase = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = accountId
    ),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomString(6) }
  );
  static Map<Id, Case> mapAccountIdToCase = new Map<Id, Case>{
    accountId => kycQaCase
  };

  @isTest
  private static void testAutoKYCQAProfileStagingConfig() {
    AutoKYCQAProfileStagingConfig config = new AutoKYCQAProfileStagingConfig(
      mapAccountIdToCase
    );

    Test.startTest();
    config.process(cpu, record, oldRecord);
    Test.stopTest();

    Assert.isTrue(
      cpu.Name == ('KYC QA Case ' + kycQaCase.CaseNumber + ' - KYC Upgrade') &&
        cpu.Object_Name__c == 'Case' &&
        cpu.TriggeredFrom__c == 'Case.KYC_QA' &&
        cpu.Customer_Name__c == accountId,
      'Customer_Profile_Updates__c should be populated with case details'
    );
    Assert.isTrue(
      cpu.ToBeValue__c.contains('"FinServ__KYCStatus__c":"CO"') &&
        cpu.ToBeValue__c.contains('"KYC_Verification_Level__c":"RR"') &&
        cpu.AsIsValue__c.contains('"FinServ__KYCStatus__c":"PC"') &&
        cpu.AsIsValue__c.contains('"KYC_Verification_Level__c":"VE"'),
      'Customer KYC data changes should be captured'
    );
  }

  @IsTest
  static void testEmptyMap() {
    AutoKYCQAProfileStagingConfig config = new AutoKYCQAProfileStagingConfig(
      null
    );
    Exception error;
    try {
      Test.startTest();
      config.process(cpu, record, oldRecord);
      Test.stopTest();
    } catch (Exception ex) {
      error = ex;
    }
    Assert.isNotNull(
      error,
      'Change capturing process should fail when customer record doesnt map to any case'
    );
  }
}
