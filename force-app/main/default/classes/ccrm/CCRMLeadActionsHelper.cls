/**
 * @author Mairaj H
 * @since  04/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadActionsHelper is a helper class to handle all the CCRM (Commercial CRM) Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMLeadActionsHelper {
  private static List<CCRM_Lead_to_Platform_Event_Mapping__mdt> mappingsInCustomMetadata = new List<CCRM_Lead_to_Platform_Event_Mapping__mdt>();
  private static Map<Id, User> mapOfLastModifiedUserLanIds = new Map<Id, User>();
  private static Map<String, String> mapOfResponseLogLeadSubStatus = new Map<String, String>();
  private static Map<String, String> mapOfOpportunityIds = new Map<String, String>();

  private static String action;
  private static string originator;
  private static Boolean isleadUpdated = false;

  private static List<Lead> listOfLeads = new List<Lead>();
  /**
   * @description Publish manual CCRM leads to UNICA via MuleSoft.
   * @param listOfLeads List of leads
   * @param oldMap This Map<Id, Lead> contains the map old leads
   * @param leadOriginator Lead Originator UNICA/CCRM/Adobe
   */
  public static void publishManualLeads(
    List<Lead> listOfLeads,
    Map<Id, Lead> oldMap,
    String leadOriginator
  ) {
    if (listOfLeads.size() > 0) {
      List<Lead_Event__e> leadEventsList;
      originator = leadOriginator;

      // Get a list of platform events
      leadEventsList = generateLeadPlatformEvents(listOfLeads, oldMap);

      // Publish platform events
      if (leadEventsList.size() > 0) {
        PlatformEventUtils.publishEvents(leadEventsList);
      }
    }
  }

  /**
   * @description Publish Lead - Response update to UNICA or Adobe via MuleSoft.
   * @name publishLeadResponseUpdateToAdobeOrUnica
   * @param listOfLeads List of Leads
   * @param oldMap Map of old lead records
   */
  public static void publishLeadResponseUpdateToAdobeOrUnica(
    List<Lead> listOfLeads,
    Map<Id, Lead> oldMap
  ) {
    Set<Id> leadIds = new Set<Id>();
    for (Lead record : listOfLeads) {
      leadIds.add(record.Id);
    }

    String taskFields = '';
    //Get Platform Event data
    List<Lead_Response_Event__e> leadEventList = new List<Lead_Response_Event__e>();

    List<CCRM_Lead_Response_Event_Mapping__mdt> responseEventMapping = CCRM_Lead_Response_Event_Mapping__mdt.getall()
      .Values();

    //Get Map of Source System Ids for UNICA & ADOBE Leads
    Map<Id, Account> mapOfSourceSystemIds = getMapOfSourceSystemIdsByRelatedParties(
      listOfLeads
    );

    //Get Map of Lan Ids for UNICA & ADOBE Leads
    Map<Id, User> mapOfLanIds = getMapOfLanIds(listOfLeads, false);

    //Task and Lead fields mapping
    Map<Id, Task> mapOfTask = new Map<Id, Task>();
    for (CCRM_Lead_Response_Event_Mapping__mdt mapping : responseEventMapping) {
      if (
        mapping.Object__c == 'Task' &&
        mapping.Task_or_Lead_Field_API_Name__c != null &&
        mapping.Platform_Event_Field_API_Name__c != null
      ) {
        taskFields += mapping.Task_or_Lead_Field_API_Name__c + ',';
      }
    }

    //Get task data for all the fields defined within custom metadata
    string query =
      'SELECT ' +
      taskFields +
      ' WhoId, Response_Type__r.Unica_Lead_SubStatus__c FROM Task WHERE WhoId IN :leadIds';

    List<Task> tasks = Database.query(query);
    for (Task task : tasks) {
      mapOfTask.put(task.WhoId, task);
    }

    List<Lead_Response_Event__e> leadResponseEventList = new List<Lead_Response_Event__e>();
    for (Lead record : listOfLeads) {
      Task task = mapOfTask.get(record.id);
      Lead_Response_Event__e responseEvent = getLeadResponseMapping(
        record,
        task,
        responseEventMapping
      );
      responseEvent.put(
        'UNICA_Treatment_Code__c',
        task.Response_Type__r.Unica_Lead_SubStatus__c
      );

      if (mapOfLanIds.containsKey(record.LastModifiedById)) {
        responseEvent.put(
          'Created_By_LAN_ID__c',
          mapOfLanIds.get(record.LastModifiedById).Lan_Id__c
        );
      }

      if (mapOfSourceSystemIds.containsKey(record.FinServ__RelatedAccount__c)) {
        responseEvent.put(
          'Customer_Number__c',
          mapOfSourceSystemIds.get(record.FinServ__RelatedAccount__c)
            .Source_System_ID__c
        );

        string accountType = CCRMLeadMappingEngine.getAccountType(
          mapOfSourceSystemIds.get(record.FinServ__RelatedAccount__c)
            .RecordTypeId
        );
        responseEvent.put(
          'Customer_Type__c',
          accountType == 'Customer'
            ? 'Individual'
            : accountType == 'Business'
                ? 'Company'
                : accountType == 'CLG' ? 'CLG' : 'Prospect'
        );
      }

      if (record.lead_originator__c == CCRMConstants.ORIGINATOR_ADOBE) {
        responseEvent.put(
          'Lead_Owner_LAN_ID__c',
          mapOfLanIds.get(record.OwnerId).Lan_Id__c
        );
      }

      leadResponseEventList.add(responseEvent);
    }
    // Publish platform events
    if (leadResponseEventList.size() > 0) {
      PlatformEventUtils.publishEvents(leadResponseEventList);
    }
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
   * @description This method returns List of lead platform events
   * @name generateLeadPlatformEvents
   * @param records List of leads
   * @param oldMap This Map<Id, Lead> contains the map old leads
   * @return List<Lead_Event__e> List of Lead platform events
   */
  private static List<Lead_Event__e> generateLeadPlatformEvents(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead_Event__e> leadEventList = new List<Lead_Event__e>();

    mappingsInCustomMetadata = CCRM_Lead_to_Platform_Event_Mapping__mdt.getall()
      .Values();

    //Get Map of Lan Ids for UNICA & ADOBE Leads
    Map<Id, User> mapOfLanIds = getMapOfLanIds(records, false);
    //Get Map of Source System Ids for UNICA & ADOBE Leads
    Map<Id, Account> mapOfSourceSystemIds = getMapOfSourceSystemIdsByRelatedParties(
      records
    );

    //Get Map of Last Modified User Lan Ids for ADOBE Leads only
    if (originator == CCRMConstants.ORIGINATOR_ADOBE) {
      mapOfLastModifiedUserLanIds = getMapOfLanIds(records, true);
      mapOfResponseLogLeadSubStatus = getMapOfResponseLogLeadSubStatus(records);
      mapOfOpportunityIds = getMapOfOpportunityIds(records);
    }

    //Get Action i.e New or Update. Action will be passed to Platform Event
    action = oldMap == null
      ? CCRMConstants.MANUAL_LEADS_TO_UNICA_ACTION_NEW
      : CCRMConstants.MANUAL_LEADS_TO_UNICA_ACTION_UPDATE;

    for (Lead record : records) {
      Lead_Event__e leadEvent = new Lead_Event__e();

      if (originator == CCRMConstants.ORIGINATOR_CCRM && oldMap != null) {
        isleadUpdated = checkIfLeadUpdated(
          mappingsInCustomMetadata,
          record,
          oldMap
        );
      }

      if (
        originator == CCRMConstants.ORIGINATOR_CCRM &&
        String.isBlank(record.FinServ__RelatedAccount__c)
      ) {
        leadEvent.put('Prospect_Id__c', 'New');
      }
      //Static mapping for following fields:
      //Owner Lan Id - Lan Id exist on User object which is a lookup on Lead
      //Action fields - Action field don't exist on Lead
      //Customer/Business/CLG Ids - No direct relationship to lead. These fields need to be mapped through related party on Lead
      leadEvent.put(
        'Owner_Lan_ID__c',
        mapOfLanIds.get(record.OwnerId).Lan_Id__c
      );
      leadEvent.put('Action__c', action);

      //Dynamic mapping
      if (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM) {
        getUnicaPlatformEventMapping(record, leadEvent);
      } else if (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) {
        getAdobePlatformEventMapping(record, leadEvent);
      }

      if (leadEvent != null) {
        mapSourceSystemIds(mapOfSourceSystemIds, record, leadEvent);
        leadEventList.add(leadEvent);
      }
    }
    return leadEventList;
  }

  /**
   * @description This method returns map of opportunity Ids for converted lead
   * @name getMapOfOpportunityIds
   * @param leadList List of leads
   * @return Map<String, String> Map of related party and opportunity id
   */
  private static Map<String, String> getMapOfOpportunityIds(
    List<Lead> leadList
  ) {
    Set<Id> accountIds = new Set<Id>();
    Map<String, String> mapOpportunityIds = new Map<String, String>();

    for (Lead lead : leadList) {
      accountIds.add(lead.FinServ__RelatedAccount__c);
    }

    if (!accountIds.isEmpty() && Schema.sObjectType.Opportunity.isQueryable()) {
      for (Opportunity opp : [
        SELECT Opp_Id__c, AccountId
        FROM Opportunity
        WHERE AccountId = :accountIds
      ]) {
        mapOpportunityIds.put(opp.AccountId, opp.Opp_Id__c);
      }
    }
    return mapOpportunityIds;
  }

  /**
   * @description This method returns map of lead with Unica Lead SubStatus
   * @name getMapOfResponseLogLeadSubStatus
   * @param leadList List of leads
   * @return Map<String, String> Map of map of lead with Unica Lead SubStatus
   */
  private static Map<String, String> getMapOfResponseLogLeadSubStatus(
    List<Lead> leadList
  ) {
    Set<Id> leadIds = new Map<Id, Lead>(leadList).keySet();
    Map<String, String> mapLeadSubStatus = new Map<String, String>();

    if (!leadids.isEmpty() && Schema.sObjectType.Task.isQueryable()) {
      for (Task task : [
        SELECT Response_Type__r.Unica_Lead_SubStatus__c, WhoId
        FROM Task
        WHERE whoId = :leadIds
        ORDER BY createddate DESC
        LIMIT 1
      ]) {
        mapLeadSubStatus.put(
          task.WhoId,
          task.Response_Type__r.Unica_Lead_SubStatus__c
        );
      }
    }
    return mapLeadSubStatus;
  }

  /**
   * @description This method returns required platform event fields for UNICA
   * @name getUnicaPlatformEventMapping
   * @param record Lead record
   * @param leadEvent Platform event
   */
  private static void getUnicaPlatformEventMapping(
    Lead record,
    Lead_Event__e leadEvent
  ) {
    for (
      CCRM_Lead_to_Platform_Event_Mapping__mdt mapping : mappingsInCustomMetadata
    ) {
      //New Lead
      if (
        action == CCRMConstants.MANUAL_LEADS_TO_UNICA_ACTION_NEW &&
        (mapping.Destination_System__c == CCRMConstants.ORIGINATOR_UNICA ||
        mapping.Destination_System__c == 'All')
      ) {
        leadEvent.put(
          mapping.Platform_Event_Field_API_Name__c,
          record.get(mapping.Lead_Field_API_Name__c)
        );
        //Lead UPDATE. Platform Event should ONLY publish if Lead fields that flow to UNICA are updated
      } else if (
        action == CCRMConstants.MANUAL_LEADS_TO_UNICA_ACTION_UPDATE &&
        (mapping.Destination_System__c == CCRMConstants.ORIGINATOR_UNICA ||
        mapping.Destination_System__c == 'All') &&
        isleadUpdated
      ) {
        leadEvent.put(
          mapping.Platform_Event_Field_API_Name__c,
          record.get(mapping.Lead_Field_API_Name__c)
        );
      }
    }

    if (!isleadUpdated) {
      leadEvent = null;
    }
  }

  /**
   * @description This method returns required platform event fields for ADOBE
   * @name getAdobePlatformEventMapping
   * @param record Lead record
   * @param leadEvent Platform event
   */
  private static void getAdobePlatformEventMapping(
    Lead record,
    Lead_Event__e leadEvent
  ) {
    leadEvent.put(
      'Last_Modified_By_LAN_ID__c',
      mapOfLastModifiedUserLanIds.get(record.LastModifiedById).Lan_Id__c
    );

    //Map Response_Type - UNICA Lead SubStatus to PE SubStatus__c
    leadEvent.put('SubStatus__c', mapOfResponseLogLeadSubStatus.get(record.Id));
    if (record.Status == 'Converted') {
      leadEvent.put(
        'Opp_Id__c',
        mapOfOpportunityIds.get(record.FinServ__RelatedAccount__c)
      );
    }

    for (
      CCRM_Lead_to_Platform_Event_Mapping__mdt mapping : mappingsInCustomMetadata
    ) {
      if (
        mapping.Destination_System__c == CCRMConstants.ORIGINATOR_ADOBE ||
        mapping.Destination_System__c == 'All'
      ) {
        leadEvent.put(
          mapping.Platform_Event_Field_API_Name__c,
          record.get(mapping.Lead_Field_API_Name__c)
        );
      }
    }
  }

  /**
   * @description This method sets Customer_ID__c/Business_ID__cCLG_ID__c in platform event
   * @name mapSourceSystemIds
   * @param mapOfSourceSystemIds Map of Accounts
   * @param record Lead record
   * @param leadEvent Lead platform event
   */
  private static void mapSourceSystemIds(
    Map<Id, Account> mapOfSourceSystemIds,
    Lead record,
    Lead_Event__e leadEvent
  ) {
    if (
      String.isNotBlank(record.FinServ__RelatedAccount__c) &&
      mapOfSourceSystemIds.containsKey(record.FinServ__RelatedAccount__c)
    ) {
      string accountType = CCRMLeadMappingEngine.getAccountType(
        mapOfSourceSystemIds.get(record.FinServ__RelatedAccount__c).RecordTypeId
      );
      if (originator == CCRMConstants.ORIGINATOR_CCRM) {
        switch on accountType {
          when 'Customer' {
            leadEvent.put(
              'Customer_ID__c',
              mapOfSourceSystemIds.get(record.FinServ__RelatedAccount__c)
                .Source_System_ID__c
            );
          }
          when 'Business' {
            leadEvent.put(
              'Business_ID__c',
              mapOfSourceSystemIds.get(record.FinServ__RelatedAccount__c)
                .Source_System_ID__c
            );
          }
          when 'CLG' {
            leadEvent.put(
              'CLG_ID__c',
              mapOfSourceSystemIds.get(record.FinServ__RelatedAccount__c)
                .Source_System_ID__c
            );
          }
        }
      }
      if (originator == CCRMConstants.ORIGINATOR_ADOBE) {
        leadEvent.put(
          'Customer_Number__c',
          mapOfSourceSystemIds.get(record.FinServ__RelatedAccount__c)
            .Source_System_ID__c
        );
        leadEvent.put(
          'Customer_Type__c',
          accountType == 'Customer'
            ? 'Individual'
            : accountType == 'Business'
                ? 'Company'
                : accountType == 'CLG' ? 'CLG' : 'Prospect'
        );
      }
    }
  }

  /**
   * @description This method returns map of account with source system id
   * @name getMapOfSourceSystemIdsByRelatedParties
   * @param leadList List of leads
   * @return Map<Id, Account> Map of account
   */
  private static Map<Id, Account> getMapOfSourceSystemIdsByRelatedParties(
    List<Lead> leadList
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Lead record : leadList) {
      accountIds.add(record.FinServ__RelatedAccount__c);
    }
    Map<Id, Account> mapOfSourceSystemIds = new Map<Id, Account>(
      [
        SELECT
          Id,
          Source_System_ID__c,
          Source_System_Name__c,
          Name,
          RecordTypeId
        FROM Account
        WHERE Source_System_Name__c = 'CAP' AND Id IN :accountIds
      ]
    );
    return mapOfSourceSystemIds;
  }

  /**
   * @description This method check any Lead fields that flow to UNICA are updated
   * @name checkIfLeadUpdated
   * @param mappingsInCustomMetadata Fields in metadata
   * @param record Lead record
   * @param oldRecords Map of old lead records
   * @return Boolean Return true if any lead field that flow to UNICA is updated
   */
  private static Boolean checkIfLeadUpdated(
    List<CCRM_Lead_to_Platform_Event_Mapping__mdt> mappingsInCustomMetadata,
    Lead record,
    Map<Id, Lead> oldRecords
  ) {
    for (
      CCRM_Lead_to_Platform_Event_Mapping__mdt mapping : mappingsInCustomMetadata
    ) {
      if (
        (mapping.Destination_System__c == CCRMConstants.ORIGINATOR_UNICA ||
        mapping.Destination_System__c == 'All') &&
        record.get(mapping.Lead_Field_API_Name__c) !=
        oldRecords.get(record.Id).get(mapping.Lead_Field_API_Name__c)
      ) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description This method gets the Lan Ids of lead owner and lead last modified user
   * @name getMapOfLanIds
   * @param leadList List of lead
   * @param isLastModifiedUser Is Last Modified User required
   * @return Map<Id, User> Return map of user with Lan Ids
   */
  private static Map<Id, User> getMapOfLanIds(
    List<Lead> leadList,
    Boolean isLastModifiedUser
  ) {
    Set<Id> leadOwnerIds = new Set<Id>();
    for (Lead record : leadList) {
      leadOwnerIds.add(
        isLastModifiedUser ? record.LastModifiedById : record.OwnerId
      );
    }
    Map<Id, User> mapOfLanId = new Map<Id, User>(
      [SELECT ID, Lan_Id__c FROM User WHERE Id IN :leadOwnerIds]
    );
    return mapOfLanId;
  }

  /**
   * @description This method is used by Admin to resend PE incase there is any error
   * @name resendLeadPlatformEvent
   * @param leadIds Set of lead ids
   */
  public static void resendLeadPlatformEvent(Set<Id> leadIds) {
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
    List<Lead> ccrmLeads = new List<Lead>();
    List<Lead> adobeLeads = new List<Lead>();
    for (Lead lead : leads) {
      if (lead.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM) {
        ccrmLeads.add(lead);
      } else if (lead.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) {
        adobeLeads.add(lead);
      }
    }
    if (ccrmLeads.size() > 0) {
      publishManualLeads(ccrmLeads, null, CCRMConstants.ORIGINATOR_CCRM);
    }
    if (adobeLeads.size() > 0) {
      publishManualLeads(adobeLeads, null, CCRMConstants.ORIGINATOR_ADOBE);
    }
  }

  /**
   * @description This method is used by Admin to resend PE incase there is any error
   * @name resendLeadUpdatePlatformEvent
   * @param leadIds Set of lead ids
   */
  public static void resendLeadUpdatePlatformEvent(Set<String> leadIds) {
    List<CCRM_Lead_Response_Event_Mapping__mdt> mappingsInCustomMetadata = CCRM_Lead_Response_Event_Mapping__mdt.getall()
      .Values();
    string leadFields = '';
    for (
      CCRM_Lead_Response_Event_Mapping__mdt mapping : mappingsInCustomMetadata
    ) {
      if (mapping.Object__c == 'Lead') {
        leadFields += mapping.Task_or_Lead_Field_API_Name__c + ',';
      }
    }
    string query =
      'SELECT ' +
      leadFields +
      ' OwnerId, FinServ__RelatedAccount__c, LastModifiedById FROM Lead WHERE Lead_Id__c IN :leadIds';
    List<Lead> leads = Database.query(query);
    if (leads.size() > 0) {
      publishLeadResponseUpdateToAdobeOrUnica(leads, null);
    }
  }
}
