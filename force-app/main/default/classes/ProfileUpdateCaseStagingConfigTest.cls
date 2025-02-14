/**
 * @author Karen Valeriano
 * @since Jan 2025
 * @description This is the test class for @link ProfileUpdateCaseStagingConfig.
 */
@IsTest
private with sharing class ProfileUpdateCaseStagingConfigTest {
  static final Faker FAKER = new Faker('AU');
  static final String CPU_ACTION_UPDATE = 'Update';
  static final String CPU_OBJECTNAME_CASE = 'Case';

  static Account acct = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
    OCV_ID__c = FAKER.randomString(10),
    Source_System_ID__c = FAKER.randomString(10),
    Source_System_Name__c = 'CAP-CIS'
  );
  static Case theCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Type = ProfileUpdateCaseActions.CASE_TYPE_LEGAL_NAME,
    NewFirstName__c = FAKER.person.firstName('male'),
    NewMiddleName__c = FAKER.randomString(5),
    NewLastName__c = FAKER.person.lastName(),
    DocumentType__c = LegalNameUpdateModel.DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE,
    LicenceNumber__c = FAKER.randomString(10),
    LicenceCardNumber__c = FAKER.randomString(15),
    ExpiryDate__c = Date.newInstance(2029, 12, 1),
    StateCode__c = FAKER.address.state(),
    CountryCode__c = 'AUS',
    AccountId = acct.Id
  );
  static Map<Id, Case> mapAccountIdToCase = new Map<Id, Case>{
    acct.Id => theCase
  };
  static Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c(
    Id = Lib_FakeIdGenerator.getMockId(Customer_Profile_Updates__c.SObjectType),
    Customer_Name__c = acct.Id
  );

  @IsTest
  static void testProfileUpdateCaseStagingConfig() {
    ProfileUpdateCaseStagingConfig config = new ProfileUpdateCaseStagingConfig(
      mapAccountIdToCase
    );

    Test.startTest();
    config.process(cpu, acct, null);
    Test.stopTest();

    Assert.areEqual(theCase.Id, cpu.Case__c, 'Incorrect Case Id');
    Assert.areEqual(acct.Id, cpu.Customer_Name__c, 'Incorrect Customer Id');
    Assert.areEqual(
      String.format(
        ProfileUpdateCaseStagingConfig.CPU_NAME_VALUE_LEGAL_NAME,
        new List<String>{ theCase.CaseNumber }
      ),
      cpu.Name,
      'Should set the correct Name'
    );
    Assert.areEqual(
      CPU_OBJECTNAME_CASE,
      cpu.Object_Name__c,
      'Should set the correct Object_Name__c'
    );
    Assert.areEqual(
      ProfileUpdateCaseStagingConfig.TRIGGERED_FROM_VALUE_LEGAL_NAME,
      cpu.TriggeredFrom__c,
      'Should set the correct TriggeredFrom__c'
    );
    Assert.areEqual(
      CPU_ACTION_UPDATE,
      cpu.Action__c,
      'Should set the correct Action__c'
    );
    Assert.areEqual(
      String.format(
          ProfileUpdateCaseStagingConfig.LEGAL_NAME_NEW_VALUE,
          new List<String>{
            ProfileUpdateCaseStagingConfig.getValue(theCase.NewFirstName__c),
            ProfileUpdateCaseStagingConfig.getValue(theCase.NewMiddleName__c),
            ProfileUpdateCaseStagingConfig.getValue(theCase.NewLastName__c)
          }
        )
        .trim(),
      cpu.NewValue__c,
      'Should set the correct NewValue__c'
    );
    Assert.isTrue(
      cpu.ToBeValue__c.contains('"firstName":"' + theCase.NewFirstName__c),
      'Should set the correct firstName value'
    );
    Assert.isTrue(
      cpu.ToBeValue__c.contains('"middleName":"' + theCase.NewMiddleName__c),
      'Should set the correct middleName value'
    );
    Assert.isTrue(
      cpu.ToBeValue__c.contains('"lastName":"' + theCase.NewLastName__c),
      'Should set the correct lastName value'
    );
    Assert.isTrue(
      cpu.ToBeValue__c.contains(
        '"identifier":"enc(' + theCase.LicenceNumber__c
      ),
      'Should set the correct document identifier value'
    );
    Assert.isTrue(
      cpu.ToBeValue__c.contains(
        '"identifier":"enc(' + theCase.LicenceCardNumber__c
      ),
      'Should set the correct related document identifier value'
    );
    Assert.isTrue(
      cpu.ToBeValue__c.contains('"identifier":"' + acct.OCV_ID__c),
      'Should set the correct ocv identifier value'
    );
  }

  @IsTest
  static void testEmptyMap() {
    ProfileUpdateCaseStagingConfig config = new ProfileUpdateCaseStagingConfig(
      null
    );
    Exception error;
    try {
      Test.startTest();
      config.process(cpu, acct, null);
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
