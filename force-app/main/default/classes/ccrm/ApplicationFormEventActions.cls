/**
 * @description Handles publishing of ApplicationForm events to the cloud.
 *              Publishes one Cloud_Event__e per ApplicationForm record
 *              when certain conditions (such as Assisted_Broker__c change) are met.
 * @author      Akanksha Kulkarni
 * @date        2025-11-10
 */
public with sharing class ApplicationFormEventActions {
  private static final ApplicationFormEventRepository APPLICATIONFORM_EVENT_REPOSITORY = (ApplicationFormEventRepository) Lib_InstanceProvider.forType(
    ApplicationFormEventRepository.class
  );

  @TestVisible
  public static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  @TestVisible
  public static final String SYNC_STATUS_BLOCKED = 'Blocked';

  /**
   * @description Publishes one event per ApplicationForm record.
   *              The method detects changes in the Assisted_Broker__c field for updates
   *              and only publishes events when valid conditions are met (e.g., Sync_Status__c = 'Broker Org').
   * @param records     The list of ApplicationForm records being inserted or updated.
   * @param oldMap      The map of old ApplicationForm records (only available in update context).
   * @param eventContext The event context (e.g., 'applicationformadd').
   * @return A list of published Cloud_Event__e records.
   *
   */
  public static List<Cloud_Event__e> publishSimpleApplicationFormEvent(
    List<ApplicationForm> records,
    Map<Id, ApplicationForm> oldMap,
    String eventContext
  ) {
    List<Cloud_Event__e> allPublishedEvents = new List<Cloud_Event__e>();

    try {
      // Build Payload
      Map<ApplicationForm, BrokerCloudEventModel.BrokerCloudEventDataModel> payloadMap = buildPayload(
        records,
        oldMap,
        eventContext
      );

      if (payloadMap.isEmpty()) {
        return allPublishedEvents;
      }

      // Step 4: Publish one event per record
      List<BrokerCloudEventModel> lstBrokerCloudEventModel = new List<BrokerCloudEventModel>();
      for (ApplicationForm app : payloadMap.keySet()) {
        BrokerCloudEventModel.BrokerCloudEventDataModel ceData = payloadMap.get(
          app
        );

        BrokerCloudEventModel cloudEventModel = new BrokerCloudEventModel();
        cloudEventModel.ce_xtargets =
          'ApplicationForm/' + app.Source_System_Id__c;
        cloudEventModel.ce_type =
          System.Label.ANZX_applicationform_event_ce_type + eventContext;
        cloudEventModel.ce_source = System.Label.ANZX_applicationform_event_ce_source;
        cloudEventModel.ce_traceparent = '';
        cloudEventModel.ce_subject =
          'ApplicationForm/' + app.Source_System_Id__c;
        cloudEventModel.ce_partitionkey =
          'ApplicationForm/' + app.Source_System_Id__c;
        cloudEventModel.ce_dataschema = System.Label.ANZX_Main_Event_ApplicationForm_Proto_Data_Schema;
        cloudEventModel.ce_data = ceData;

        lstBrokerCloudEventModel.add(cloudEventModel);
      }

      List<SObject> published = CloudEventController.publishCloudEvents(
        lstBrokerCloudEventModel
      );

      CloudEventController.logSuccessEvents(
        (List<Cloud_Event__e>) published,
        'ApplicationForm Event from ApplicationFormTriggerHandler'
      );

      allPublishedEvents.addAll((List<Cloud_Event__e>) published);
    } catch (Exception e) {
      Logger.error(
        'Error in publishSimpleApplicationFormEvent: ' + e.getMessage(),
        e
      );
      Logger.saveLog();
    }

    return allPublishedEvents;
  }

  /**
   * @description Builds the payload.
   * @param records     The list of ApplicationForm records being inserted or updated.
   * @param oldMap      The map of old ApplicationForm records (only available in update context).
   * @param eventContext The event context (e.g., 'applicationformadd').
   * @return buildPayload payload structure.
   *
   */
  @TestVisible
  private static Map<ApplicationForm, BrokerCloudEventModel.BrokerCloudEventDataModel> buildPayload(
    List<ApplicationForm> records,
    Map<Id, ApplicationForm> oldMap,
    String eventContext
  ) {
    Map<ApplicationForm, BrokerCloudEventModel.BrokerCloudEventDataModel> results = new Map<ApplicationForm, BrokerCloudEventModel.BrokerCloudEventDataModel>();

    // Step 1: Identify records where Assisted_Broker__c changed
    List<ApplicationForm> changedRecords = new List<ApplicationForm>();

    Set<SObjectField> applicationFormFieldsSet = new Set<SObjectField>{
      ApplicationForm.Assisted_Broker__c,
      ApplicationForm.Sync_Status__c
    };

    if (eventContext == 'applicationformadd' && oldMap != null) {
      changedRecords = ListUtil.filter(records, oldMap)
        .anyChanged(applicationFormFieldsSet)
        .toList();

      if (changedRecords.isEmpty()) {
        return results;
      }
    }

    if (eventContext != 'applicationformadd' || oldMap == null) {
      changedRecords.addAll(records);
    }

    // Step 2: Filter valid records (Sync_Status conditions)
    List<ApplicationForm> filteredApps = ListUtil.filter(changedRecords, oldMap)
      .notContains(ApplicationForm.Sync_Status__c, SYNC_STATUS_BLOCKED)
      .contains(ApplicationForm.Sync_Status__c, SYNC_STATUS_BROKER_ORG)
      .toList();

    if (filteredApps.isEmpty()) {
      return results;
    }

    // Step 3: Fetch related Account External IDs (bulk query)
    Map<Id, String> accountIdAndExternalId = APPLICATIONFORM_EVENT_REPOSITORY.getRelatedAccounts(
      filteredApps
    );

    // Step 4: Build payload for each record
    for (ApplicationForm app : filteredApps) {
      BrokerCloudEventModel.BrokerCloudEventDataModel ceData = ApplicationFormEventBuilder.buildApplicationFormPayload(
        new List<ApplicationForm>{ app },
        accountIdAndExternalId
      );

      results.put(app, ceData);
    }

    return results;
  }
}
