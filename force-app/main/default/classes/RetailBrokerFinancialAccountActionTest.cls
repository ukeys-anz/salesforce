/**
 * @author Nakul Kumar
 * @since  01/2025
 * @description  Test class for RetailBrokerFinancialAccountAction
 */
@IsTest
public with sharing class RetailBrokerFinancialAccountActionTest {
  static Lib_MockProvider brokerCodeMergeRepoMock = Lib_MockProvider.forType(
    RetailContactMergeRepository.class
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
   * @description Mock broker codes required for creating map.
   * @param productCode Value of product code
   * @param subProductCode Value of sub product code
   * @param isClassic Classic loan check
   * @return Product2 record
   */
  static Product2 createProduct(
    String productCode,
    String subProductCode,
    Boolean isClassic
  ) {
    Product2 product = new Product2(
      Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      Name = 'Test Product',
      ANZ_Product_Code__c = productCode,
      Is_Retail_Classic_Loan_Product__c = isClassic,
      Sub_Product_Code__c = subProductCode
    );
    return product;
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
    finAccounts[0].Marketing_Code__c = 'HLVAR01';
    finAccounts[0].Assisted_Broker__c = Lib_FakeIdGenerator.getMockId(
      Broker_Code__c.SObjectType
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
    brokerCodeMergeRepoMock.mock(
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
    brokerCodeMergeRepoMock.mock(
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
    Assert.isNotNull(
      recordsToUpdate[0].Assisted_Broker__c,
      'Assisted_Broker should be updated'
    );
  }

  /**
   * @description Test case for getRecordsToUpdateAssistedBroker method.
   * When Assisted_TPMi_Saoisupdated/chnaged and Assistd_brker is null
   */
  @IsTest
  static void testpopulateFinancialAccountAssistedBrokerWhenTPMIIsChangedl() {
    Id newRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    FinServ__FinancialAccount__c newRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      newRecordId
    );
    newRecord.Assisted_Broker_TPMI_SAO__c = 'Broker-TPMISAO-1';
    newRecord.Assisted_Broker__c = null;

    FinServ__FinancialAccount__c oldRecord = newRecord.Clone(
      true,
      true,
      true,
      true
    );
    oldRecord.Assisted_Broker_TPMI_SAO__c = 'oldBroker-TPMISAO-1';
    oldRecord.Assisted_Broker__c = null;

    Map<Id, FinServ__FinancialAccount__c> oldMap = new Map<Id, FinServ__FinancialAccount__c>();
    oldMap.put(oldRecord.Id, oldRecord);

    Broker_Code__c mockBrokerCode = createMockBrokerCode(
      'Broker-TPMISAO-1_Retail',
      newRecord.Id
    );
    brokerCodeMergeRepoMock.mock(
      'getBrokerIdentifiers',
      new List<Broker_Code__c>{ mockBrokerCode }
    );
    Test.startTest();

    List<FinServ__FinancialAccount__c> recordsToUpdate = RetailBrokerFinancialAccountAction.populateFinancialAccountAssistedBroker(
      new List<FinServ__FinancialAccount__c>{ newRecord },
      oldMap
    );
    Test.stopTest();

    Assert.areEqual(1, recordsToUpdate.size(), 'One record should be updated');
    Assert.isNotNull(
      recordsToUpdate[0].Assisted_Broker__c,
      'Assisted_Broker should be updated'
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

  @isTest
  static void testfilterPlusFinancialAccounts() {
    Id newRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    FinServ__FinancialAccount__c newRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      newRecordId
    );
    newRecord.Assisted_Broker__c = Lib_FakeIdGenerator.getMockId(
      Broker_Code__c.SObjectType
    );
    newRecord.Marketing_Code__c = 'HLVAR01';
    Test.startTest();
    List<FinServ__FinancialAccount__c> validRecords = RetailBrokerFinancialAccountAction.filterPlusFinancialAccounts(
      new List<FinServ__FinancialAccount__c>{ newRecord },
      new Set<string>{ 'HLVAR01', 'HLFXD01' }
    );
    Test.stopTest();
    Assert.areEqual(validRecords.size(), 1, 'One record should be valid');
    Assert.areEqual(
      newRecord.Id,
      validRecords[0].Id,
      'Returned record should match the input record'
    );
    Assert.isTrue(
      new Set<String>{ 'HLVAR01', 'HLFXD01' }
        .contains(validRecords[0].Marketing_Code__c),
      'Marketing code should be in the allowed set'
    );
  }

  @isTest
  static void testNegativefilterPlusFinancialAccounts() {
    Test.startTest();
    List<FinServ__FinancialAccount__c> emptyResult = RetailBrokerFinancialAccountAction.filterPlusFinancialAccounts(
      new List<FinServ__FinancialAccount__c>(),
      new Set<String>{ 'HLVAR01', 'HLFXD01' }
    );
    Test.stopTest();
    Assert.isTrue(
      emptyResult.isEmpty(),
      'Empty input list should return empty result'
    );
  }

  @isTest
  static void testFilterClassicFinancialAccounts() {
    Id newRecordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Product2 product = createProduct('ANZX', 'ANZ198', true);

    FinServ__FinancialAccount__c validRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      newRecordId
    );
    validRecord.Assisted_Broker__c = Lib_FakeIdGenerator.getMockId(
      Broker_Code__c.SObjectType
    );
    String jsonValid = JSON.serialize(validRecord);
    Map<String, Object> validMap = (Map<String, Object>) JSON.deserializeUntyped(
      jsonValid
    );
    validMap.put('Sub_product_Code_Display__c', 'ANZ198');
    String validJson = JSON.serialize(validMap);
    FinServ__FinancialAccount__c updatedValidRecord = (FinServ__FinancialAccount__c) JSON.deserialize(
      validJson,
      FinServ__FinancialAccount__c.class
    );

    FinServ__FinancialAccount__c invalidRecord = createFinancialAccounts(
      RTFinancialAccount.bankAccount,
      Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
    String jsonInvalid = JSON.serialize(invalidRecord);
    Map<String, Object> invalidMap = (Map<String, Object>) JSON.deserializeUntyped(
      jsonInvalid
    );
    invalidMap.put('Sub_product_Code_Display__c', 'INVALID198');
    String invalidJson = JSON.serialize(invalidMap);
    FinServ__FinancialAccount__c updatedInvalidRecord = (FinServ__FinancialAccount__c) JSON.deserialize(
      invalidJson,
      FinServ__FinancialAccount__c.class
    );

    List<FinServ__FinancialAccount__c> allRecords = new List<FinServ__FinancialAccount__c>{
      updatedValidRecord,
      updatedInvalidRecord
    };

    QueryProducts.productsById = new Map<Id, Product2>{ product.Id => product };

    Test.startTest();
    List<FinServ__FinancialAccount__c> validRecords = RetailBrokerFinancialAccountAction.filterClassicFinancialAccounts(
      allRecords,
      new Set<string>{ 'ANZ198' }
    );
    Test.stopTest();
    Assert.areEqual(validRecords.size(), 1, 'One record should be valid');
    Assert.areEqual(
      updatedValidRecord.Id,
      validRecords[0].Id,
      'Returned record should match the input record'
    );
    Assert.areEqual(
      'ANZ198',
      validRecords[0].Sub_product_Code_Display__c,
      'Sub product code should be ANZ198'
    );
  }

  @isTest
  static void testNegativeFilterClassicFinancialAccounts() {
    Test.startTest();
    List<FinServ__FinancialAccount__c> filtered = RetailBrokerFinancialAccountAction.filterClassicFinancialAccounts(
      new List<FinServ__FinancialAccount__c>(),
      new Set<String>{ 'ANZ198' }
    );
    Test.stopTest();
    Assert.areEqual(0, filtered.size(), 'No records should be returned');
  }
}
