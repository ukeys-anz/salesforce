/**
 * @description       : Service layer for GCP event related actions for customer event
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 10-09-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public with sharing class CustomerEventActions {
  public static final String CUSTOMER_EVENT_UPDATE = 'update';

  /**
   * @description To set the mock broker settings
   * @return The BrokerSettings__c custom setting
   */
  @TestVisible
  private static BrokerSettings__c brokerSettings() {
    if (mockBrokerSettings != null) {
      return mockBrokerSettings;
    }
    return BrokerSettings__c.getOrgDefaults();
  }

  @TestVisible
  private static BrokerSettings__c mockBrokerSettings;
  /**
   * @description  Generate and dispatch customer cloud events
   * This function is designed to be a void function as it's the end of the publish process.
   * @param records The Account records passed from Trigger.new()
   * @param oldMap  old trigger values
   * @param triggerContext trigger Context
   * @return List<Cloud_Event__e> Cloud Event List
   */
  @TestVisible
  public static List<Cloud_Event__e> publishEventForCustomers(
    List<Account> records,
    Map<Id, Account> oldMap,
    String triggerContext
  ) {
    try {
      //Checking Broker Settings Custom Setting if cloud event publish has to be bypassed
      if (brokerSettings().BypassCustomerSyncEvents__c == true) {
        return null;
      }
      List<Account> accBasedOnOCVVersion = filterOCVVersionUpdate(
        records,
        oldMap
      );

      List<Account> filteredAccounts = ListUtil.filter(
          accBasedOnOCVVersion,
          oldMap
        )
        .isNotNull(Account.Sync_Status__c)
        .oldNotEquals(Account.Sync_Status__c, null)
        .notContains(
          Account.Sync_Status__c,
          BrokerConstants.SYNC_STATUS_BLOCKED
        )
        .contains(
          Account.Sync_Status__c,
          BrokerConstants.SYNC_STATUS_BROKER_ORG
        )
        .toList();

      Map<Id, List<BrokerCloudEventModel.MasterNode>> masterNodesByAccountIdMap = generateCustomerCEModel(
        filteredAccounts
      );

      List<BrokerCloudEventModel> cloudEventModels = generateCloudEventModel(
        filteredAccounts,
        masterNodesByAccountIdMap,
        triggerContext
      );
      List<Cloud_Event__e> successPublishedEvents = CloudEventController.publishCloudEvents(
        cloudEventModels
      );

      logSuccessEvents(successPublishedEvents);
      return successPublishedEvents;
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      return null;
    }
  }

  /**
   * @description  Validate if the account OCV Event Version is valid or not.
   * @param records Account records.
   * @param oldMap old trigger values
   * @return List<Account> The account records that has a valid OCV Version.
   */
  @TestVisible
  private static List<Account> filterOCVVersionUpdate(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    List<Account> filteredAccounts = new List<Account>();
    for (Account record : records) {
      Account oldRecord = oldMap.get(record.id);
      if (
        record.OCV_Event_Version__c != null &&
        record.OCV_Event_Version__c > 0 &&
        record.OCV_Event_Version__c >= oldRecord.OCV_Event_Version__c
      ) {
        filteredAccounts.add(record);
      }
    }
    return filteredAccounts;
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
      'Customer Published' + successEvents.size() + 'Account Cloud Events'
    );
    Logger.saveLog();
  }

  /**
   * @description This function creates a map of account Id vs related master nodes.
   * @param records The account records
   * @return Map<Id, List<BrokerCloudEventModel.MasterNode>> Map of account and list of related master nodes
   */
  @TestVisible
  private static Map<Id, List<BrokerCloudEventModel.MasterNode>> generateCustomerCEModel(
    List<Account> records
  ) {
    Map<Id, List<BrokerCloudEventModel.MasterNode>> masterNodesByAccountIdMap = new Map<Id, List<BrokerCloudEventModel.MasterNode>>();
    for (Account record : records) {
      BrokerCloudEventModel.MasterNode masterNodeObj = CustomerDataCEBuilder.buildAccountNode(
        record
      );
      if (!masterNodesByAccountIdMap.containsKey(record.id)) {
        masterNodesByAccountIdMap.put(
          record.id,
          new List<BrokerCloudEventModel.MasterNode>{}
        );
      }
      masterNodesByAccountIdMap.get(record.id).add(masterNodeObj);
    }
    return masterNodesByAccountIdMap;
  }

  /**
   * @description This function is created a list of BrokerCloudEventModel.
   * @param accounts The account records
   * @param masterNodesByAccountIdMap Map of account and list of related master nodes
   * @param triggerContext Trigger Context
   * @return List<BrokerCloudEventModel> List of BrokerCloudEventModel
   */
  @TestVisible
  private static List<BrokerCloudEventModel> generateCloudEventModel(
    List<Account> accounts,
    Map<Id, List<BrokerCloudEventModel.MasterNode>> masterNodesByAccountIdMap,
    String triggerContext
  ) {
    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();
    for (Account record : accounts) {
      List<BrokerCloudEventModel.MasterNode> masterNodes = masterNodesByAccountIdMap.get(
        record.id
      );
      BrokerCloudEventModel cloudEventModel = new CustomerDataCloudEventModel(
        record,
        masterNodes,
        triggerContext
      );
      cloudEventModels.add(cloudEventModel);
    }
    return cloudEventModels;
  }
}
