/**
 * @author Mairaj H
 * @since  09/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadPlatformEventHelper is a class to construct data for LEAD Platform Event sent to UNICA/ADOBE
 */
public with sharing class CCRMLeadPlatformEventHelper {
  public static Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
  public static List<Task> leadTask;

  /**
   * @description Return list of platform events for Response Log associated to lead
   * @param listOfLeads Lead record
   * @param leadIds Set of lead Ids
   * @return Lead_Response_Event__e Lead Response Log Platform Event
   */
  public static List<Lead_Response_Event__e> getLeadResponseEventList(
    List<Lead> listOfLeads,
    Set<Id> leadIds
  ) {
    //Get Platform Event data
    List<Lead_Response_Event__e> leadEventList = new List<Lead_Response_Event__e>();

    List<CCRM_Lead_Response_Event_Mapping__mdt> responseEventMapping = CCRM_Lead_Response_Event_Mapping__mdt.getall()
      .Values();

    //Get Map of Source System Ids for UNICA & ADOBE Leads
    Map<Id, Account> mapOfSourceSystemIds = CCRMAccountActions.getMapOfSourceSystemIdsByRelatedParties(
      listOfLeads
    );

    //Get Map of Lan Ids for UNICA & ADOBE Leads
    Map<Id, User> mapOfLanIds = CCRMUserActions.getMapOfLanIds(
      listOfLeads,
      false
    );

    //Task and Lead fields mapping
    Map<Id, Task> mapOfTask = getMapOfTask(responseEventMapping, leadIds);

    List<Lead_Response_Event__e> leadResponseEventList = new List<Lead_Response_Event__e>();
    for (Lead record : listOfLeads) {
      Task task = mapOfTask.get(record.id);
      Lead_Response_Event__e responseEvent = getLeadResponseMapping(
        record,
        task,
        responseEventMapping
      );

      if (mapOfLanIds.containsKey(record.LastModifiedById)) {
        responseEvent.put(
          'Created_By_LAN_ID__c',
          mapOfLanIds.get(record.LastModifiedById).Lan_Id__c
        );
      }

      CCRMLeadUtil.mapSourceSystemIdsForLeadResponse(
        mapOfSourceSystemIds,
        record,
        responseEvent
      );

      if (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) {
        responseEvent.put(
          'Lead_Owner_LAN_ID__c',
          mapOfLanIds.get(record.OwnerId).Lan_Id__c
        );
        //Don't send follow up date for Adobe leads
        responseEvent.put('Followup_Date__c', null);
      }

      leadResponseEventList.add(responseEvent);
    }
    return leadResponseEventList;
  }

  /**
   * @description Return map of task related to leads
   * @param responseEventMapping List of Mapping defined in Custom Metadata
   * @param leadIds Set of Lead Ids
   * @return Map<Id, Task> Map of task with Leads Ids
   */
  private static Map<Id, Task> getMapOfTask(
    List<CCRM_Lead_Response_Event_Mapping__mdt> responseEventMapping,
    Set<Id> leadIds
  ) {
    Map<Id, Task> mapOfTask = new Map<Id, Task>();
    String taskFields = '';
    for (CCRM_Lead_Response_Event_Mapping__mdt mapping : responseEventMapping) {
      if (
        mapping.Object__c == 'Task' &&
        mapping.Task_or_Lead_Field_API_Name__c != null &&
        mapping.Platform_Event_Field_API_Name__c != null
      ) {
        taskFields += mapping.Task_or_Lead_Field_API_Name__c + ',';
      }
    }

    //Get ONLY latest task data for all the fields defined within custom metadata
    string query =
      'SELECT ' +
      taskFields +
      ' WhoId, Response_Type__r.Unica_Lead_SubStatus__c FROM Task WHERE WhoId IN :leadIds order by createdDate desc LIMIT 1';

    List<Task> tasks = Database.query(query);
    for (Task task : tasks) {
      mapOfTask.put(task.WhoId, task);
    }
    return mapOfTask;
  }

  /**
   * @description Create mapping between platform event and Lead/Task object based on mapping defined in custom metadata.
   * @param record Lead record
   * @param task Task record
   * @param responseEventMapping List of Mapping defined in Custom Metadata
   * @return Lead_Response_Event__e Lead Response Log Platform Event
   */
  private static Lead_Response_Event__e getLeadResponseMapping(
    lead record,
    Task task,
    List<CCRM_Lead_Response_Event_Mapping__mdt> responseEventMapping
  ) {
    Lead_Response_Event__e leadResponseEvent = new Lead_Response_Event__e();
    for (CCRM_Lead_Response_Event_Mapping__mdt mapping : responseEventMapping) {
      if (
        mapping.Object__c == 'Task' &&
        (mapping.Destination_System__c == record.Lead_Originator__c ||
        mapping.Destination_System__c == 'All')
      ) {
        leadResponseEvent.put(
          mapping.Platform_Event_Field_API_Name__c,
          task.get(mapping.Task_or_Lead_Field_API_Name__c)
        );
      } else if (
        mapping.Object__c == 'Lead' &&
        (mapping.Destination_System__c == record.Lead_Originator__c ||
        mapping.Destination_System__c == 'All')
      ) {
        leadResponseEvent.put(
          mapping.Platform_Event_Field_API_Name__c,
          record.get(mapping.Task_or_Lead_Field_API_Name__c)
        );
      }
    }
    return leadResponseEvent;
  }

  /**
   * @description This method get lead data to resend PE Lead Update event by Admin incase there is any error
   * @name getLeadData
   * @param leadIds Set of lead ids
   * @return List<Lead> List of Lead records
   */
  public static List<Lead> getLeadData(Set<Id> leadIds) {
    List<CCRM_Lead_to_Platform_Event_Mapping__mdt> mappingsInCustomMetadata = CCRM_Lead_to_Platform_Event_Mapping__mdt.getall()
      .Values();
    string leadFields = '';
    for (
      CCRM_Lead_to_Platform_Event_Mapping__mdt mapping : mappingsInCustomMetadata
    ) {
      leadFields += mapping.Lead_Field_API_Name__c + ',';
    }
    string query =
      'SELECT ' +
      leadFields +
      ' OwnerId, FinServ__RelatedAccount__c, LastModifiedById FROM Lead WHERE Id IN :leadIds';
    List<Lead> leads = Database.query(query);
    return leads;
  }

  /**
   * @description This method returns map of lead with Unica Lead SubStatus
   * @name getMapOfResponseLogLeadSubStatus
   * @param leadList List of leads
   * @param mapOfOpportunityId Map of map of lead Ids with Opportunity Ids
   * @return Map<String, String> Map of map of lead with Unica Lead SubStatus
   */
  public static Map<String, String> getMapOfResponseLogLeadSubStatus(
    List<Lead> leadList,
    Map<Id, Id> mapOfOpportunityId
  ) {
    Set<Id> leadIds = new Set<Id>();
    Map<String, String> mapLeadSubStatus = new Map<String, String>();

    for (Lead lead : leadList) {
      leadIds.add(lead.Id);
    }

    if (leadids.isEmpty() || !Schema.sObjectType.Task.isQueryable()) {
      return mapLeadSubStatus;
    }

    //For lead conversion tasks are fetched for leads in LeadConversion class and assigned to leadTask
    if (!mapOfOpportunityId.isEmpty()) {
      for (Task leadTask : leadTask) {
        mapLeadSubStatus.put(
          mapOfOpportunityId.get(leadTask.WhoId),
          leadTask.Response_Type__r.Unica_Lead_SubStatus__c
        );
      }
    } else {
      //For lead update fetch task for leads
      mapLeadSubStatus = getTaskForLeads(leadIds);
    }
    return mapLeadSubStatus;
  }

  /**
   * @description This method returns Map of Lead Id with Unica Lead SubStatus
   * @name getTaskForLeads
   * @param leadIds Set of leads
   * @return Map<String, String> Map of Lead Id with Unica Lead SubStatus
   */
  private static Map<String, String> getTaskForLeads(Set<Id> leadIds) {
    Map<String, String> mapLeadSubStatus = new Map<String, String>();

    for (Task task : [
      SELECT Response_Type__r.Unica_Lead_SubStatus__c, WhoId
      FROM Task
      WHERE WhoId IN :leadIds
      ORDER BY createddate DESC
    ]) {
      if (mapLeadSubStatus.containsKey(task.WhoId)) {
        continue;
      }

      mapLeadSubStatus.put(
        task.WhoId,
        task.Response_Type__r.Unica_Lead_SubStatus__c = !String.isEmpty(
            task.Response_Type__r.Unica_Lead_SubStatus__c
          )
          ? task.Response_Type__r.Unica_Lead_SubStatus__c
          : CCRMConstants.LEAD_SUBSTATUS_NEW
      );
    }
    return mapLeadSubStatus;
  }
}
