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
  private static Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
  private static String action;
  private static string originator;
  private static List<Lead> listOfLeads = new List<Lead>();

  private static final Map<String, String> MAP_ACCOUNTTYPE_TO_EVENTFIELDNAME = new Map<String, String>{
    'Customer' => 'Customer_ID__c',
    'Business' => 'Business_ID__c',
    'CLG' => 'CLG_ID__c'
  };
  private static final Map<String, String> MAP_ACCOUNTTYPE_TO_CUSTOMERTYPE = new Map<String, String>{
    'Customer' => 'Individual',
    'Business' => 'Company',
    'CLG' => 'CLG'
  };

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

    //Get ONLY latest task data for all the fields defined within custom metadata
    string query =
      'SELECT ' +
      taskFields +
      ' WhoId, Response_Type__r.Unica_Lead_SubStatus__c FROM Task WHERE WhoId IN :leadIds order by createdDate desc LIMIT 1';

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

      if (mapOfLanIds.containsKey(record.LastModifiedById)) {
        responseEvent.put(
          'Created_By_LAN_ID__c',
          mapOfLanIds.get(record.LastModifiedById).Lan_Id__c
        );
      }

      if (mapOfSourceSystemIds.containsKey(record.FinServ__RelatedAccount__c)) {
        responseEvent.put(
          'Customer_ID__c',
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
      } else if (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) {
        //For Adobe lead add prospect Id to customer number if no related party exist
        responseEvent.put('Customer_ID__c', record.Prospect_ID__c);
      }

      if (record.lead_originator__c == CCRMConstants.ORIGINATOR_ADOBE) {
        responseEvent.put(
          'Lead_Owner_LAN_ID__c',
          mapOfLanIds.get(record.OwnerId).Lan_Id__c
        );
        //Don't send follow up date for Adobe leads
        responseEvent.put('Followup_Date__c', null);
      }

      leadResponseEventList.add(responseEvent);
    }
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
    Map<Id, User> mapOfLanIds = getMapOfLanIds(records, false);
    //Get Map of Source System Ids for UNICA & ADOBE Leads
    Map<Id, Account> mapOfSourceSystemIds = getMapOfSourceSystemIdsByRelatedParties(
      records
    );

    //Get Map of Last Modified User Lan Ids for ADOBE Leads only
    mapOfLastModifiedUserLanIds = getMapOfLanIds(records, true);
    mapOfResponseLogLeadSubStatus = getMapOfResponseLogLeadSubStatus(records);

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
        mapSourceSystemIds(mapOfSourceSystemIds, record, leadEvent);
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
    Map<Id, User> mapOfLanIds = getMapOfLanIds(records, false);
    //Get Map of Source System Ids for UNICA
    Map<Id, Account> mapOfSourceSystemIds = getMapOfSourceSystemIdsByRelatedParties(
      records
    );

    //Get Action i.e New or Update. Action will be passed to Platform Event
    action = CCRMConstants.MANUAL_LEADS_TO_UNICA_ACTION_NEW;

    for (Lead record : records) {
      Lead_Event__e leadEvent = new Lead_Event__e();

      if (
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM &&
        String.isBlank(record.FinServ__RelatedAccount__c)
      ) {
        leadEvent.put('Prospect_Id__c', 'New');
      }
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
        mapSourceSystemIds(mapOfSourceSystemIds, record, leadEvent);
        leadEventList.add(leadEvent);
      }
    }
    return leadEventList;
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
    Set<Id> leadIds = new Set<Id>();
    Map<String, String> mapLeadSubStatus = new Map<String, String>();

    for (Lead lead : leadList) {
      leadIds.add(lead.Id);
    }

    Set<Id> oppIds = new Set<Id>(mapOfOpportunityId.values());

    if (leadids.isEmpty() || !Schema.sObjectType.Task.isQueryable()) {
      return mapLeadSubStatus;
    }
    for (Task task : [
      SELECT Response_Type__r.Unica_Lead_SubStatus__c, WhoId, WhatId
      FROM Task
      WHERE WhoId IN :leadIds OR WhatId IN :oppIds
      ORDER BY createddate DESC
    ]) {
      if (
        mapLeadSubStatus.containsKey(task.WhatId) ||
        mapLeadSubStatus.containsKey(task.WhoId)
      ) {
        continue;
      }
      if (oppIds.contains(task.WhatId)) {
        mapLeadSubStatus.put(
          task.WhatId,
          task.Response_Type__r.Unica_Lead_SubStatus__c
        );
      } else {
        mapLeadSubStatus.put(
          task.WhoId,
          task.Response_Type__r.Unica_Lead_SubStatus__c = !String.isEmpty(
              task.Response_Type__r.Unica_Lead_SubStatus__c
            )
            ? task.Response_Type__r.Unica_Lead_SubStatus__c
            : CCRMConstants.LEAD_SUBSTATUS_NEW
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

      if (MAP_ACCOUNTTYPE_TO_EVENTFIELDNAME.containsKey(accountType)) {
        leadEvent.put(
          MAP_ACCOUNTTYPE_TO_EVENTFIELDNAME.get(accountType),
          mapOfSourceSystemIds.get(record.FinServ__RelatedAccount__c)
            .Source_System_ID__c
        );
      }

      if (originator == CCRMConstants.ORIGINATOR_UNICA_OR_ADOBE_OR_CCRM) {
        String customerType = MAP_ACCOUNTTYPE_TO_CUSTOMERTYPE.containsKey(
            accountType
          )
          ? MAP_ACCOUNTTYPE_TO_CUSTOMERTYPE.get(accountType)
          : 'Prospect';
        leadEvent.put('Customer_Type__c', customerType);
      }
    } else if (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) {
      //For Adobe lead add prospect Id if no related party exist
      leadEvent.put('Customer_ID__c', record.Prospect_ID__c);
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
    publishLeadUpdateToUnicaOrAdobe(getLeadData(leadIds));
  }

  /**
   * @description This method is used by Admin to resend PE incase there is any error
   * @name resendManualLeadPlatformEvent
   * @param leadIds Set of lead ids
   */
  public static void resendManualLeadPlatformEvent(Set<Id> leadIds) {
    List<Lead> leads = getLeadData(leadIds);
    if (leads.size() > 0) {
      publishManualLeads(leads);
    }
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
   * @description Set default campaign of manually created leads.
   * @name getDefaultCampaign
   * @return `Campaign`
   */
  public static Campaign getDefaultCampaign() {
    String defaultCampaignCode = Label.CCRM_DefaultCampaign;
    if (String.isBlank(defaultCampaignCode)) {
      return null;
    }
    try {
      List<Campaign> defaultCampaign = [
        SELECT Id, Code__c
        FROM Campaign
        WHERE Code__c = :defaultCampaignCode
        WITH SECURITY_ENFORCED
      ];
      if (defaultCampaign.isEmpty()) {
        return null;
      }
      return defaultCampaign[0];
    } catch (System.QueryException qe) {
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'getDefaultCampaign'
      );
      log.error(
        'InsufficientAccessException',
        qe.getMessage(),
        qe.getTypeName()
      );
      log.publishEvent();
    }
    return null;
  }

  /**
   * @description Set field CCRM_Duplicate_Block__c to true if the lead's status is New or In progress
   * @name setDuplicateBlock
   * @param record current record
   * @param oldRec old record
   */
  public static void setDuplicateBlock(Lead record, Lead oldRec) {
    if (
      record.Status == CCRMConstants.STATUS_NEW ||
      record.Status == CCRMConstants.STATUS_IN_PROGRESS
    ) {
      record.CCRM_Duplicate_Block_Check__c = 'Yes';
    } else {
      record.CCRM_Duplicate_Block_Check__c = 'No';
    }
  }

  /**
   * @description Get a List of Controlling Posts
   * @name getControllingPosts
   * @param employeeIds A Set of User.Employee_Id__c
   * @return `List<Controlling_Post__c>` Returns List of Controlling Posts of Users
   */
  public static List<Controlling_Post__c> getControllingPosts(
    Set<String> employeeIds
  ) {
    if (
      !Schema.sObjectType.Controlling_Post__c.isQueryable() &&
      !Schema.sObjectType.Controlling_Post__c.fields.CPID__c.isAccessible() &&
      !Schema.sObjectType.Controlling_Post__c.fields.Responsible_Employee_Id__c.isAccessible()
    ) {
      return new List<Controlling_Post__c>();
    }
    return [
      SELECT Id, CPID__c, Responsible_Employee_Id__c
      FROM Controlling_Post__c
      WHERE Responsible_Employee_Id__c IN :employeeIds AND Is_Active__c = TRUE
      WITH SECURITY_ENFORCED
    ];
  }

  /**
   * @description Updates Leads if the User has a Controlling Post with CPID
   * @name updateCPIDs
   * @param leadOwners Map of Leads with Owner ID as key
   * @param users Map of Employee Users with Employee ID as key
   * @param controllingPosts List of Controlling Posts from employeer
   */
  public static void updateCPIDs(
    Map<Id, List<Lead>> leadOwners,
    Map<String, User> users,
    List<Controlling_Post__c> controllingPosts
  ) {
    for (Controlling_Post__c controllingPost : controllingPosts) {
      if (controllingPost.CPID__c == null) {
        continue;
      }
      User user = users.get(controllingPost.Responsible_Employee_Id__c);
      List<Lead> mappedLeads = leadOwners.get(user?.id);

      if (mappedLeads == null) {
        continue;
      }
      for (Lead mappedLead : mappedLeads) {
        if (mappedLead.CPID__c == null) {
          mappedLead.Controlling_Post__c = controllingPost.Id;
          mappedLead.CPID__c = controllingPost.CPID__c;
          mappedLead.CPID_Owner__c = user.id;
        }
      }
    }
  }
}
