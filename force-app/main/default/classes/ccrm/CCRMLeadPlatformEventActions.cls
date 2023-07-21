/**
 * @author Mairaj H
 * @since  10/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadPlatformEventActions is an action class for sending platform events for CCRM/UNICA/ADOBE Leads
 */
public with sharing class CCRMLeadPlatformEventActions {
  private static List<CCRM_Lead_to_Platform_Event_Mapping__mdt> mappingsInCustomMetadata = new List<CCRM_Lead_to_Platform_Event_Mapping__mdt>();
  private static Map<Id, User> mapOfLastModifiedUserLanIds = new Map<Id, User>();
  private static Map<String, String> mapOfResponseLogLeadSubStatus = new Map<String, String>();
  private static Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
  private static String action;
  private static string originator;

  /**
   * @description Publish manual CCRM leads to UNICA via MuleSoft.
   * @param listOfLeads List of leads
   */
  public static void publishManualLeads(List<Lead> listOfLeads) {
    if (listOfLeads.size() > 0) {
      List<Lead_Event__e> leadEventsList;

      // Get a list of platform events
      leadEventsList = getLeadPlatformEvents(listOfLeads);

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

    List<Lead_Response_Event__e> leadResponseEventList = CCRMLeadPlatformEventHelper.getLeadResponseEventList(
      listOfLeads,
      leadIds
    );

    // Publish platform events
    if (leadResponseEventList.size() > 0) {
      PlatformEventUtils.publishEvents(leadResponseEventList);
    }
  }

  /**
   * @description Publish CCRM/UNICA/ADOBE leads to UNICA or ADOBE via MuleSoft.
   * @param listOfLeads List of leads
   */
  public static void publishLeadUpdateToUnicaOrAdobe(List<Lead> listOfLeads) {
    if (listOfLeads.size() > 0) {
      List<Lead_Event__e> leadEventsList;
      originator = CCRMConstants.ORIGINATOR_UNICA_OR_ADOBE_OR_CCRM;
      // Get a list of platform events
      leadEventsList = getLeadUpdatePlatformEvents(listOfLeads);

      // Publish platform events
      if (leadEventsList.size() > 0) {
        PlatformEventUtils.publishEvents(leadEventsList);
      }
    }
  }

  /**
   * @description This method returns List of lead platform events
   * @name getLeadUpdatePlatformEvents
   * @param records List of leads
   * @return List<Lead_Event__e> List of Lead platform events
   */
  private static List<Lead_Event__e> getLeadUpdatePlatformEvents(
    List<Lead> records
  ) {
    List<Lead_Event__e> leadEventList = new List<Lead_Event__e>();

    mappingsInCustomMetadata = CCRM_Lead_to_Platform_Event_Mapping__mdt.getall()
      .Values();

    //Get Map of Lan Ids for UNICA & ADOBE Leads
    Map<Id, User> mapOfLanIds = CCRMUserActions.getMapOfLanIds(records, false);
    //Get Map of Source System Ids for UNICA & ADOBE Leads
    Map<Id, Account> mapOfSourceSystemIds = CCRMAccountActions.getMapOfSourceSystemIdsByRelatedParties(
      records
    );

    //Get Map of Last Modified User Lan Ids for ADOBE Leads only
    mapOfLastModifiedUserLanIds = CCRMUserActions.getMapOfLanIds(records, true);
    mapOfResponseLogLeadSubStatus = CCRMLeadPlatformEventHelper.getMapOfResponseLogLeadSubStatus(
      records,
      mapOfOpportunityId
    );

    for (Lead record : records) {
      Lead_Event__e leadEvent = new Lead_Event__e();

      //Static mapping for following fields:
      //Owner Lan Id - Lan Id exist on User object which is a lookup on Lead
      //Customer/Business/CLG Ids - No direct relationship to lead. These fields need to be mapped through related party on Lead
      if (mapOfLanIds.containsKey(record.OwnerId)) {
        leadEvent.put(
          'Owner_Lan_ID__c',
          mapOfLanIds.get(record.OwnerId).Lan_Id__c
        );
      }
      leadEvent.put('Action__c', 'Update');

      //Dynamic mapping
      getLeadToPlatformEventMapping(record, leadEvent);

      if (leadEvent != null) {
        CCRMLeadUtil.mapSourceSystemIds(
          mapOfSourceSystemIds,
          record,
          leadEvent
        );
        leadEventList.add(leadEvent);
      }
    }
    return leadEventList;
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
   * @name getLeadPlatformEvents
   * @param records List of leads
   * @return List<Lead_Event__e> List of Lead platform events
   */
  private static List<Lead_Event__e> getLeadPlatformEvents(List<Lead> records) {
    List<Lead_Event__e> leadEventList = new List<Lead_Event__e>();

    mappingsInCustomMetadata = CCRM_Lead_to_Platform_Event_Mapping__mdt.getall()
      .Values();

    //Get Map of Lan Ids for UNICA
    Map<Id, User> mapOfLanIds = CCRMUserActions.getMapOfLanIds(records, false);
    //Get Map of Source System Ids for UNICA
    Map<Id, Account> mapOfSourceSystemIds = CCRMAccountActions.getMapOfSourceSystemIdsByRelatedParties(
      records
    );

    //Get Action i.e New or Update. Action will be passed to Platform Event
    action = CCRMConstants.MANUAL_LEADS_TO_UNICA_ACTION_NEW;

    for (Lead record : records) {
      Lead_Event__e leadEvent = new Lead_Event__e();

      //Static mapping for following fields:
      //Owner Lan Id - Lan Id exist on User object which is a lookup on Lead
      //Action fields - Action field don't exist on Lead
      //SubStatus will ne set to NEW on CCRM lead creation
      if (mapOfLanIds.containsKey(record.OwnerId)) {
        leadEvent.put(
          'Owner_Lan_ID__c',
          mapOfLanIds.get(record.OwnerId).Lan_Id__c
        );
      }

      leadEvent.put('Action__c', action);
      leadEvent.put('SubStatus__c', CCRMConstants.LEAD_SUBSTATUS_NEW);

      //Dynamic mapping
      getUnicaPlatformEventMapping(record, leadEvent);

      //Send PE for new Lead Or for updated lead only when required fields mentioned in Custom Metadata is changed
      if (leadEvent != null) {
        CCRMLeadUtil.mapSourceSystemIds(
          mapOfSourceSystemIds,
          record,
          leadEvent
        );
        leadEventList.add(leadEvent);
      }
    }
    return leadEventList;
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
      }
    }
  }

  /**
   * @description This method returns mapped fields (Lead to Lead_Event__e (Platform Event))
   * in Custom Metadata - CCRM Lead to Platform Event Mapping for ADOBE/UNICA/CCRM
   * @name getLeadToPlatformEventMapping
   * @param record Lead record
   * @param leadEvent Platform event
   */
  private static void getLeadToPlatformEventMapping(
    Lead record,
    Lead_Event__e leadEvent
  ) {
    leadEvent.put(
      'Last_Modified_By_LAN_ID__c',
      mapOfLastModifiedUserLanIds.get(record.LastModifiedById).Lan_Id__c
    );

    //Map Response_Type - UNICA Lead SubStatus to PE SubStatus__c
    //Map from Opportunity if lead got converted otherwise from Lead
    if (mapOfOpportunityId.containsKey(record.Id)) {
      Id opId = mapOfOpportunityId.get(record.Id);
      leadEvent.put('SubStatus__c', mapOfResponseLogLeadSubStatus.get(opId));
      leadEvent.put('Opp_Id__c', mapOfOpportunityId.get(record.Id));
    } else {
      leadEvent.put(
        'SubStatus__c',
        mapOfResponseLogLeadSubStatus.get(record.Id)
      );
    }

    for (
      CCRM_Lead_to_Platform_Event_Mapping__mdt mapping : mappingsInCustomMetadata
    ) {
      if (mapping.Destination_System__c == 'All') {
        leadEvent.put(
          mapping.Platform_Event_Field_API_Name__c,
          record.get(mapping.Lead_Field_API_Name__c)
        );
      }
    }
  }

  /**
   * @description This method is to publish event when lead conversion is completed
   * @name sendUpdateToUnicaOrAdobeOnLeadConversion
   * @param leadIds Set of lead ids
   * @param mapOppId Map of Oppotunities ids
   */
  public static void sendUpdateToUnicaOrAdobeOnLeadConversion(
    Set<Id> leadIds,
    Map<Id, Id> mapOppId
  ) {
    mapOfOpportunityId = mapOppId;
    publishLeadUpdateToUnicaOrAdobe(
      CCRMLeadPlatformEventHelper.getLeadData(leadIds)
    );
  }

  /**
   * @description This method is used by Admin to resend PE incase there is any error
   * @name resendManualLeadPlatformEvent
   * @param leadIds Set of lead ids
   */
  public static void resendManualLeadPlatformEvent(Set<Id> leadIds) {
    List<Lead> leads = CCRMLeadPlatformEventHelper.getLeadData(leadIds);
    if (leads.size() > 0) {
      publishManualLeads(leads);
    }
  }
}
