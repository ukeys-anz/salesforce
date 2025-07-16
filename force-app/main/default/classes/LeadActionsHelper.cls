/**
 * Helper class to manage Lead-related actions, specifically for creating callback tasks.
 * @author Aman Gupta
 * @since 2025-01-16
 * @description Lead Trigger Helper
 */
public with sharing class LeadActionsHelper {
  private static final Map<String, String> LEAD_FIELDS_WITH_ERROR_MSG_MAP = new Map<String, String>{
    'Business_ID__c' => 'BUSINESS NUMBER NOT FOUND',
    'Customer_ID__c' => 'CUSTOMER NUMBER NOT FOUND',
    'CLG_ID__c' => 'CLG NOT FOUND'
  };
  private static final Set<String> LEAD_SOURCE = new Set<String>{
    'Web explore',
    'Web explore AEM exit page',
    'AEM promo page'
  };
  private static final String CAMPAIGN_NOT_FOUND_ERROR_MESSAGE = 'CAMPAIGN DOES NOT EXIST OR NOT ACTIVE';
  private static final String ENTITY_TYPE_INDIVIDUAL = 'Individual';
  private static final String ENTITY_TYPE_CLG = 'Customer Lending Group';
  private static final String ORIGINATOR_ADOBE = 'Adobe';
  private static final String ORIGINATOR_UNICA = 'UNICA';
  private static final String ANZ_DOT_COM = 'ANZ.com';
  private static final String ANZ_CAMPAIGNS = 'ANZ Campaigns';
  private static final Map<String, String> LEAD_FIELDS_WITH_ENTITY_TYPE_MAP = new Map<String, String>{
    'Customer_ID__c' => ENTITY_TYPE_INDIVIDUAL,
    'CLG_ID__c' => ENTITY_TYPE_CLG
  };
  private static final LeadActionsRepository LEAD_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Populate fields of New Leads before Inserting.
   *  - Priority__c: updated from campaign, or default value if not available
   *  - Description: updated from campaign if available
   * @name populateFieldsFromCampaign
   * @param records List of lead records.
   */
  public static void populateFieldsFromCampaign(List<Lead> records) {
    List<Lead> filteredRecords = ListUtil.filter(records)
      .isNotNull(Lead.Campaign_Code__c)
      .toList();
    Map<String, Campaign> mapCampaignCodeRecord = getLeadCampaigns(
      filteredRecords
    );
    setFields(filteredRecords, mapCampaignCodeRecord);
    populateCampaignCode(filteredRecords, mapCampaignCodeRecord);
  }

  private static void setFields(
    List<Lead> filteredRecords,
    Map<String, Campaign> mapCampaignCodeRecord
  ) {
    for (Lead record : filteredRecords) {
      Boolean hasKey = mapCampaignCodeRecord.containsKey(
        record.Campaign_Code__c
      );
      if (hasKey) {
        populatePriorityAndDescription(record, mapCampaignCodeRecord);
      } else if (record.Lead_Originator__c == ORIGINATOR_UNICA) {
        record.addError(CAMPAIGN_NOT_FOUND_ERROR_MESSAGE);
      }
    }
  }

  private static void populateCampaignCode(
    List<Lead> filteredRecords,
    Map<String, Campaign> mapCampaignCodeRecord
  ) {
    for (Lead record : filteredRecords) {
      Boolean hasKey = mapCampaignCodeRecord.containsKey(
        record.Campaign_Code__c
      );
      //CC-4179 populate campaign Name from Campaign for ML
      if (
        record.RecordTypeId == RTLead.mlcrmLead &&
        String.isBlank(record.Campaign_Name__c) &&
        hasKey
      ) {
        record.Campaign_Name__c = mapCampaignCodeRecord.get(
            record.Campaign_Code__c
          )
          .Name;
      }
    }
  }

  /**
   * @description Populate fields of New Leads before Inserting.
   *  - Priority__c: updated from campaign, or default value if not available
   *  - Description: updated from campaign if available
   * @name populatePriorityAndDescription
   * @param record Lead record
   * @param mapCampaignCodeRecord Map of campaign code vs Campaign
   */
  private static void populatePriorityAndDescription(
    Lead record,
    Map<String, Campaign> mapCampaignCodeRecord
  ) {
    Campaign campaignRec = mapCampaignCodeRecord.get(record.Campaign_Code__c);
    record.Priority__c = campaignRec.Priority__c !=
      Decimal.ValueOf(LABEL.CCRM_LeadDefaultPriorityValue)
      ? campaignRec.Priority__c
      : Decimal.ValueOf(LABEL.CCRM_LeadDefaultPriorityValue);
    record.Description = String.isBlank(record.Description)
      ? campaignRec.Description
      : record.Description;
  }

  /**
   * @description Populate fields of New Leads before Inserting.
   *  - FinServ__RelatedAccount__c: updated by search for account matching Customer_ID__c/CLG_ID__c/Business_ID__c
   * @name populateRelatedAccount
   * @param records List of lead records.
   */
  public static void populateRelatedAccount(List<Lead> records) {
    Set<SObjectField> eligibleSetOfFields = new Set<SObjectField>{
      Lead.Customer_ID__c,
      Lead.Business_ID__c,
      Lead.CLG_ID__c
    };
    List<Lead> filteredLeads = ListUtil.filter(records)
      .anyNotNull(eligibleSetOfFields)
      .equals(Lead.Lead_Originator__c, ORIGINATOR_UNICA)
      .toList();
    Map<String, Account> accountMap = getAccountsBySourceSystemId(
      filteredLeads
    );
    setRelatedAccount(filteredLeads, accountMap);
  }

  /**
   * @description set related account
   * @name setRelatedAccount
   * @param filteredLeads List of lead records.
   * @param accountMap account map
   */
  private static void setRelatedAccount(
    List<Lead> filteredLeads,
    Map<String, Account> accountMap
  ) {
    for (Lead record : filteredLeads) {
      for (String fieldName : LEAD_FIELDS_WITH_ERROR_MSG_MAP.keySet()) {
        String fieldValue = (String) record.get(fieldName);
        Account acct = accountMap.get(fieldValue);
        if (String.isBlank(fieldValue)) {
          continue;
        }
        if (!accountMap.containsKey(fieldValue)) {
          record.addError(LEAD_FIELDS_WITH_ERROR_MSG_MAP.get(fieldName));
          continue;
        }
        record.FinServ__RelatedAccount__c = acct.Id;
        record.Entity_Type__c = LEAD_FIELDS_WITH_ENTITY_TYPE_MAP.get(
          fieldName
        ) ?? acct.FinServ__CustomerType__c;
      }
    }
  }

  /**
   * @description Populate lead source of New adobe Leads before Inserting.
   *  - leadSource: populate it as per Originator
   * @name populateLeadSourceForAdobeOrigin
   * @param records List of lead records.
   */
  public static void populateLeadSourceForAdobeOrigin(List<Lead> records) {
    List<Lead> adobeLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, ORIGINATOR_ADOBE)
      .toList();
    ListUtil.setField(adobeLeads, Lead.LeadSource, ANZ_DOT_COM);
  }

  /**
   * @description Populate lead source of New unica Leads before Inserting.
   *  - leadSource: populate it as per Originator
   * @name populateLeadSourceForUnicaOrigin
   * @param records List of lead records.
   */
  public static void populateLeadSourceForUnicaOrigin(List<Lead> records) {
    List<Lead> unicaLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, ORIGINATOR_UNICA)
      .toList();
    ListUtil.setField(unicaLeads, Lead.LeadSource, ANZ_CAMPAIGNS);
  }

  /**
   * @description Populate Registered_Company__c on New Leads before Inserting based on Entity Type.
   *  - Registered_Company__c: populate it as per Entity Type
   * @name populateRegisteredCompany
   * @param leadList List of lead records.
   */
  public static void populateRegisteredCompany(List<Lead> leadList) {
    List<Lead> filteredLeads = ListUtil.filter(leadList)
      .equals(Lead.Entity_Type__c, ENTITY_TYPE_INDIVIDUAL)
      .toList();
    ListUtil.setField(filteredLeads, Lead.Registered_Company__c, 'No');
  }

  /**
   * @description Get list of Campaigns from Campaign_Code__c on CCRM Leads.
   * @name getLeadCampaigns
   * @param records List of lead records.
   * @return Map<String, Campaign> Type where Key is Campaign_Code__c.
   */
  public static Map<String, Campaign> getLeadCampaigns(List<Lead> records) {
    Set<String> campaignCodes = ListUtil.getStrings(
      records,
      Lead.Campaign_Code__c
    );
    List<Campaign> campaignRecords = LEAD_REPOSITORY.getCampaignRecords(
      campaignCodes
    );
    return (Map<String, Campaign>) ListUtil.mapBy(
      campaignRecords,
      Campaign.Code__c
    );
  }

  /**
   * @description This method returns related party by Source System ID passed from UNICA lead
   * @name getAccountsBySourceSystemId
   * @param records List of lead records
   * @return Map<String, Account> where Key is Source_System_ID__c.
   */
  public static Map<String, Account> getAccountsBySourceSystemId(
    List<Lead> records
  ) {
    Set<String> accountIds = new Set<String>();
    for (Lead record : records) {
      for (String fieldName : LEAD_FIELDS_WITH_ERROR_MSG_MAP.keySet()) {
        String value = (String) record.get(fieldName);
        if (String.isBlank(value)) {
          continue;
        }
        accountIds.add(value);
      }
    }
    return (Map<String, Account>) ListUtil.mapBy(
      LEAD_REPOSITORY.getRelatedAccounts(accountIds),
      Account.Source_System_ID__c
    );
  }

  /**
   * @description Creates a callback task for the provided Lead record.
   * @param newLeads The Lead record from the trigger.
   */
  public static void checkAndCreateCallbackTask(List<Lead> newLeads) {
    List<Task> tasksToCreate = new List<Task>();
    try {
      Task_Creation_Mapping__mdt callbackRequestMapping = Task_Creation_Mapping__mdt.getInstance(
        'AEM_BOH_Call_Back_Request'
      );
      List<Lead> bohLeads = ListUtil.filter(newLeads)
        .equals(Lead.Is_BOH_Lead__c, true)
        .equals(Lead.LeadSource, LEAD_SOURCE)
        .toList();
      for (Lead record : bohLeads) {
        Task callbackTask = TaskUtils.generateTaskFromMetadata(
          callbackRequestMapping
        );
        callbackTask.WhoId = record.Id;
        callbackTask.Pub_Sub_Event_Id__c = record.Pub_Sub_Event_Id__c;
        callbackTask.ActivityDate = System.today().addDays(5);
        tasksToCreate.add(callbackTask);
      }
      DML_REPOSITORY.doInsert(tasksToCreate, new DmlConfig().allowPartial());
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
  }
  /**
   * @description This method is used to map referral status with lead status
   * @name mapLeadStatusWithReferralStatus
   * @param filteredLeads List of filtered lead records.
   */
  public static void mapLeadStatusWithReferralStatus(List<Lead> filteredLeads) {
    for (Lead lead : filteredLeads) {
      String key = TextUtils.concat(
        new Set<String>{ 'CCRM', lead.Status, lead.Lead_Outcome__c }
      );
      lead.Referral_Status__c = QueryLeadToReferralStatusMapping.get(key)
        ?.Referral_Status__c;
    }
  }
}
