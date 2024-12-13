/**
 * @description       : Service layer for GCP event related actions for Case event
 * @author            : Smruti Khobragade | Salesforce
 * @last modified on  : 12-13-2024
 * @last modified by  : Smruti Khobragade |  Salesforce
 **/

public class BrokerRequestHelpCaseEventActions {
  private static final BrokerSettingRepository BROKER_SETTING_REPOSITORY = (BrokerSettingRepository) Lib_InstanceProvider.forType(
    BrokerSettingRepository.class
  );
  public static final Set<SObjectField> REQUEST_HELP_FIELDS = new Set<SObjectField>{
    Case.Status,
    Case.Type,
    Case.Sub_Type__c,
    Case.External_Case_ID__c,
    Case.Subject,
    Case.Description
  };
  @TestVisible
  private static BrokerSettings__c mockBrokerSettings;
  /**
   * @description  Generate and dispatch customer cloud events
   * This function is designed to be a void function as it's the end of the publish process.
   * @param caseList The Case records passed from Trigger.new()
   * @param oldMap  old trigger values
   * @param triggerContext trigger Context
   * @return List<Cloud_Event__e> Cloud Event List
   */
  @TestVisible
  public static List<Cloud_Event__e> publishEventForCase(
    List<Case> caseList,
    Map<Id, Case> oldMap,
    String triggerContext
  ) {
    try {
      //Checking Broker Settings Custom Setting if cloud event publish has to be bypassed
      if (
        BROKER_SETTING_REPOSITORY.getBrokerSettings().BypassCaseSyncEvents__c ==
        true
      ) {
        return null;
      }
      List<Case> filteredCases = ListUtil.filter(caseList, oldMap)
        .isNotNull(Case.Sync_Status__c)
        .oldNotEquals(Case.Sync_Status__c, null)
        .notContains(Case.Sync_Status__c, BrokerConstants.SYNC_STATUS_BLOCKED)
        .contains(Case.Sync_Status__c, BrokerConstants.SYNC_STATUS_BROKER_ORG)
        .equals(Case.RecordTypeId, RTCase.brokerEnquiry)
        .anyChanged(REQUEST_HELP_FIELDS)
        .toList();

      Map<Id, List<BrokerRequestHelpCaseCloudEventModel.MasterNode>> masterNodesByCaseIdMap = generateCaseCEModel(
        filteredCases
      );

      List<BrokerRequestHelpCaseCloudEventModel> cloudEventModels = generateCloudEventModel(
        filteredCases,
        masterNodesByCaseIdMap,
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
   * @description Log publish success events
   * @param successEvents List of success events
   */
  @TestVisible
  private static void logSuccessEvents(List<SObject> successEvents) {
    if (successEvents.isEmpty()) {
      return;
    }
    Logger.info('Case Published' + successEvents.size());
    Logger.saveLog();
  }

  /**
   * @description This function creates a map of Case Id vs related master nodes.
   * @param caseList The case records
   * @return Map<Id, List<BrokerRequestHelpCaseCloudEventModel.MasterNode>> Map of case and list of related master nodes
   */
  @TestVisible
  private static Map<Id, List<BrokerRequestHelpCaseCloudEventModel.MasterNode>> generateCaseCEModel(
    List<Case> caseList
  ) {
    Map<Id, List<BrokerRequestHelpCaseCloudEventModel.MasterNode>> masterNodesByCaseIdMap = new Map<Id, List<BrokerRequestHelpCaseCloudEventModel.MasterNode>>();
    for (Case record : caseList) {
      BrokerRequestHelpCaseCloudEventModel.MasterNode masterNodeObj = BrokerRequestHelpCaseDataCEBuilder.buildCaseNode(
        record
      );

      if (!masterNodesByCaseIdMap.containsKey(record.Id)) {
        masterNodesByCaseIdMap.put(
          record.Id,
          new List<BrokerRequestHelpCaseCloudEventModel.MasterNode>{}
        );
      }
      masterNodesByCaseIdMap.get(record.Id).add(masterNodeObj);
    }
    return masterNodesByCaseIdMap;
  }

  /**
   * @description This function is created a list of BrokerCaseCloudEventModel.
   * @param caseList The case records
   * @param masterNodesByCaseIdMap Map of Case and list of related master nodes
   * @param triggerContext Trigger Context
   * @return List<BrokerCaseCloudEventModel> List of BrokerCaseCloudEventModel
   */
  @TestVisible
  private static List<BrokerRequestHelpCaseCloudEventModel> generateCloudEventModel(
    List<Case> caseList,
    Map<Id, List<BrokerRequestHelpCaseCloudEventModel.MasterNode>> masterNodesByCaseIdMap,
    String triggerContext
  ) {
    List<BrokerRequestHelpCaseCloudEventModel> cloudEventModels = new List<BrokerRequestHelpCaseCloudEventModel>();
    for (Case record : caseList) {
      List<BrokerRequestHelpCaseCloudEventModel.MasterNode> masterNodes = masterNodesByCaseIdMap.get(
        record.Id
      );
      BrokerRequestHelpCaseCloudEventModel cloudEventModel = new BrokerRequestHelpCaseDataCloudEventModel(
        record,
        masterNodes,
        triggerContext
      );
      cloudEventModels.add(cloudEventModel);
    }
    return cloudEventModels;
  }
}
