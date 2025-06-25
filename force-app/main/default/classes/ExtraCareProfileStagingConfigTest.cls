/**
 * @description       : Test class for ExtraCareProfileStagingConfig
 * @author            : Akshat Khandelwal
 * @group             :
 * @last modified on  : Apr 2025
 **/
@isTest
private class ExtraCareProfileStagingConfigTest {
  static final Faker FAKER = new Faker('en-AU');

  static Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c();
  static Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
  static Account record = new Account(
    Id = accountId,
    ExtraCareTimePeriod__c = 'Temporarily required',
    ExtraCareReason__c = 'Administration Order;Power of Attorney;Cognitive capacity concerns',
    ExtraCareNotes__c = 'Updating',
    ExtraCareReviewDate__c = Date.today(),
    ExtraCareDisclosure__c = true,
    ExtraCareConsent__c = true
  );
  static Account oldRecord = new Account(
    Id = accountId,
    ExtraCareTimePeriod__c = 'Temporarily required',
    ExtraCareReason__c = 'Administration Order;Power of Attorney',
    ExtraCareNotes__c = 'Updating',
    ExtraCareReviewDate__c = Date.today(),
    ExtraCareDisclosure__c = true,
    ExtraCareConsent__c = false
  );

  @isTest
  private static void testExtraCareProfileStagingConfig() {
    ExtraCareProfileStagingConfig config = new ExtraCareProfileStagingConfig();

    Test.startTest();
    config.process(cpu, record, oldRecord);
    Test.stopTest();

    Assert.isTrue(
      cpu.Name == ('Extra Care Update') &&
        cpu.Object_Name__c == 'Account' &&
        cpu.TriggeredFrom__c == 'Account.Individual.ExtraCare' &&
        cpu.Customer_Name__c == accountId,
      'Customer_Profile_Updates__c should be populated with extra care details'
    );
    Assert.isTrue(
      cpu.ToBeValue__c.contains(
          '"ExtraCareReason__c":"Administration Order;Power of Attorney;Cognitive capacity concerns"'
        ) &&
        cpu.ToBeValue__c.contains(
          '"ExtraCareTimePeriod__c":"Temporarily required"'
        ) &&
        cpu.ToBeValue__c.contains('"ExtraCareDisclosure__c":true') &&
        cpu.ToBeValue__c.contains('"ExtraCareConsent__c":true'),
      'Customer extra care changes should be captured'
    );
  }
}
