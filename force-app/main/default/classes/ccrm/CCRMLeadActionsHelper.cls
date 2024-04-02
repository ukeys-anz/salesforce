/**
 * @author Mairaj H
 * @since  04/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadActionsHelper is a helper class to handle all the CCRM (Commercial CRM),MLCRM Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMLeadActionsHelper {
  @TestVisible
  static final String CAMPAIGN_NOT_FOUND_ERROR_MESSAGE = 'CAMPAIGN DOES NOT EXIST OR NOT ACTIVE';
  @TestVisible
  static final String BUSINESS_NUMBER_NOT_FOUND_ERROR_MESSAGE = 'BUSINESS NUMBER NOT FOUND';
  @TestVisible
  static final String CUSTOMER_NUMBER_NOT_FOUND_ERROR_MESSAGE = 'CUSTOMER NUMBER NOT FOUND';
  @TestVisible
  static final String CLG_NOT_FOUND_ERROR_MESSAGE = 'CLG NOT FOUND';
  private static final String LEAD_OWNERSHIP_ERROR = 'Leads can only be transferred within your segment.';

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
    Map<String, Account> mapAccountRecord = new Map<String, Account>();
    mapAccountRecord = new CCRMLeadMappingEngine()
      .getAccountsBySourceSystemId(records);

    for (Lead record : records) {
      if (
        CCRMLeadUtil.isCCRMLeadType(record) ||
        CCRMLeadUtil.isMLCRMLeadType(record)
      ) {
        if (!String.isBlank(record.Business_ID__c)) {
          if (mapAccountRecord.containsKey(record.Business_ID__c)) {
            record.FinServ__RelatedAccount__c = mapAccountRecord.get(
                record.Business_ID__c
              )
              .Id;
          } else if (CCRMLeadUtil.isUnicaLead(record)) {
            record.addError(BUSINESS_NUMBER_NOT_FOUND_ERROR_MESSAGE);
          }
        } else if (!String.isBlank(record.Customer_ID__c)) {
          if (mapAccountRecord.containsKey(record.Customer_ID__c)) {
            record.FinServ__RelatedAccount__c = mapAccountRecord.get(
                record.Customer_ID__c
              )
              .Id;
          } else if (CCRMLeadUtil.isUnicaLead(record)) {
            record.addError(CUSTOMER_NUMBER_NOT_FOUND_ERROR_MESSAGE);
          }
        } else if (!String.isBlank(record.CLG_ID__c)) {
          if (mapAccountRecord.containsKey(record.CLG_ID__c)) {
            record.FinServ__RelatedAccount__c = mapAccountRecord.get(
                record.CLG_ID__c
              )
              .Id;
          } else if (CCRMLeadUtil.isUnicaLead(record)) {
            record.addError(CLG_NOT_FOUND_ERROR_MESSAGE);
          }
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
   * @description Throw error if we try to transfer the lead ownership from BB to SBB/SBB-NBC and vice versa
   * - ownerID: throw error when try to change between segment.
   * @name transferLeadOwnership
   * @param newleadList List of new lead records.
   * @param oldLeadMap Map of old lead records.
   */
  public static void transferLeadOwnership(
    List<Lead> newleadList,
    Map<Id, Lead> oldLeadMap
  ) {
    List<Lead> leadList = new List<Lead>();
    Map<Id, User> userMap = new Map<Id, User>();
    Set<Id> ownerIdSet = new Set<Id>();
    List<String> bbRolesList = new List<String>();
    List<String> sbbRolesList = new List<String>();
    String newCommercialSegment = '';
    String oldCommercialSegment = '';
    if (
      System.UserInfo.getProfileId() ==
      CommonUtil.getProfileByName('ANZ CCRM Standard User').Id
    ) {
      for (Lead newLeadRec : newLeadList) {
        if (
          newLeadRec.RecordTypeId == CCRMConstants.CCRM_LEAD_RT_ID &&
          newLeadRec.OwnerId != oldLeadMap.get(newLeadRec.Id).OwnerId
        ) {
          leadList.add(newLeadRec);
          ownerIdSet.add(newLeadRec.OwnerId);
          ownerIdSet.add(oldLeadMap.get(newLeadRec.Id).OwnerId);
        }
      }

      if (!ownerIdSet.isEmpty()) {
        userMap = new Map<Id, User>(
          [
            SELECT Id, Profile.Name, UserRole.Name, Commercial_Segment__c
            FROM User
            WHERE Id IN :ownerIdSet
          ]
        );

        for (Lead newLeadRec : leadList) {
          newCommercialSegment = userMap.get(newLeadRec.OwnerId)
            .Commercial_Segment__c;
          oldCommercialSegment = userMap.get(
              oldLeadMap.get(newLeadRec.Id).OwnerId
            )
            .Commercial_Segment__c;
          if (
            String.isNotBlank(oldCommercialSegment) &&
            (CCRMConstants.BB_SEGMENT.equalsIgnoreCase(oldCommercialSegment) ||
            CCRMConstants.SBB_SEGMENT.equalsIgnoreCase(oldCommercialSegment) ||
            CCRMConstants.SBB_NBC_SEGMENT.equalsIgnoreCase(
              oldCommercialSegment
            )) &&
            (String.isBlank(newCommercialSegment) ||
            newCommercialSegment != oldCommercialSegment)
          ) {
            newLeadRec.addError(LEAD_OWNERSHIP_ERROR);
          }
        }
      }
    }
  }
}
