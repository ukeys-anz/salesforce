/**
 * @author Mairaj H
 * @since  04/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadActionsHelper is a helper class to handle all the CCRM (Commercial CRM),MLCRM Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMLeadActionsHelper {
  private static final Map<String, String> LEAD_FIELDS_WITH_ERROR_MSG_MAP = new Map<String, String>{
    'Business_ID__c' => 'BUSINESS NUMBER NOT FOUND',
    'Customer_ID__c' => 'CUSTOMER NUMBER NOT FOUND',
    'CLG_ID__c' => 'CLG NOT FOUND'
  };
  @TestVisible
  static final String CAMPAIGN_NOT_FOUND_ERROR_MESSAGE = 'CAMPAIGN DOES NOT EXIST OR NOT ACTIVE';
  @TestVisible
  static final String BUSINESS_NUMBER_NOT_FOUND_ERROR_MESSAGE = 'BUSINESS NUMBER NOT FOUND';
  @TestVisible
  static final String CUSTOMER_NUMBER_NOT_FOUND_ERROR_MESSAGE = 'CUSTOMER NUMBER NOT FOUND';
  @TestVisible
  static final String CLG_NOT_FOUND_ERROR_MESSAGE = 'CLG NOT FOUND';
  @TestVisible
  static final String ENTITY_TYPE_INDIVIDUAL = 'Individual';
  @TestVisible
  static final String ENTITY_TYPE_CLG = 'Customer Lending Group';
  private static final String ORIGINATOR_UNICA = 'UNICA';
  private static final Set<ID> SET_OF_ELIGIBLE_RT_ID = new Set<Id>{
    RTLead.commercialLead,
    RTLead.mlcrmLead
  };
  private static final Map<String, String> LEAD_FIELDS_WITH_ENTITY_TYPE_MAP = new Map<String, String>{
    'Customer_ID__c' => ENTITY_TYPE_INDIVIDUAL,
    'CLG_ID__c' => ENTITY_TYPE_CLG
  };

  private static final CCRMLeadRepository LEAD_REPOSITORY = (CCRMLeadRepository) Lib_InstanceProvider.forType(
    CCRMLeadRepository.class
  );

  /**
   * @description Set field CCRM_Duplicate_Block__c to true if the lead's status is New or In progress
   * @name setDuplicateBlock
   * @param record current record
   * @param oldRec old record
   */
  public static void setDuplicateBlock(Lead record, Lead oldRec) {
    if (CCRMLeadUtil.isCCRMLeadType(record)) {
      if (
        (record.Status == CCRMConstants.STATUS_ASSIGNED ||
        record.Status == CCRMConstants.STATUS_IN_PROGRESS)
      ) {
        record.CCRM_Duplicate_Block_Check__c = 'Yes';
      } else {
        record.CCRM_Duplicate_Block_Check__c = 'No';
      }
    } else if (CCRMLeadUtil.isMLCRMLeadType(record)) {
      if (
        (record.Status == CCRMConstants.STATUS_NEW ||
        record.Status == CCRMConstants.STATUS_IN_PROGRESS ||
        record.Status == MLCRMConstants.STATUS_OPPORTUNITY_INDENTIFIED)
      ) {
        record.CCRM_Duplicate_Block_Check__c = 'Yes';
      } else {
        record.CCRM_Duplicate_Block_Check__c = 'No';
      }
    }
  }

  /**
   * @description Populate fields of New Leads before Inserting.
   *  - Priority__c: updated from campaign, or default value if not available
   *  - Description: updated from campaign if available
   * @name populateFieldsFromCampaign
   * @param records List of lead records.
   */
  public static void populateFieldsFromCampaign(List<Lead> records) {
    Map<String, Campaign> mapCampaignCodeRecord = CCRMCampaignActions.getCCRMLeadCampaigns(
      records
    );
    Decimal priorityValue;
    for (Lead record : records) {
      if (
        CCRMLeadUtil.isCCRMLeadType(record) ||
        CCRMLeadUtil.isMLCRMLeadType(record)
      ) {
        if (mapCampaignCodeRecord.containsKey(record.Campaign_Code__c)) {
          priorityValue = mapCampaignCodeRecord.get(record.Campaign_Code__c)
              .Priority__c !=
            Decimal.ValueOf(LABEL.CCRM_LeadDefaultPriorityValue)
            ? mapCampaignCodeRecord.get(record.Campaign_Code__c).Priority__c
            : Decimal.ValueOf(LABEL.CCRM_LeadDefaultPriorityValue);
          record.Priority__c = priorityValue;
          record.Description = String.isBlank(record.Description)
            ? mapCampaignCodeRecord.get(record.Campaign_Code__c).Description
            : record.Description;
        } else if (CCRMLeadUtil.isUnicaLead(record)) {
          record.addError(CAMPAIGN_NOT_FOUND_ERROR_MESSAGE);
        }
      }
      //CC-4179 populate campaign Name from Campaign for ML
      if (
        CCRMLeadUtil.isMLCRMLeadType(record) &&
        String.isNotBlank(record.Campaign_Code__c) &&
        mapCampaignCodeRecord.containsKey(record.Campaign_Code__c) &&
        String.isBlank(record.Campaign_Name__c)
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
   *  - FinServ__RelatedAccount__c: updated by search for account matching Customer_ID__c/CLG_ID__c/Business_ID__c
   * @name populateRelatedAccount
   * @param records List of lead records.
   */
  public static void populateRelatedAccount(List<Lead> records) {
    Map<String, Account> mapAccountRecord = getAccountsBySourceSystemId(
      records
    );
    List<Lead> filteredRecords = ListUtil.filter(records)
      .equals(Lead.RecordTypeId, SET_OF_ELIGIBLE_RT_ID)
      .toList();
    for (Lead record : filteredRecords) {
      for (String fieldName : LEAD_FIELDS_WITH_ERROR_MSG_MAP.keySet()) {
        String fieldValue = (String) record.get(fieldName);
        if (String.isBlank(fieldValue)) {
          continue;
        }
        if (mapAccountRecord.containsKey(fieldValue)) {
          record.FinServ__RelatedAccount__c = mapAccountRecord.get(fieldValue)
            .Id;
          record.Entity_Type__c = LEAD_FIELDS_WITH_ENTITY_TYPE_MAP.get(
            fieldName
          ) ?? mapAccountRecord.get(fieldValue).FinServ__CustomerType__c;
        } else if (record.Lead_Originator__c == ORIGINATOR_UNICA) {
          record.addError(LEAD_FIELDS_WITH_ERROR_MSG_MAP.get(fieldName));
        }
      }
    }
  }

  /**
   * @description Populate lead source of New Leads before Inserting.
   *  - leadSource: populate it as per Originator
   * @name populateLeadSource
   * @param records List of lead records.
   */
  public static void populateLeadSource(List<Lead> records) {
    for (Lead record : records) {
      //CC-1874 Set lead source for Adobe/Unica for MCLRM lead
      if (
        CCRMLeadUtil.isMLCRMLeadType(record) &&
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE
      ) {
        record.LeadSource = MLCRMConstants.ANZ_DOT_COM;
      } else if (
        (CCRMLeadUtil.isMLCRMLeadType(record) ||
        CCRMLeadUtil.isCCRMLeadType(record)) &&
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_UNICA
      ) {
        record.LeadSource = MLCRMConstants.ANZ_CAMPAIGNS;
      }
    }
  }

  /**
   * @description Populate Registered_Company__c on New Leads before Inserting based on Entity Type.
   *  - Registered_Company__c: populate it as per Entity Type
   * @name populateRegisteredCompany
   * @param leadList List of lead records.
   */
  public static void populateRegisteredCompany(List<Lead> leadList) {
    List<Lead> filteredLeadsList = ListUtil.filter(leadList)
      .equals(
        Lead.RecordTypeId,
        QueryRT.of(Lead.SObjectType).getId('CCRM_Lead')
      )
      .equals(Lead.Entity_Type__c, ENTITY_TYPE_INDIVIDUAL)
      .toList();

    for (Lead leadIterator : filteredLeadsList) {
      leadIterator.Registered_Company__c = 'No';
    }
  }

  /**
   * @description determines if login user is CCRM User
   * @name isCCRMUser
   * @return Boolen
   */
  public static Boolean isCCRMUser() {
    return LEAD_REPOSITORY.getUserProfileId() ==
      CommonUtil.getProfileByName(CCRMConstants.CCRM_PROFILE_NAME).Id;
  }
  /**
   * @description determines if lead record type is ccrm Lead then prevent deletion
   * @name checkCCRMLead
   * @param records List of new lead records.
   */
  public static void validateLeadTypeForDeletion(List<Lead> records) {
    if (!isCCRMUser()) {
      return;
    }
    for (Lead rec : records) {
      if (CCRMLeadUtil.isCCRMLeadType(rec)) {
        rec.addError(CCRMConstants.DELETE_ERROR);
      }
    }
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
    List<Lead> unicaLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, ORIGINATOR_UNICA)
      .toList();

    for (Lead selectLead : unicaLeads) {
      for (String fieldName : LEAD_FIELDS_WITH_ERROR_MSG_MAP.keySet()) {
        String fieldValue = (String) selectLead.get(fieldName);
        if (String.isNotBlank(fieldValue)) {
          accountIds.add(fieldValue);
        }
      }
    }
    return (Map<String, Account>) ListUtil.mapBy(
      LEAD_REPOSITORY.getRelatedAccounts(accountIds),
      Account.Source_System_ID__c
    );
  }
}
