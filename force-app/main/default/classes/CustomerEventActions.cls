/**
 * @description       : description Service layer for customer event related actions
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 09-17-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public with sharing class CustomerEventActions {
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
      List<Account> accBasedOnOCVVersion = filterAccountsBasedonOCVVersion(
        records,
        oldMap
      );

      List<Account> filteredAccounts = filterAccountsBasedOnSyncStatus(
        accBasedOnOCVVersion,
        oldMap
      );

      Map<Id, List<BrokerCloudEventModel.MasterNode>> accIdVsMasterNodes = generateCustomerCEModelBundle(
        filteredAccounts
      );

      List<BrokerCloudEventModel> cloudEventModels = generateCloudEventModel(
        filteredAccounts,
        accIdVsMasterNodes,
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
   * @description Validate if account sync status is valid or not.
   * @param records The Account records
   * @param oldMap old trigger values
   * @return List<Account> The account records that has a valid sync status.
   */
  @TestVisible
  private static List<Account> filterAccountsBasedOnSyncStatus(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    List<Account> filteredAccounts = new List<Account>();
    for (Account record : records) {
      if (
        record.Sync_Status__c != null &&
        oldMap.get(record.id).Sync_Status__c != null &&
        !record.Sync_Status__c.contains(BrokerConstants.SYNC_STATUS_BLOCKED) &&
        record.Sync_Status__c.contains(BrokerConstants.SYNC_STATUS_BROKER_ORG)
      ) {
        filteredAccounts.add(record);
      }
    }
    return filteredAccounts;
  }

  /**
   * @description  Validate if the account OCV Event Version is valid or not.
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

  /**
   * @description This function creates a map of account Id vs related master nodes.
   * @param records The account records
   * @return Map<Id, List<BrokerCloudEventModel.MasterNode>> Map of account and list of related master nodes
   */
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

  /**
   * @description This function is created a list of BrokerCloudEventModel.
   * @param accounts The account records
   * @param accIdVsMasterNodes Map of account and list of related master nodes
   * @param triggerContext Trigger Context
   * @return List<BrokerCloudEventModel> List of BrokerCloudEventModel
   */
  @TestVisible
  private static List<BrokerCloudEventModel> generateCloudEventModel(
    List<Account> accounts,
    Map<Id, List<BrokerCloudEventModel.MasterNode>> accIdVsMasterNodes,
    String triggerContext
  ) {
    List<BrokerCloudEventModel> cloudEventModels = new List<BrokerCloudEventModel>();
    for (Account record : accounts) {
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
    return cloudEventModels;
  }
}
