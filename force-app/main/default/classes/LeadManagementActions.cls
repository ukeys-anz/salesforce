/**
 * @author Sahil S
 * @since  08/2021
 * @modified Hitesh & Prahlad
 * @since March 2025
 * @description LeadManagementActions is class to handle all the Common Lead Actions
 */
public with sharing class LeadManagementActions {
  private static set<String> setOfFollowUpForContactAttempted = new Set<String>{
    'Call Back',
    'Contact Attempted',
    'Accepted',
    'Appointment Booked'
  };
  private static set<String> setOfFollowUpForAppointment = new Set<String>{
    'Accepted',
    'Appointment Booked'
  };
  private final static String STATUS_NEW = 'New';
  private final static String ORIGINATOR_CCRM = 'CCRM';
  private final static String ORIGINATOR_MLCRM = 'MLCRM';
  private final static String ORIGINATOR_UNICA = 'UNICA';
  private final static String STATUS_CONVERTED = 'Converted';
  private final static String ORIGINATOR_ADOBE = 'Adobe';
  private final static String COPY_LEAD_ID = 'copyLeadId';
  private static final String STATUS_IN_PROGRESS = 'In progress';
  private static final String LEAD_NEW_TO_INPROGRESS = 'LeadNewToInProgress';
  private static final Set<String> EMPTY_NULL_SET = new Set<String>{ '', null };
  final static LeadActionsRepository LEAD_ACTION_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  final static UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static List<Schema.FieldSetMember> fieldSetMembers = Schema.SObjectType.Lead.fieldSets.CCRM_Previous_Lead_Fields.getFields();
  public static set<ID> calloutLeadIds = new Set<ID>();
  private static final Set<String> SET_OF_ELIGIBLE_LEAD_ORIGINATOR = new Set<String>{
    'CCRM',
    'UNICA',
    'Adobe'
  };

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description Before Update Automated actions of a Converted Lead.
   * @name blankFollowUpDateOnLeadConvert
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @param records from the trigger
   */
  public static void blankFollowUpDateOnLeadConvert(
    Map<Id, Lead> oldMap,
    List<Lead> records
  ) {
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Status, STATUS_CONVERTED)
      .changed(Lead.Status)
      .toList();
    ListUtil.setField(filteredLeads, Lead.Followup_Date__c, null);
  }

  /**
   * @description Notify new Lead Owners.
   * @name notifyLeadOwners
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @param records from the trigger
   */
  public static void notifyLeadOwners(
    Map<Id, Lead> oldMap,
    List<Lead> records
  ) {
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .changed(Lead.OwnerId)
      .toList();
    List<Lead> createChatterPostLeads = getUserOwnerLeads(filteredLeads);
    if (createChatterPostLeads.isEmpty()) {
      return;
    }
    // Chatter Post for newly assigned Leads.
    ChatterPostActions.createLeadChatterPost(
      createChatterPostLeads,
      Label.CCRM_NewSourceLeadMessage
    );
  }

  /**
   * @description This method is to get filtered Lead which has owner id as user
   * @param records List of lead records
   * @return Set of accountId
   */
  @testVisible
  private static List<Lead> getUserOwnerLeads(List<Lead> records) {
    List<Lead> createChatterPostLeads = new List<Lead>();
    for (Lead record : records) {
      if (record.OwnerID.getsobjecttype() != User.sobjecttype) {
        continue;
      }
      createChatterPostLeads.add(record);
    }
    return createChatterPostLeads;
  }

  /**
   * @description Notify new Lead Owners.
   * @name notifyLeadOwnersForAdobeOrUnicaOrigin
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @param records from the trigger
   */
  public static void notifyLeadOwnersForAdobeOrUnicaOrigin(
    Map<Id, Lead> oldMap,
    List<Lead> records
  ) {
    Set<String> setOfEligibleLeadOriginator = new Set<String>{
      ORIGINATOR_UNICA,
      ORIGINATOR_ADOBE
    };
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Lead_Originator__c, setOfEligibleLeadOriginator)
      .changed(Lead.OwnerId)
      .toList();
    List<Lead> createChatterPostLeads = getUserOwnerLeads(filteredLeads);
    if (createChatterPostLeads.isEmpty()) {
      return;
    }
    // Chatter Post for newly assigned Leads.
    ChatterPostActions.createLeadChatterPost(
      createChatterPostLeads,
      Label.CCRM_NewSourceLeadMessage
    );
  }

  /**
   * @description Copy Lead Id from Lead_Auto_Number on Lead Insert.
   * @name copyLeadId
   * @param records from the trigger of type List<Lead>.
   */
  public static void copyLeadId(List<Lead> records) {
    List<Lead> filteredLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Id__c, EMPTY_NULL_SET)
      .toList();
    List<Lead> unicaLeads = ListUtil.filter(records)
      .contains(Lead.Lead_Id__c, 'null')
      .toList();
    filteredLeads.addAll(unicaLeads);
    List<Lead> updateLeads = getUpdatedLeads(filteredLeads);
    DML_REPOSITORY.doUpdate(updateLeads, new DmlConfig().allowPartial());
  }

  /**
   * @description get updated leads
   * @name getUpdatedLeads
   * @param filteredLeads list of filtered leads
   * @return List<Lead>
   */
  private static List<Lead> getUpdatedLeads(List<Lead> filteredLeads) {
    List<Lead> updateLeads = new List<Lead>();
    for (Lead record : filteredLeads) {
      updateLeads.add(
        new Lead(
          Id = record.id,
          Lead_Id__c = record.Lead_Auto_Number__c,
          Skip_Validations__c = COPY_LEAD_ID
        )
      );
    }
    return updateLeads;
  }

  /**
   * @description After Insert to create Campaign Member to link Leads with their respective Campaigns.
   * @name createCampaignMember
   * @param records List of lead records.
   */
  public static void createCampaignMember(List<Lead> records) {
    Map<String, Campaign> mapCampaignCodeRecord = LeadActionsHelper.getLeadCampaigns(
      records
    );
    List<Lead> filteredLeads = ListUtil.filter(records)
      .notequals(Lead.Campaign_Code__c, EMPTY_NULL_SET)
      .toList();

    List<CampaignMember> newCampaignMembers = generateNewCampaignMembersList(
      filteredLeads,
      mapCampaignCodeRecord
    );

    DML_REPOSITORY.doInsert(newCampaignMembers, new DmlConfig().allowPartial());
  }

  /**
   * @description This is used to form the new campaign member list
   * @param filteredLeads filtered leads list
   * @param mapCampaignCodeRecord Map of campaign code to campaign record
   * @return List<CampaignMember> List of campaign members
   */
  private static List<CampaignMember> generateNewCampaignMembersList(
    List<Lead> filteredLeads,
    Map<String, Campaign> mapCampaignCodeRecord
  ) {
    List<CampaignMember> newCampaignMembers = new List<CampaignMember>();

    for (Lead selectLead : filteredLeads) {
      Campaign campaignRec = mapCampaignCodeRecord.get(
        selectLead.Campaign_Code__c
      );
      if (campaignRec == null) {
        continue;
      }
      CampaignMember campaignMemberRecord = new CampaignMember();
      campaignMemberRecord.CampaignId = campaignRec.Id;
      campaignMemberRecord.LeadId = selectLead.Id;
      newCampaignMembers.add(campaignMemberRecord);
    }
    return newCampaignMembers;
  }

  /**
   * @description Populate fields of New Leads with the values from Previous lead id lookup
   * @name populateFromPreviousLead
   * @param records List of lead records.
   */
  public static void populateFromPreviousLead(List<Lead> records) {
    List<Lead> filteredLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, 'Adobe')
      .isNotNull(Lead.Previous_Lead__c)
      .toList();
    Set<Id> previousLeadIds = ListUtil.getIds(
      filteredLeads,
      Lead.Previous_Lead__c
    );
    Map<Id, Lead> previousLeadMap = getPreviousrecords(
      previousLeadIds,
      fieldSetMembers
    );
    setLeadRecords(filteredLeads, fieldSetMembers, previousLeadMap);
  }

  /**
   * @description method to query previous lead records
   * @name getPreviousrecords
   * @param previousLeadIds List of previous lead ids
   * @param fieldSetMembers list of fields from fieldSet
   * @return Map<Id, Lead> map of previous lead records
   */
  @testVisible
  private static Map<Id, Lead> getPreviousrecords(
    Set<Id> previousLeadIds,
    List<Schema.FieldSetMember> fieldSetMembers
  ) {
    List<String> leadFields = new List<String>();
    if (previousLeadIds.isEmpty()) {
      return new Map<Id, Lead>();
    }
    for (Schema.FieldSetMember field : fieldSetMembers) {
      leadFields.add(field.FieldPath);
    }
    String leadQuery =
      'SELECT Id, ' +
      String.join(leadFields, ', ') +
      ' FROM Lead WHERE Id IN :leadIds';
    return new Map<Id, Lead>(
      LEAD_ACTION_REPOSITORY.getLeadData(leadQuery, previousLeadIds)
    );
  }

  /**
   * @description method to set lead records
   * @name setLeadRecords
   * @param filteredLeads List of previous lead ids
   * @param fieldSetMembers list of fields from fieldSet
   * @param previousLeadMap previous lead map
   */
  private static void setLeadRecords(
    List<Lead> filteredLeads,
    List<Schema.FieldSetMember> fieldSetMembers,
    Map<Id, Lead> previousLeadMap
  ) {
    for (Lead record : filteredLeads) {
      for (Schema.FieldSetMember field : fieldSetMembers) {
        record.put(
          field.FieldPath,
          previousLeadMap.get(record.Previous_Lead__c).get(field.FieldPath)
        );
      }
    }
  }

  /**
   * @description This method prefill data from Account to Leads when related party added to existing lead
   * @name prefillManualLeadsFromAccountOnUpdate
   * @param records List of lead records
   * @param oldMap Mao of old lead records
   */
  public static void prefillManualLeadsFromAccountOnUpdate(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    Set<String> setOfEligibleLeadOriginator = new Set<String>{
      ORIGINATOR_CCRM,
      ORIGINATOR_MLCRM,
      ORIGINATOR_ADOBE
    };
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Lead_Originator__c, setOfEligibleLeadOriginator)
      .changed(Lead.FinServ__RelatedAccount__c)
      .isNotNull(Lead.FinServ__RelatedAccount__c)
      .toList();
    Set<String> relatedPartyIds = ListUtil.getStrings(
      filteredLeads,
      Lead.FinServ__RelatedAccount__c
    );
    if (relatedPartyIds.isEmpty()) {
      return;
    }
    new CommercialLeadMappingEngine()
      .prefillManualLeadsFromAccount(filteredLeads, relatedPartyIds);
  }

  /**
   * @description This method prefill data from Account to Leads when related party added on lead creation
   * @name prefillManualLeadsFromAccountOnInsert
   * @param records List of lead records
   */
  public static void prefillManualLeadsFromAccountOnInsert(List<Lead> records) {
    Set<String> setOfEligibleLeadOriginator = new Set<String>{
      ORIGINATOR_CCRM,
      ORIGINATOR_MLCRM
    };
    List<Lead> filteredLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, setOfEligibleLeadOriginator)
      .notequals(Lead.FinServ__RelatedAccount__c, EMPTY_NULL_SET)
      .toList();
    Set<String> relatedPartyIds = ListUtil.getStrings(
      filteredLeads,
      Lead.FinServ__RelatedAccount__c
    );
    if (relatedPartyIds.isEmpty()) {
      return;
    }
    new CommercialLeadMappingEngine()
      .prefillManualLeadsFromAccount(filteredLeads, relatedPartyIds);
  }

  /**
   * @description This method prefill data from Account to Leads for UNICA leads
   * @name prefillUnicaLeadsFromAccountOnInsert
   * @param records List of lead records
   */
  public static void prefillUnicaLeadsFromAccountOnInsert(List<Lead> records) {
    Set<SObjectField> eligibleSetOfFields = new Set<SObjectField>{
      Lead.Customer_ID__c,
      Lead.Business_ID__c,
      Lead.CLG_ID__c
    };
    List<Lead> filteredLeads = ListUtil.filter(records)
      .anyNotNull(eligibleSetOfFields)
      .equals(Lead.Lead_Originator__c, ORIGINATOR_UNICA)
      .toList();
    Map<String, Account> accountMap = LeadActionsHelper.getAccountsBySourceSystemId(
      filteredLeads
    );
    List<Lead> applicableforPrefillLeads = ListUtil.filter(filteredLeads)
      .noError()
      .toList();
    if (accountMap.isEmpty() || applicableforPrefillLeads.isEmpty()) {
      return;
    }
    new CommercialLeadMappingEngine()
      .prefillUnicaLeads(applicableforPrefillLeads, accountMap);
  }

  /**
   * @description This method send manual Leads to UNICA
   * @name sendManualLeadsToUnica
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void sendManualLeadsToUnica(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    Set<String> setOfEligibleLeadOriginator = new Set<String>{
      ORIGINATOR_UNICA,
      ORIGINATOR_CCRM
    };
    List<Lead> filteredLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, setOfEligibleLeadOriginator)
      .toList();
    CCRMLeadPlatformEventActions.publishManualLeads(filteredLeads);
  }

  /**
   * @description This method send Lead - Response update to UNICA or Adobe
   * @name publishLeadResponseUpdateToAdobeOrUnica
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void publishLeadResponseUpdateToAdobeOrUnica(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Lead_Originator__c, SET_OF_ELIGIBLE_LEAD_ORIGINATOR)
      .notEquals(Lead.Id, calloutLeadIds)
      .changed(Lead.SubStatus__c)
      .toList();
    CCRMLeadPlatformEventActions.publishLeadResponseUpdateToAdobeOrUnica(
      filteredLeads,
      oldMap
    );
  }
  /**
   * @description This method send CCRM/UNICA/ADOBE lead change update to UNICA or ADOBE
   * @name sendLeadUpdateToUnicaOrAdobe
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void sendLeadUpdateToUnicaOrAdobe(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    if (USER_REPOSITORY.isIntegrationUser()) {
      return;
    }
    Set<SObjectField> fieldsToValidateChange = new Set<SObjectField>{
      Lead.OwnerID,
      Lead.Expiry_Date__c,
      Lead.Status
    };
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Lead_Originator__c, SET_OF_ELIGIBLE_LEAD_ORIGINATOR)
      .notEquals(Lead.Id, calloutLeadIds)
      .notEquals(Lead.Status, 'Converted')
      .anyChanged(fieldsToValidateChange)
      .toList();
    CCRMLeadPlatformEventActions.publishLeadUpdateToUnicaOrAdobe(
      filteredLeads,
      new List<Task>()
    );
  }

  /**
   * @description Set field CCRM_Duplicate_Block__c to true if the lead's status is in Lead status map
   * @name setDuplicateBlock
   * @param records List of Lead records
   * @param oldMap Map of old map
   */
  public static void setDuplicateBlock(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .changed(Lead.Status)
      .toList();
    Map<Id, Set<String>> recordTypeWithLeadStatusesMap = new Map<Id, Set<String>>{
      RTLead.mlcrmLead => new Set<String>{
        'New',
        'In progress',
        'Opportunity Identified'
      },
      RTLead.commercialLead => new Set<String>{ 'Assigned', 'In progress' }
    };
    for (Lead record : filteredLeads) {
      if (
        recordTypeWithLeadStatusesMap.get(record.RecordTypeId)
          ?.contains(record.Status)
      ) {
        record.CCRM_Duplicate_Block_Check__c = 'Yes';
      } else {
        record.CCRM_Duplicate_Block_Check__c = 'No';
      }
    }
  }

  /**
   * @description This method to update lead status when response is logged. 
                  CC-1069 Auto Update Lead status to In Progrees for MLCRM Manual lead update. Added CreatedDate and LastModifiedDate 
                  check due to existing code's insert trigger immediately invokes update trigger. 
                  This check ensures it happen only on update from UI.
   * @name updateLeadStatus
   * @param records List of Lead records
   * @param oldMap Map of old map
   * @author Ashish Kumar
   * @US CC-1609
   */
  public static void updateLeadStatus(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    if (oldMap == null) {
      return;
    }
    Set<SObjectField> leadFieldsSet = new Set<SObjectField>{
      Lead.OwnerID,
      Lead.Skip_Validations__c,
      Lead.Status
    };
    List<Lead> leadsWithFieldChanged = ListUtil.filter(records, oldMap)
      .anyChanged(leadFieldsSet)
      .toList();
    Set<Id> leadIdsWithFieldChanged = ListUtil.getIds(
      leadsWithFieldChanged,
      Lead.Id
    );
    List<Lead> filteredLeads = ListUtil.filter(records, oldMap)
      .equals(Lead.Status, STATUS_NEW)
      .equals(Lead.isNewLead__c, false)
      .notEquals(Lead.Id, leadIdsWithFieldChanged)
      .toList();

    ListUtil.setField(filteredLeads, Lead.Status, STATUS_IN_PROGRESS);
    ListUtil.setField(
      filteredLeads,
      Lead.Skip_Validations__c,
      LEAD_NEW_TO_INPROGRESS
    );
  }
}
