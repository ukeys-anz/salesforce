/**
 * @author Nakul Kumar
 * @since  01/2025
 * @description  Test class for RetailBrokerFinancialAccountAction
 */
@IsTest
public with sharing class RetailBrokerFinancialAccountActionTest {
  static Lib_MockProvider brokerCodeRepoMock = Lib_MockProvider.forType(
    BrokerCodeRepository.class
  );
  /**
   * @description creating Financial Account records for testing
   * @param recordTypeId Financial Account recordTypeId
   * @param accountId primary owner of the fin account record
   * @return Financial Account Records
   */
  static FinServ__FinancialAccount__c createFinancialAccounts(
    Id recordTypeId,
    Id accountId
  ) {
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.RecordTypeId = recordTypeId;
    financialAccount.Name = 'Everyday Account_20010101';
    financialAccount.FinServ__PrimaryOwner__c = accountId;
    financialAccount.Account_Key__c = 'AccountKey_20010101';
    financialAccount.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SObjectType
    );
    return financialAccount;
  }

  /**
   * @description set mock parent Account records for testing
   * @return Id account's fake record id to be used as a primary owner of test financial accounts
   */
  static Id setMockParentAccounts() {
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    accnt.Name = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.External_Id__c = 'ExID_20010101';
    Lib_MockProvider.forType(AccountRepository.class)
      .mock(
        'getAccountsWithExternalId',
        new Map<Id, Account>{ accnt.Id => accnt }
      );
    return accnt.Id;
  }
  /**
   * @description Mock broker codes required for creating map.
   * @param brokerIdentifier
   * @param brokerName
   * @return List of Broker_Code__c
   */
  private static Broker_Code__c createMockBrokerCode(
    String brokerIdentifier,
    Id brokerName
  ) {
    Broker_Code__c brokerCode = new Broker_Code__c();
    brokerCode.External_Id__c = brokerIdentifier;
    brokerCode.Broker_Name__c = brokerName;
    return brokerCode;
  }

  /**
   * @description test function to test RetailBrokerFinancialAccountAction.publishContractEvents
   * Assertion is made against the count of the cloud events generated which should be equal to the number of records provided to the function
   */
  @IsTest
  static void testPublishContractEvents() {
    Id accountId = setMockParentAccounts();
    List<FinServ__FinancialAccount__c> finAccounts = new List<FinServ__FinancialAccount__c>();
    finAccounts.add(
      createFinancialAccounts(RTFinancialAccount.bankAccount, accountId)
    );
    finAccounts.add(
      createFinancialAccounts(RTFinancialAccount.bankAccount, null)
    );
    Integer cloudEventsBefore = CloudEventController.cloudEvents == null
      ? 0
      : CloudEventController.cloudEvents.size();
    Test.startTest();
    RetailBrokerFinancialAccountAction.publishContractEvents(
      finAccounts,
      'add'
    );
    Test.stopTest();
    Integer cloudEventsAfter = CloudEventController.cloudEvents == null
      ? 0
      : CloudEventController.cloudEvents.size();
    Assert.areEqual(
      cloudEventsBefore + 1,
      cloudEventsAfter,
      'A cloud event should be generated'
    );
  }

  /* Assisted_Broker and Assisted_brokerTPMI_Sao is null */
  @istest
  static void testpopulateFinancialAccountAssistedBrokerWhenTPMIIsNull() {
    Id newRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, FinServ__FinancialAccount__c> oldMap = new Map<Id, FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c newRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      newRecordId
    );
    Broker_Code__c mockBrokerCode = createMockBrokerCode(
      'Broker-TPMISAO-1_Retail',
      newRecord.Id
    );
    brokerCodeRepoMock.mock(
      'getBrokerIdentifiers',
      new List<Broker_Code__c>{ mockBrokerCode }
    );
    Test.startTest();

    List<FinServ__FinancialAccount__c> recordsToUpdate = RetailBrokerFinancialAccountAction.populateFinancialAccountAssistedBroker(
      new List<FinServ__FinancialAccount__c>{ newRecord },
      oldMap
    );
    Test.stopTest();

    Assert.areEqual(0, recordsToUpdate.size(), 'No records should be updated');
  }

  /* Assisted_Broker is null and Assisted_brokerTPMI_Sao is not null */
  @istest
  static void testpopulateFinancialAccountAssistedBrokerWhenTPMIIsNotNull() {
    Id newRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, FinServ__FinancialAccount__c> oldMap = new Map<Id, FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c newRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      newRecordId
    );
    Broker_Code__c mockBrokerCode = createMockBrokerCode(
      'Broker-TPMISAO-1_Retail',
      newRecord.Id
    );
    brokerCodeRepoMock.mock(
      'getBrokerIdentifiers',
      new List<Broker_Code__c>{ mockBrokerCode }
    );
    newRecord.Assisted_Broker_TPMI_SAO__c = 'Broker-TPMISAO-1';
    newRecord.Assisted_Broker__c = null;

    Test.startTest();
    List<FinServ__FinancialAccount__c> recordsToUpdate = RetailBrokerFinancialAccountAction.populateFinancialAccountAssistedBroker(
      new List<FinServ__FinancialAccount__c>{ newRecord },
      oldMap
    );
    Test.stopTest();

    Assert.areEqual(1, recordsToUpdate.size(), 'record should be updated');
  }

  /**
   * @description Test case for getRecordsToUpdateAssistedBroker method.
   * When Assisted_TPMi_Saoisupdated/chnaged and Assistd_brker is null
   */
  @IsTest
  static void testGetRecordsToUpdateAssistedBroker() {
    Id newRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    FinServ__FinancialAccount__c newRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      newRecordId
    );
    newRecord.Assisted_Broker_TPMI_SAO__c = 'Broker-TPMISAO-1';
    newRecord.Assisted_Broker__c = null;

    FinServ__FinancialAccount__c oldRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      newRecordId
    );
    oldRecord.Assisted_Broker_TPMI_SAO__c = 'oldBroker-TPMISAO-1';
    oldRecord.Assisted_Broker__c = null;

    Map<Id, FinServ__FinancialAccount__c> oldMap = new Map<Id, FinServ__FinancialAccount__c>();
    oldMap.put(oldRecord.Id, oldRecord);

    Test.startTest();

    List<FinServ__FinancialAccount__c> recordsToUpdate = RetailBrokerFinancialAccountAction.getRecordsToUpdateAssistedBroker(
      new List<FinServ__FinancialAccount__c>{ newRecord },
      oldMap
    );
    Test.stopTest();

    Assert.areEqual(1, recordsToUpdate.size(), 'One record should be updated');
    Assert.areEqual(
      'Broker-TPMISAO-1',
      recordsToUpdate[0].Assisted_Broker_TPMI_SAO__c,
      'Assisted_Broker_TPMI_SAO__c should be updated'
    );
  }

  /**
   * @description Test case for createBrokerIdentifierMap method.
   */
  @IsTest
  static void testCreateBrokerIdentifierMap() {
    Id newRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    FinServ__FinancialAccount__c newRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      newRecordId
    );
    newRecord.Assisted_Broker_TPMI_SAO__c = 'Broker-TPMISAO-1';
    Test.startTest();
    Map<String, String> brokerIdentifierMap = RetailBrokerFinancialAccountAction.createBrokerIdentifierMap(
      new List<FinServ__FinancialAccount__c>{ newRecord },
      'Retail'
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      brokerIdentifierMap.size(),
      'One broker identifier should be mapped'
    );
    Assert.areEqual(
      'Broker-TPMISAO-1_Retail',
      brokerIdentifierMap.get('AccountKey_20010101'),
      'Broker identifier should be mapped correctly'
    );
  }
}
