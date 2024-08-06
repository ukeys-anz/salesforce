/**
 * @description       : description Service layer for GCP event related actions for customer event
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 08-06-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public with sharing class CustomerGCPActions {
  public static final String GCP_EVENT_ADD = 'add';
  public static final String GCP_EVENT_UPDATE = 'update';
  @TestVisible
  private static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  @TestVisible
  private static final String SYNC_STATUS_BLOCKED = 'Blocked';

  /**
   * @description  Generate and dispatch customer GCP cloud events
   * This function is designed to be a void function as it's the end of the publish process.
   * @param records The Account records passed from Trigger.new()
   * @param oldMap  old trigger values
   * @param triggerContext trigger Context
   */
  @TestVisible
  public static void publishGCPEventForCustomers(
    List<Account> records,
    Map<Id, Account> oldMap,
    String triggerContext
  ) {
    List<Account> accBasedOnOCVVersion = filterAccountsBasedonOCVVersion(
      records,
      oldMap
    );

    List<Account> filteredAccounts = filterAccountsBasedOnSyncStatus(
      accBasedOnOCVVersion
    );

    if (filteredAccounts.isEmpty()) {
      return;
    }

    Map<Id, List<BrokerCloudEventModel.MasterNode>> accIdVsMasterNodes = generateCustomerCEModelBundle(
      filteredAccounts
    );

    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();
    for (Account record : records) {
      List<BrokerCloudEventModel.MasterNode> masterNodes = accIdVsMasterNodes.get(
        record.id
      );
      BrokerCloudEventModel cloudEventModel = new CustomerDataCloudEventModel(
        record,
        masterNodes,
        triggerContext
      );
      cloudEventModels.add(cloudEventModel);
    }
    List<SObject> successPublishedEvents = CloudEventController.publishCloudEvents(
      cloudEventModels
    );

    logSuccessEvents(successPublishedEvents);
  }

  /**
   * @description  Generate and dispatch customer GCP cloud events
   * This function is designed to be a void function as it's the end of the publish process.
   * @param records The Account records
   * @return List<Account> The account records that has a valid sync status.
   */
  @TestVisible
  private static List<Account> filterAccountsBasedOnSyncStatus(
    List<Account> records
  ) {
    List<Account> filteredAccounts = new List<Account>();
    for (Account record : records) {
      if (
        record.Sync_Status__c != null &&
        !record.Sync_Status__c.contains(SYNC_STATUS_BLOCKED) &&
        record.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG)
      ) {
        filteredAccounts.add(record);
      }
    }
    return filteredAccounts;
  }

  /**
   * @description  Validate if the account OCV Event Version is valid or not.
   * Returns true if the version is valid.
   * @param records Account records.
   * @param oldMap old trigger values
   * @return List<Account> The account records that has a valid OCV Version.
   */
  @TestVisible
  private static List<Account> filterAccountsBasedonOCVVersion(
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

  @TestVisible
  private static Map<Id, List<BrokerCloudEventModel.MasterNode>> generateCustomerCEModelBundle(
    List<Account> records
  ) {
    Map<Id, List<BrokerCloudEventModel.MasterNode>> accIdVsMasterNodes = new Map<Id, List<BrokerCloudEventModel.MasterNode>>();
    for (Account record : records) {
      BrokerCloudEventModel.MasterNode masterNodeObj = CustomerDataCEBuilder.buildAccountNode(
        record
      );
      if (!accIdVsMasterNodes.containsKey(record.id)) {
        accIdVsMasterNodes.put(
          record.id,
          new List<BrokerCloudEventModel.MasterNode>{}
        );
      }
      accIdVsMasterNodes.get(record.id).add(masterNodeObj);
    }
    return accIdVsMasterNodes;
  }
}
