/**
 * @author Nakul Kumar
 * @since 01/2025
 * @description the action class for trigger handler RetailBrokerFinAccountTriggerHandler to perform actions based on FinServ__FinancialAccount__c records corresponding to Broker domain
 * @runTests RetailBrokerFinancialAccountActionTest
 */
public with sharing class RetailBrokerFinancialAccountAction {
  private static final AccountRepository ACCOUNT_REPOSITORY = (AccountRepository) Lib_InstanceProvider.forType(
    AccountRepository.class
  );
  private static final BrokerCodeRepository BROKER_CODE_REPOSITORY = (BrokerCodeRepository) Lib_InstanceProvider.forType(
    BrokerCodeRepository.class
  );

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param financialAccounts list of Financial Account Records
   * @param eventType insert/update
   */
  public static void publishContractEvents(
    List<FinServ__FinancialAccount__c> financialAccounts,
    String eventType
  ) {
    Set<Id> accountIds = ListUtil.getIds(
      financialAccounts,
      FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c
    );
    Map<Id, Account> accountIdsVsAccounts = ACCOUNT_REPOSITORY.getAccountsWithExternalId(
      accountIds
    );
    Map<Id, Account> finAccountIdsVsAccounts = getFinancialAccountIdsAndAccounts(
      financialAccounts,
      accountIdsVsAccounts
    );
    List<BrokerDataCloudEventModel> cloudEventModels = generateCotractEventModel(
      financialAccounts,
      finAccountIdsVsAccounts,
      eventType
    );
    List<SObject> successPublishedEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );
    logSuccessEvents(successPublishedEvents);
  }

  /**
   * @description get the map of Financial Account Id and parent Account
   * @param financialAccounts List of Financial Account Records
   * @param accountIdsVsAccounts Map of account ids and account records
   * @return Map<Id, Account> map of financial account ids and their parent accounts
   */
  private static Map<Id, Account> getFinancialAccountIdsAndAccounts(
    List<FinServ__FinancialAccount__c> financialAccounts,
    Map<Id, Account> accountIdsVsAccounts
  ) {
    Map<Id, Account> finAccountIdsVsAccounts = new Map<Id, Account>();
    for (FinServ__FinancialAccount__c record : financialAccounts) {
      finAccountIdsVsAccounts.put(
        record.Id,
        accountIdsVsAccounts.get(record.FinServ__PrimaryOwner__c)
      );
    }
    return finAccountIdsVsAccounts;
  }

  /**
   * @description Publish event for Financial account creation/update in retail broker domain
   * @param financialAccounts Financial Account records
   * @param finAccountIdsVsAccounts map of financial account ids and their parent accounts
   * @param eventType insert/update
   * @return List<BrokerDataCloudEventModel> list of BrokerDataCloudEventModel
   */
  private static List<BrokerDataCloudEventModel> generateCotractEventModel(
    List<FinServ__FinancialAccount__c> financialAccounts,
    Map<Id, Account> finAccountIdsVsAccounts,
    String eventType
  ) {
    List<BrokerDataCloudEventModel> cloudEventModels = new List<BrokerDataCloudEventModel>();
    for (FinServ__FinancialAccount__c financialAccount : financialAccounts) {
      if (finAccountIdsVsAccounts.get(financialAccount.Id) == null) {
        continue;
      }
      List<BrokerCloudEventModel.MasterNode> masterNodes = generateContractEventMasterNode(
        financialAccount,
        finAccountIdsVsAccounts.get(financialAccount.Id),
        eventType
      );
      BrokerDataCloudEventModel eventModel = new BrokerDataCloudEventModel(
        financialAccount,
        masterNodes,
        eventType
      );
      cloudEventModels.add(eventModel);
    }
    return cloudEventModels;
  }

  /**
   * @description Publish event for Financial account creation/update in retail broker domain
   * @param financialAccount Financial Account record
   * @param primaryAccount parent Account record
   * @param eventType insert/update
   * @return BrokerDataCloudEventModel
   */
  private static List<BrokerCloudEventModel.MasterNode> generateContractEventMasterNode(
    FinServ__FinancialAccount__c financialAccount,
    Account primaryAccount,
    String eventType
  ) {
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    masterNodes.add(
      BrokerCloudEventBuilder.buildFinancialAccountNode(
        financialAccount,
        primaryAccount
      )
    );
    return masterNodes;
  }

  /**
   * @description populate Assisted Broker for Retail Financial accounts
   * When Assisted_Broker is null or Assisted_brokerTPMI_Sao is not null and it is changed.
   * @param records records to populate assisted broker
   * @param oldMap old records
   * @return List<FinServ__FinancialAccount__c> updated records
   */

  public static List<FinServ__FinancialAccount__c> populateFinancialAccountAssistedBroker(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    List<FinServ__FinancialAccount__c> recordsToUpdate = getRecordsToUpdateAssistedBroker(
      records,
      oldMap
    );
    return processAssistedBrokerPopulation(recordsToUpdate, 'Retail');
  }

  /**
   * @description populate Assisted Broker for Retail Residential Loan Applications
   * @param records records to update
   * @param oldMap old records
   * @return List<FinServ__FinancialAccount__c> updated records
   */
  @TestVisible
  private static List<FinServ__FinancialAccount__c> getRecordsToUpdateAssistedBroker(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    List<FinServ__FinancialAccount__c> recordsToUpdate = new List<FinServ__FinancialAccount__c>();
    for (FinServ__FinancialAccount__c record : records) {
      FinServ__FinancialAccount__c oldRecord = oldMap.get(record.Id);
      if (record.Assisted_Broker_TPMI_SAO__c == null) {
        continue;
      }

      if (
        oldRecord != null &&
        record.Assisted_Broker_TPMI_SAO__c ==
        oldRecord.Assisted_Broker_TPMI_SAO__c
      ) {
        continue;
      }
      recordsToUpdate.add(record);
    }
    return recordsToUpdate;
  }

  /**
   * @description  method to populate Assisted Broker
   * @param records List of records to update
   * @param accreditationType it will be retail by default
   * @return List<FinServ__FinancialAccount__c> updated records
   */
  public static List<FinServ__FinancialAccount__c> processAssistedBrokerPopulation(
    List<FinServ__FinancialAccount__c> records,
    String accreditationType
  ) {
    // Create a map of account keys to broker identifiers
    Map<String, String> extIdToBrokerIdMap = createBrokerIdentifierMap(
      records,
      accreditationType
    );
    // Convert the values of extIdToBrokerIdMap to a Set<String>
    Set<String> brokerIdentifiers = new Set<String>(
      extIdToBrokerIdMap.values()
    );
    Map<String, Broker_Code__c> brokerCodeToContactMap = (Map<String, Broker_Code__c>) Listutil.mapBy(
      BROKER_CODE_REPOSITORY.getBrokerIdentifiers(brokerIdentifiers),
      Broker_Code__c.External_Id__c
    );
    // Populate the Assisted_Broker__c field for each record
    for (FinServ__FinancialAccount__c record : records) {
      String brokerIdentifier = extIdToBrokerIdMap.get(record.Account_Key__c);
      if (brokerIdentifier == null) {
        continue;
      }
      record.Assisted_Broker__c = brokerCodeToContactMap.get(brokerIdentifier)
        ?.Broker_Name__c;
    }
    return records;
  }
  /**
   * @description Create a map of account keys to broker identifiers.
   * @param records List of records.
   * @param accreditationType Type of accreditation.
   * @return Map of FA account key  to Broker identifier
   */
  @TestVisible
  private static Map<String, String> createBrokerIdentifierMap(
    List<FinServ__FinancialAccount__c> records,
    String accreditationType
  ) {
    Map<String, String> extIdToBrokerIdMap = new Map<String, String>();
    for (FinServ__FinancialAccount__c record : records) {
      String brokerIdentifier =
        record.Assisted_Broker_TPMI_SAO__c +
        '_' +
        accreditationType;
      extIdToBrokerIdMap.put(record.Account_Key__c, brokerIdentifier);
    }
    return extIdToBrokerIdMap;
  }
  /**
   * @description Log publish success events
   * @param successEvents List of success events
   */
  @TestVisible
  private static void logSuccessEvents(List<SObject> successEvents) {
    if (successEvents.isEmpty()) {
      return;
    }
    Logger.info(
      'Financial Account Published' + successEvents.size() + ' Cloud Events'
    );
  }
}
