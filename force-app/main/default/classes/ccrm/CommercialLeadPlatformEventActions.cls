/**
 * @author Naman Garg
 * @since May 2025
 * @group CCRM (Commercial CRM)
 * @description CommercialLeadPlatformEventActions is an action class for sending platform events for CCRM/UNICA/ADOBE Leads
 */
public with sharing class CommercialLeadPlatformEventActions {
  private static Map<String, String> mapOfResponseLogLeadSubStatus = new Map<String, String>();
  @TestVisible
  private static Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();

  private static final String ACTION_NEW = 'New';
  private static final String ACTION_UPDATE = 'Update';
  private static final String MANUAL_LEADS_TO_UNICA_ACTION_NEW = 'New';
  private static final String ORIGINATOR_UNICA_OR_ADOBE_OR_CCRM = 'CCRM OR UNICA OR ADOBE';
  private static final String ORIGINATOR_CCRM = 'CCRM';
  private static final String DESTINATION_SYSTEM_UNICA = 'Unica';
  private static final String CCRM_LEAD = 'CCRM_Lead';
  private static final String DESTINATION_SYSTEM_ALL = 'All';
  private static final String ACTION_FIELD = 'Action__c';
  private static final String OWNER_LAN_ID_FIELD = 'Owner_Lan_ID__c';
  private static final String LAST_MODIFIED_BY_FIELD = 'Last_Modified_By_LAN_ID__c';
  private static final String RECORD_TYPE_FIELD = 'Lead_Record_Type__c';
  private static final String SUBSTATUS_FIELD = 'SubStatus__c';
  private static final String OPP_FIELD = 'Opp_Id__c';
  private static final String STATUS_FIELD = 'Status__c';
  private static final String DESCRIPTION_FIELD = 'Description__c';
  private static final String CUSTOMER_TYPE_FIELD = 'Customer_Type__c';
  private static final String PROSPECT_FIELD = 'Prospect_ID__c';
  private static final String PROSPECT_VALUE = 'Prospect';
  private static final String NEW_VALUE = 'New';
  private static final String LEAD_SUBSTATUS_NEW = 'New';

  private static final Map<Id, String> ACCOUNT_TYPE_MAP = new Map<Id, String>{
    RTAccount.businessAccount => 'Business',
    RTAccount.personAccount => 'Customer',
    RTAccount.clgAccount => 'CLG'
  };

  public static final Map<String, String> ACCOUNT_TYPE_TO_CUSTOMER_TYPE_MAP = new Map<String, String>{
    'Customer' => 'Individual',
    'Business' => 'Company',
    'CLG' => 'CLG'
  };

  public static final Map<String, String> ACCOUNT_TYPE_TO_EVENTFIELDNAME_MAP = new Map<String, String>{
    'Customer' => 'Customer_ID__c',
    'Business' => 'Business_ID__c',
    'CLG' => 'CLG_ID__c'
  };

  private static final UserActionsRepository USER_ACTIONS_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final LeadActionsRepository LEAD_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );

  /**
   * @description Publish manual CCRM leads to UNICA via MuleSoft.
   * @param listOfLeads List of leads.
   */
  public void publishManualLeads(List<Lead> listOfLeads) {
    Set<Id> leadOwnerIdsSet = ListUtil.getIds(listOfLeads, Lead.OwnerId);

    Map<Id, User> mapOfOwnerLanIds = USER_ACTIONS_REPOSITORY.getUserMapFromUserIds(
      leadOwnerIdsSet
    );

    Set<Id> leadAccountIdsSet = ListUtil.getIds(
      listOfLeads,
      Lead.FinServ__RelatedAccount__c
    );

    Map<Id, Account> mapOfAccount = LEAD_REPOSITORY.getAccountRecords(
      leadAccountIdsSet
    );

    List<Lead_Event__e> leadEventsList = formUnicaLeadEventList(
      listOfLeads,
      mapOfOwnerLanIds,
      mapOfAccount
    );

    if (leadEventsList.isEmpty()) {
      return;
    }
    DML_REPOSITORY.doPublish(leadEventsList);
  }

  /**
   * @description This method returns List of lead platform events
   * @name formUnicaLeadEventList
   * @param records List of leads
   * @param mapOfOwnerLanIds Map of Owner Lan's Id
   * @param mapOfAccount Map Of Id and Account
   * @return List<Lead_Event__e> List of Lead platform events
   */
  @TestVisible
  private static List<Lead_Event__e> formUnicaLeadEventList(
    List<Lead> records,
    Map<Id, User> mapOfOwnerLanIds,
    Map<Id, Account> mapOfAccount
  ) {
    List<Lead_Event__e> leadEventList = new List<Lead_Event__e>();
    List<CCRM_Lead_to_Platform_Event_Mapping__mdt> filteredMdtRecords = QueryLeadToPlatformEventMapping.get(
      DESTINATION_SYSTEM_ALL
    );

    filteredMdtRecords.addAll(
      QueryLeadToPlatformEventMapping.get(DESTINATION_SYSTEM_UNICA)
    );
    for (Lead record : records) {
      Lead_Event__e leadEvent = new Lead_Event__e();

      leadEvent.put(ACTION_FIELD, MANUAL_LEADS_TO_UNICA_ACTION_NEW);
      leadEvent.put(SUBSTATUS_FIELD, LEAD_SUBSTATUS_NEW);

      mapOwnerLanIds(record, mapOfOwnerLanIds, leadEvent);

      generateLeadEventFromMd(record, filteredMdtRecords, leadEvent);

      mapSourceSystemIds(mapOfAccount, record, leadEvent);

      leadEventList.add(leadEvent);
    }
    return leadEventList;
  }

  /**
   * @description This is used to generate the leadEvent from CCRM_Lead_to_Platform_Event_Mapping__mdt
   * @param record Lead record
   * @param filteredMdtRecords Metadata records
   * @param leadEvent Lead Event
   */
  @TestVisible
  private static void generateLeadEventFromMd(
    Lead record,
    List<CCRM_Lead_to_Platform_Event_Mapping__mdt> filteredMdtRecords,
    Lead_Event__e leadEvent
  ) {
    for (
      CCRM_Lead_to_Platform_Event_Mapping__mdt mdtRecord : filteredMdtRecords
    ) {
      if (mdtRecord.Platform_Event_Field_API_Name__c == STATUS_FIELD) {
        getLeadToPlatformEventMappingForStatus(
          record,
          leadEvent,
          mdtRecord.Platform_Event_Field_API_Name__c
        );
        continue;
      }
      if (mdtRecord.Platform_Event_Field_API_Name__c == DESCRIPTION_FIELD) {
        leadEvent.put(
          mdtRecord.Platform_Event_Field_API_Name__c,
          record.Note__c?.stripHtmlTags().left(1950)
        );
        continue;
      }
      leadEvent.put(
        mdtRecord.Platform_Event_Field_API_Name__c,
        record.get(mdtRecord.Lead_Field_API_Name__c)
      );
    }
  }

  /**
   * @description Publish CCRM/UNICA/ADOBE leads to UNICA or ADOBE via MuleSoft.
   * @param listOfLeads List of leads
   * @param taskList list Of Tasks
   */
  public void publishLeadUpdateToUnicaOrAdobe(
    List<Lead> listOfLeads,
    List<Task> taskList
  ) {
    if (listOfLeads.isEmpty()) {
      return;
    }
    Set<Id> leadOwnerIdsSet = ListUtil.getIds(listOfLeads, Lead.OwnerId);

    Map<Id, User> mapOfOwnerLanIds = USER_ACTIONS_REPOSITORY.getUserMapFromUserIds(
      leadOwnerIdsSet
    );

    Set<Id> leadAccountIdsSet = ListUtil.getIds(
      listOfLeads,
      Lead.FinServ__RelatedAccount__c
    );

    Map<Id, Account> mapOfAccount = LEAD_REPOSITORY.getAccountRecords(
      leadAccountIdsSet
    );

    Set<Id> leadLastModifiedByIdsSet = ListUtil.getIds(
      listOfLeads,
      Lead.LastModifiedById
    );

    Map<Id, User> mapOfLastModifiedUserLanIds = USER_ACTIONS_REPOSITORY.getUserMapFromUserIds(
      leadLastModifiedByIdsSet
    );

    mapOfResponseLogLeadSubStatus = CCRMLeadPlatformEventHelper.getMapOfResponseLogLeadSubStatus(
      listOfLeads,
      mapOfOpportunityId,
      taskList
    );

    List<Lead_Event__e> leadEventsList = formLeadEventList(
      listOfLeads,
      mapOfOwnerLanIds,
      mapOfAccount,
      mapOfLastModifiedUserLanIds
    );

    if (leadEventsList.isEmpty()) {
      return;
    }

    DML_REPOSITORY.doPublish(leadEventsList);
  }

  /**
   * @description This method returns List of lead platform events
   * @name formLeadEventList
   * @param records List of leads
   * @param mapOfOwnerLanIds Map of Owner Lan's Id
   * @param mapOfAccount Map Of Id and Account
   * @param mapOfLastModifiedUserLanIds Map of Last Modified Lan's Id
   * @return List<Lead_Event__e> List of Lead platform events
   */
  @TestVisible
  private static List<Lead_Event__e> formLeadEventList(
    List<Lead> records,
    Map<Id, User> mapOfOwnerLanIds,
    Map<Id, Account> mapOfAccount,
    Map<Id, User> mapOfLastModifiedUserLanIds
  ) {
    List<Lead_Event__e> leadEventList = new List<Lead_Event__e>();
    for (Lead record : records) {
      Lead_Event__e leadEvent = new Lead_Event__e();

      leadEvent.put(ACTION_FIELD, ACTION_UPDATE);
      leadEvent.put(RECORD_TYPE_FIELD, CCRM_LEAD);

      mapOwnerLanIds(record, mapOfOwnerLanIds, leadEvent);

      mapLastModifiedLanIds(record, mapOfLastModifiedUserLanIds, leadEvent);

      mapSubstatus(record, leadEvent);

      getLeadToPlatformEventMapping(record, leadEvent);

      mapSourceSystemIds(mapOfAccount, record, leadEvent);

      leadEventList.add(leadEvent);
    }
    return leadEventList;
  }

  /**
   * @description This method sets lan Ids
   * @name mapOwnerLanIds
   * @param record lead Record
   * @param mapOfOwnerLanIds Map of Owner Lan Id
   * @param leadEvent Lead platform event
   */
  @TestVisible
  private static void mapOwnerLanIds(
    Lead record,
    Map<Id, User> mapOfOwnerLanIds,
    Lead_Event__e leadEvent
  ) {
    leadEvent.put(
      OWNER_LAN_ID_FIELD,
      mapOfOwnerLanIds.get(record.OwnerId)?.Lan_Id__c
    );
  }

  /**
   * @description This method sets lan Ids
   * @name mapLastModifiedLanIds
   * @param record lead Record
   * @param mapOfLastModifiedUserLanIds Map of Last Modified Lan Id
   * @param leadEvent Lead platform event
   */
  @TestVisible
  private static void mapLastModifiedLanIds(
    Lead record,
    Map<Id, User> mapOfLastModifiedUserLanIds,
    Lead_Event__e leadEvent
  ) {
    leadEvent.put(
      LAST_MODIFIED_BY_FIELD,
      mapOfLastModifiedUserLanIds.get(record.LastModifiedById)?.Lan_Id__c
    );
  }

  /**
   * @description This method sets SubStatus__c and Opp_Id__c
   * @name mapSubstatus
   * @param record Lead record
   * @param leadEvent Lead platform event
   */
  @TestVisible
  private static void mapSubstatus(Lead record, Lead_Event__e leadEvent) {
    if (mapOfOpportunityId.containsKey(record.Id)) {
      leadEvent.put(
        SUBSTATUS_FIELD,
        mapOfResponseLogLeadSubStatus.get(mapOfOpportunityId.get(record.Id))
      );
      leadEvent.put(OPP_FIELD, mapOfOpportunityId.get(record.Id));
      return;
    }
    leadEvent.put(
      SUBSTATUS_FIELD,
      mapOfResponseLogLeadSubStatus.get(record.Id)
    );
  }

  /**
   * @description This method returns mapped fields (Lead to Lead_Event__e (Platform Event))
   * in Custom Metadata - CCRM Lead to Platform Event Mapping for ADOBE/UNICA/CCRM
   * @name getLeadToPlatformEventMapping
   * @param record Lead record
   * @param leadEvent Platform event
   */
  @TestVisible
  private static void getLeadToPlatformEventMapping(
    Lead record,
    Lead_Event__e leadEvent
  ) {
    List<CCRM_Lead_to_Platform_Event_Mapping__mdt> filteredMdtRecords = QueryLeadToPlatformEventMapping.get(
      DESTINATION_SYSTEM_ALL
    );

    generateLeadEventFromMd(record, filteredMdtRecords, leadEvent);
  }

  /**
   * @description This method returns mapped fields (Lead to Lead_Event__e (Platform Event))
   * in Custom Metadata - CCRM Lead to Platform Event Mapping for ADOBE/UNICA/CCRM
   * @name mapStatus
   * @param record Lead record
   * @param leadEvent Platform event
   * @param platformEventField Platform event field
   */
  @TestVisible
  private static void getLeadToPlatformEventMappingForStatus(
    Lead record,
    Lead_Event__e leadEvent,
    String platformEventField
  ) {
    leadEvent.put(
      platformEventField,
      QueryLeadStatusTransformation.get(
          record.Status + ' ' + record.Lead_Outcome__c
        )
        ?.UNICA_Lead_Status__c ??
        QueryLeadStatusTransformation.get(record.Status)?.UNICA_Lead_Status__c
    );
  }

  /**
   * @description This method sets Customer_ID__c/Business_ID__cCLG_ID__c in platform event
   * @name mapSourceSystemIds
   * @param mapOfAccount Map of Accounts
   * @param record Lead record
   * @param leadEvent Lead platform event
   */
  @TestVisible
  private static void mapSourceSystemIds(
    Map<Id, Account> mapOfAccount,
    Lead record,
    Lead_Event__e leadEvent
  ) {
    string accountType = ACCOUNT_TYPE_MAP.get(
      mapOfAccount.get(record.FinServ__RelatedAccount__c)?.RecordTypeId
    );

    if (accountType == null) {
      leadEvent.put(CUSTOMER_TYPE_FIELD, PROSPECT_VALUE);
      if (
        record.Lead_Originator__c == ORIGINATOR_CCRM &&
        String.isBlank(record.FinServ__RelatedAccount__c)
      ) {
        leadEvent.put(PROSPECT_FIELD, NEW_VALUE);
      }
      return;
    }
    leadEvent.put(
      CUSTOMER_TYPE_FIELD,
      ACCOUNT_TYPE_TO_CUSTOMER_TYPE_MAP.get(accountType)
    );
    leadEvent.put(
      ACCOUNT_TYPE_TO_EVENTFIELDNAME_MAP.get(accountType),
      mapOfAccount.get(record.FinServ__RelatedAccount__c).Source_System_ID__c
    );
  }

  /**
   * @description Publish Lead - Response update to UNICA or Adobe via MuleSoft.
   * @name publishLeadResponseUpdateToAdobeOrUnica
   * @param listOfLeads List of Leads
   * @param oldMap Map of old lead records
   */
  public void publishLeadResponseUpdateToAdobeOrUnica(
    List<Lead> listOfLeads,
    Map<Id, Lead> oldMap
  ) {
    Set<Id> leadIds = ListUtil.getIds(listOfLeads, Lead.Id);

    List<Lead_Response_Event__e> leadResponseEventList = CCRMLeadPlatformEventHelper.getLeadResponseEventList(
      listOfLeads,
      leadIds
    );

    DML_REPOSITORY.doPublish(leadResponseEventList);
  }

  /**
   * @description This method is used by Admin to resend PE incase there is any error
   * @name resendManualLeadPlatformEvent
   * @param leadIds Set of lead ids
   */
  public static void resendManualLeadPlatformEvent(Set<Id> leadIds) {
    List<Lead> leads = CCRMLeadPlatformEventHelper.getLeadData(leadIds);
    new CommercialLeadPlatformEventActions().publishManualLeads(leads);
  }
}
