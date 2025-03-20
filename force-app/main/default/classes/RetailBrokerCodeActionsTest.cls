@isTest
public with sharing class RetailBrokerCodeActionsTest {
  static Lib_MockProvider brokerCodeRepoMock = Lib_MockProvider.forType(
    BrokerCodeRepository.class
  );
  /**
   * @description Creates mock Broker_Code__c records.
   * @param brokerIdentifiers List of broker identifiers.
   * @param brokerNames List of broker names (contact IDs).
   * @return List of Broker_Code__c records.
   */
  private static List<Broker_Code__c> createMockBrokerCodes(
    List<String> brokerIdentifiers,
    List<Id> brokerNames
  ) {
    List<Broker_Code__c> brokerCodes = new List<Broker_Code__c>();
    for (Integer i = 0; i < brokerIdentifiers.size(); i++) {
      Broker_Code__c brokerCode = new Broker_Code__c();
      brokerCode.External_Id__c = brokerIdentifiers[i];
      brokerCode.Broker_Name__c = brokerNames[i];
      brokerCodes.add(brokerCode);
    }
    return brokerCodes;
  }

  /**
   * @description Creates mock FinServ__FinancialAccount__c records.
   * @param ids List of record IDs.
   * @param assistedBrokerTpmiSao List of Assisted_Broker_TPMI_SAO__c values.
   * @param assistedBroker List of Assisted_Broker__c values.
   * @return List of FinServ__FinancialAccount__c records.
   */
  private static List<FinServ__FinancialAccount__c> createMockFinancialAccounts(
    List<Id> ids,
    List<String> assistedBrokerTpmiSao,
    List<String> assistedBroker
  ) {
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    for (Integer i = 0; i < ids.size(); i++) {
      FinServ__FinancialAccount__c account = new FinServ__FinancialAccount__c();
      account.Id = ids[i];
      account.Assisted_Broker_TPMI_SAO__c = assistedBrokerTpmiSao[i];
      account.Assisted_Broker__c = assistedBroker[i];
      account.Account_Key__c = 'AccountKey' + i;
      financialAccounts.add(account);
    }
    return financialAccounts;
  }

  /**
   * @description Tests the getBrokerCodeToContactMap method.
   */
  @isTest
  static void testGetBrokerCodeToContactMap() {
    Id newRecordId1 = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SObjectType
    );
    Id newRecordId2 = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SObjectType
    );
    // Create a list of broker identifiers
    Set<String> brokerIdentifiers = new Set<String>{
      'Broker-TPMISAO-1_Retail',
      'Broker-TPMISAO-2_Retail'
    };
    // Create a list of broker names (contact IDs)
    List<Id> brokerNames = new List<Id>{ newRecordId1, newRecordId2 };
    List<Broker_Code__c> brokerCodes = createMockBrokerCodes(
      new List<String>(brokerIdentifiers),
      brokerNames
    );
    brokerCodeRepoMock.mock('getBrokerIdentifiers', brokerCodes);

    Test.startTest();
    Map<String, Id> brokerCodeToContactMap = RetailBrokerCodeActions.getBrokerCodeExIDToContactMap(
      brokerIdentifiers
    );
    Test.stopTest();

    Assert.areEqual(
      2,
      brokerCodeToContactMap.size(),
      'Two broker codes should be mapped to contacts'
    );
    Assert.areEqual(
      newRecordId1,
      brokerCodeToContactMap.get('Broker-TPMISAO-1_Retail'),
      'Broker code should be mapped to contact correctly'
    );
    Assert.areEqual(
      newRecordId2,
      brokerCodeToContactMap.get('Broker-TPMISAO-2_Retail'),
      'Broker code should be mapped to contact correctly'
    );
  }
}
