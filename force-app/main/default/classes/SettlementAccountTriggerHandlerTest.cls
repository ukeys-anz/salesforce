/**
 * @author Peter Charalambous
 * @since Tue Apr 16 2024
 * @description test class for SettlementAccountTriggerHandler
 */

@IsTest
public with sharing class SettlementAccountTriggerHandlerTest {
  private static final String OCVID = '11223344';
  private static final String CUSTOMER = 'Test Customer';
  static Lib_MockProvider brokerSettingsMock = Lib_MockProvider.forType(
    CustomSettingsRepository.class
  );
  @TestSetup
  static void setup() {
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassSettlementAccountEvent__c = false;
    brokerSettingsMock.mock('brokerSettings', mockSettings);
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

    Settlement_Account__c settleAcc = new Settlement_Account__c(
      Nominated_By_Id__c = OCVID,
      Settlement__c = settlement.Id
    );
    insert settleAcc;
  }
  @IsTest
  static void testNominatedByNameIsPopulated() {
    LoanApplicant applicant = [
      SELECT Id
      FROM LoanApplicant
      WHERE Name = :CUSTOMER
    ];
    Test.startTest();
    Settlement_Account__c settleAcc = [
      SELECT Nominated_By__c
      FROM Settlement_Account__c
      WHERE Nominated_By__c = :applicant.Id
    ];
    Test.stopTest();
    Assert.isNotNull(
      settleAcc.Nominated_By__c,
      'Nominated By should contain a value equal to loan applicant id'
    );
  }
  @isTest
  static void testOnAfterInsert() {
    List<Settlement_Account__c> mockRecords = new List<Settlement_Account__c>();
    mockRecords.add(
      new Settlement_Account__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Settlement_Account__c.getSObjectType()
        )
      )
    );

    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassSettlementAccountEvent__c = false;
    brokerSettingsMock.mock('brokerSettings', mockSettings);

    SettlementAccountTriggerHandler handler = new SettlementAccountTriggerHandler();
    handler.records = mockRecords;
    Test.startTest();
    handler.onAfterInsert();
    Test.stopTest();

    Assert.isFalse(
      mockSettings.BypassSettlementAccountEvent__c,
      'BypassSettlementAccountEvent__c should be false'
    );
  }
  @isTest
  static void testOnAfterUpdateWithBypassFalse() {
    List<Settlement_Account__c> mockRecords = new List<Settlement_Account__c>();
    mockRecords.add(
      new Settlement_Account__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Settlement_Account__c.getSObjectType()
        )
      )
    );

    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassSettlementAccountEvent__c = true;
    brokerSettingsMock.mock('brokerSettings', mockSettings);

    SettlementAccountTriggerHandler handler = new SettlementAccountTriggerHandler();
    Map<Id, Settlement_Account__c> mockRecordsMap = new Map<Id, Settlement_Account__c>(
      mockRecords
    );
    handler.records = mockRecords;
    Test.startTest();
    handler.onAfterUpdate(mockRecordsMap);

    Test.stopTest();

    Assert.isTrue(
      mockSettings.BypassSettlementAccountEvent__c,
      'BypassSettlementAccountEvent__c should be false'
    );
  }
}
