/**
 * @author Akanksha Kulkarni
 * @since Nov 2025
 * @group (Commercial Broker)
 * @description Test class for ApplicationFormEventBuilder
 */
@IsTest
public class ApplicationFormEventBuilderTest {
  @IsTest
  static void testBuildPayloadNoErrorSingleRecord() {
    Account acc = createAccount();
    ApplicationForm app = createApplicationForm(acc.Id);

    Map<Id, String> mapAcc = new Map<Id, String>{
      acc.Id => acc.External_Id__c
    };

    BrokerCloudEventModel.BrokerCloudEventDataModel ceData = ApplicationFormEventBuilder.buildApplicationFormPayload(
      new List<ApplicationForm>{ app },
      mapAcc
    );

    System.assertNotEquals(null, ceData, 'ceData must not be null');
  }

  @IsTest
  static void testBuildPayloadNoErrorMultipleRecords() {
    Account acc1 = createAccount();
    Account acc2 = createAccount();

    ApplicationForm f1 = createApplicationForm(acc1.Id);
    ApplicationForm f2 = createApplicationForm(acc2.Id);

    Map<Id, String> mapAcc = new Map<Id, String>{
      acc1.Id => acc1.External_Id__c,
      acc2.Id => acc2.External_Id__c
    };

    BrokerCloudEventModel.BrokerCloudEventDataModel ceData = ApplicationFormEventBuilder.buildApplicationFormPayload(
      new List<ApplicationForm>{ f1, f2 },
      mapAcc
    );

    System.assertNotEquals(null, ceData, 'ceData must not be null');
  }

  @IsTest
  static void testBuildPayloadNullAccountMapNoException() {
    Account acc = createAccount();
    ApplicationForm app = createApplicationForm(acc.Id);

    Map<Id, String> emptyMap = new Map<Id, String>();

    BrokerCloudEventModel.BrokerCloudEventDataModel ceData = ApplicationFormEventBuilder.buildApplicationFormPayload(
      new List<ApplicationForm>{ app },
      emptyMap
    );

    System.assertNotEquals(
      null,
      ceData,
      'ceData should not be null when account map is empty'
    );
  }

  private static Account createAccount() {
    Account a = new Account();
    a.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    a.Name = 'Test';
    a.External_Id__c = 'EXT-' + String.valueOf(Math.random()).substring(2, 6);
    return a;
  }

  private static ApplicationForm createApplicationForm(Id accId) {
    ApplicationForm f = new ApplicationForm();
    f.Id = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    f.AccountId = accId;
    f.Application_Number__c =
      'APP' + String.valueOf(Math.random()).substring(2, 6);
    return f;
  }
}
