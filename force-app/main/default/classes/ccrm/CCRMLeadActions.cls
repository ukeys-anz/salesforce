/**
 * @author Sahil S
 * @since  08/2021
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadActions is class to handle all the CCRM (Commercial CRM) Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMLeadActions {
  @TestVisible
  static final String EXPIRY_DATE_MISSING_ERROR_MESSAGE = 'EXPIRY DATE IS MISSING';

  /**
   * @description Before Update Automated actions of a completed Lead.
   * @name leadCompletedActionBeforeUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   * @param records from the trigger
   */
  public static void leadCompletedActionBeforeUpdate(
    Map<Id, Lead> oldMap,
    List<Lead> records
  ) {
    for (Lead record : records) {
      if (
        ((CCRMLeadUtil.isCCRMLeadType(record) &&
        record.Status == CCRMConstants.STATUS_CONVERTED) ||
        (CCRMLeadUtil.isMLCRMLeadType(record) &&
        record.Status == CCRMConstants.STATUS_COMPLETED)) &&
        CCRMLeadUtil.isLeadStatusChanged(record, oldMap?.get(record.Id))
      ) {
        record.Followup_Date__c = null;
      }
    }
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
    List<Lead> createChatterPostLeads = new List<Lead>();

    for (Lead record : records) {
      Lead oldRec = oldMap?.get(record.id);
      Boolean isAdobeNewLead = oldRec == null;
      Boolean isLeadOwnerUpdated = CCRMLeadUtil.isLeadOwnerChanged(
        record,
        oldRec
      );
      if (
        ((CCRMLeadUtil.isCCRMLeadType(record) &&
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) ||
        CCRMLeadUtil.isMLCRMLeadType(record)) &&
        record.OwnerID.getsobjecttype() == User.sobjecttype &&
        (isAdobeNewLead || isLeadOwnerUpdated)
      ) {
        createChatterPostLeads.add(record);
      }
    }

    if (!createChatterPostLeads.isEmpty()) {
      // Chatter Post for newly assigned Leads.
      ChatterPostActions.createLeadChatterPost(
        createChatterPostLeads,
        Label.CCRM_NewSourceLeadMessage
      );
    }
  }

  /**
   * @description Copy Lead Id from Lead_Auto_Number on Lead Insert.
   * @name copyLeadId
   * @param records from the trigger of type List<Lead>.
   */
  public static void copyLeadId(List<Lead> records) {
    List<Lead> updateLeads = new List<Lead>();

    for (Lead record : records) {
      if (
        (CCRMLeadUtil.isCCRMLeadType(record) ||
        CCRMLeadUtil.isMLCRMLeadType(record)) &&
        (String.isBlank(record.Lead_Id__c) ||
        record.Lead_Id__c.contains('null'))
      ) {
        Lead updateLead = new Lead(Id = record.id);
        updateLead.Lead_Id__c = record.Lead_Auto_Number__c;
        updateLead.Skip_Validations__c = MLCRMConstants.COPY_LEAD_ID;
        updateLeads.add(updateLead);
      }
    }

    if (
      Schema.sObjectType.Lead.fields.Lead_Id__c.isUpdateable() &&
      !updateLeads.isEmpty()
    ) {
      List<Database.saveResult> results = Database.update(updateLeads, false);
      Logger.error('', results);
      Logger.saveLog();
    }
  }

  /**
   * @description Populate fields of New Leads before Inserting.
   *  - Priority__c: updated from campaign, or default value if not available
   *  - Description: updated from campaign if available
   *  - FinServ__RelatedAccount__c: updated by search for account matching Customer_ID__c/CLG_ID__c/Business_ID__c
   *  - LeadSource: updated based on Lead_Originator for UNICA/Adobe
   * @name populateFields
   * @param records List of lead records.
   */
  public static void populateFields(List<Lead> records) {
    //CC-3941 moved logic to helper class to resolve  ExcessiveClassLength and NcssMethodCount PMD issues
    CCRMLeadActionsHelper.populateFieldsFromCampaign(records);
    CCRMLeadActionsHelper.populateRelatedAccount(records);
    CCRMLeadActionsHelper.populateLeadSource(records);
  }

  /**
   * @description After Insert to create Campaign Member to link Leads with their respective Campaigns.
   * @name createCampaignMember
   * @param records List of lead records.
   */
  public static void createCampaignMember(List<Lead> records) {
    List<CampaignMember> newCampaignMembers = new List<CampaignMember>();

    Map<String, Campaign> mapCampaignCodeRecord = CCRMCampaignActions.getCCRMLeadCampaigns(
      records
    );

    for (Lead selectLead : records) {
      if (
        (CCRMLeadUtil.isCCRMLeadType(selectLead) ||
        CCRMLeadUtil.isMLCRMLeadType(selectLead)) &&
        !String.isBlank(selectLead.Campaign_Code__c) &&
        mapCampaignCodeRecord.containsKey(selectLead.Campaign_Code__c)
      ) {
        CampaignMember campaignMemberRecord = new CampaignMember();
        campaignMemberRecord.CampaignId = mapCampaignCodeRecord.get(
            selectLead.Campaign_Code__c
          )
          .Id;
        campaignMemberRecord.LeadId = selectLead.Id;
        newCampaignMembers.add(campaignMemberRecord);
      }
    }

    if (
      Schema.sObjectType.CampaignMember.isCreateable() &&
      !newCampaignMembers.isEmpty()
    ) {
      List<Database.saveResult> results = Database.Insert(
        newCampaignMembers,
        false
      );
      Logger.error('', results);
      Logger.saveLog();
    }
  }

  /**
   * @description Check and update expiry date for CCRM leads if needed, eg.
   *  - lead ownership changed
   *  - follow-up date changed
   *  - expiry date are set after campaign end date
   * @name setExpiryDate
   * @param records List of lead NEW records.
   * @param oldMap Map of leads with Id.
   */
  public static void setExpiryDate(List<Lead> records, Map<Id, Lead> oldMap) {
    Map<String, Date> mapCampaigns = getMapOfCampaign(records);
    Map<String, Task> mapTask = getMapOfTask(records, oldMap);
    Date newExpiryDate = null;
    Boolean includeFriday = false;

    for (Lead record : records) {
      if (record.Expiry_Date__c >= Date.today()) {
        Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
        // Log Response created with Follow-up date and then Follow-up date changed in Lead
        if (mapTask.size() > 0) {
          newExpiryDate = updateExpiryDateWhenFollowUpChanged(
            record,
            mapTask,
            newExpiryDate
          );
        }

        //On lead ownership change set Expiry date to Monday if it on Friday, Saturday or Sunday
        //If expiry date is today and weekday is from Mon-Thu then just add 1 day
        if (
          CCRMLeadUtil.isLeadOwnerChanged(record, oldRec) &&
          (CCRMLeadUtil.isCCRMLeadType(record) ||
          CCRMLeadUtil.isMLCRMLeadType(record))
        ) {
          if (
            (record.Expiry_Date__c ==
            Date.today()
              .addDays(Integer.valueOf(System.Label.CCRM_Today_Date))) ||
            (Date.today().daysBetween(record.Expiry_Date__c) == 1 &&
            CCRMLeadUtil.isMLCRMLeadType(record))
          ) {
            string dayName = DateTimeUtils.getDay(record.Expiry_Date__c);
            switch on dayName {
              when 'Mon', 'Tue', 'Wed', 'Thu' {
                record.Expiry_Date__c = record.Expiry_Date__c + 1;
              }
              when 'Fri' {
                newExpiryDate = record.Expiry_Date__c;
                includeFriday = true;
              }
              when 'Sat', 'Sun' {
                newExpiryDate = record.Expiry_Date__c;
                includeFriday = false;
              }
            }
          } else if (CCRMLeadUtil.isCCRMLeadType(record)) {
            newExpiryDate = record.Expiry_Date__c;
            includeFriday = true;
          }
        }

        //Expiry Date should not be greater than Campaign End date
        if (
          mapCampaigns.size() > 0 &&
          newExpiryDate > mapCampaigns.get(record.Id)
        ) {
          newExpiryDate = mapCampaigns.get(record.Id);
        }

        //Check if new expiry date fall on Weekend then extend it to Monday
        if (newExpiryDate != null) {
          record.Expiry_Date__c = DateTimeUtils.getWeekday(
            newExpiryDate,
            includeFriday,
            false
          );
        }

        //Set Lead follow up date when follow up date is greater than campaign expiry date
        if (
          mapCampaigns.size() > 0 &&
          record.Followup_Date__c > mapCampaigns.get(record.Id) &&
          System.today()
            .addDays(integer.valueOf(System.Label.ML_FollowUpDateExtends)) <=
          record.Expiry_Date__c &&
          CCRMLeadUtil.isMLCRMLeadType(record)
        ) {
          record.Followup_Date__c =
            record.Expiry_Date__c -
            (integer.valueOf(System.Label.ML_FollowUpDateExtends));
        } else if (
          mapCampaigns.size() > 0 &&
          record.Followup_Date__c > mapCampaigns.get(record.Id) &&
          System.today()
            .addDays(integer.valueOf(System.Label.ML_FollowUpDateExtends)) >
          record.Expiry_Date__c &&
          CCRMLeadUtil.isMLCRMLeadType(record)
        ) {
          record.Followup_Date__c =
            record.Expiry_Date__c -
            (integer.valueOf(System.Label.ML_FollowUpDateLessThanToday));
        }
      }
    }
  }

  /**
   * @description This method extends the expiry date when:
   * Log Response created with Follow up date AND Follow up date is changed
   * @name updateExpiryDateWhenFollowUpChanged
   * @param record Lead record.
   * @param mapTask Map of Task
   * @param newExpiryDate Expiry Date
   * @return Date
   */
  private static Date updateExpiryDateWhenFollowUpChanged(
    Lead record,
    Map<String, Task> mapTask,
    Date newExpiryDate
  ) {
    Task task = mapTask.get(record.Id);

    Integer minDays = CCRMLeadUtil.isCCRMLeadType(record)
      ? integer.valueOf(System.Label.CCRM_MinDaysExpiryDateExtends)
      : integer.valueOf(System.Label.ML_MinDaysExpiryDateExtends);
    Integer maxdays = CCRMLeadUtil.isCCRMLeadType(record)
      ? integer.valueOf(System.Label.CCRM_MinDaysExpiryDateExtends)
      : integer.valueOf(System.Label.ML_MinDaysExpiryDateExtends);

    if (task != null && task.ActivityDate != null) {
      newExpiryDate = task.ActivityDate.addDays(minDays) >
        record.Expiry_Date__c.addDays(maxdays)
        ? record.Expiry_Date__c.addDays(maxdays)
        : task.ActivityDate.addDays(minDays);
    }
    return newExpiryDate;
  }

  /**
   * @description Get Map of Campaign related to Lead
   * @name getMapOfCampaign
   * @param records List of lead new records.
   * @return Map<String, Date> where Key is Lead Id.
   */
  private static Map<String, Date> getMapOfCampaign(List<Lead> records) {
    Set<String> leadIds = new Set<String>();
    Map<String, Date> mapCampaigns = new Map<String, Date>();

    for (Lead selectLead : records) {
      if (selectLead.Expiry_Date__c >= Date.today()) {
        leadIds.add(selectLead.Id);
      }
    }
    if (leadIds.size() > 0) {
      for (CampaignMember campaignMember : [
        SELECT LeadId, Campaign.EndDate
        FROM CampaignMember
        WHERE leadId = :leadIds
      ]) {
        mapCampaigns.put(
          campaignMember.LeadId,
          campaignMember.Campaign.EndDate
        );
      }
    }
    return mapCampaigns;
  }

  /**
   * @description Get Map of Task related to Lead
   * @name getMapOfTask
   * @param records List of lead new records.
   * @param oldMap Map of lead with key Id.
   * @return Map<String, Task> where Key is Lead Id.
   */
  private static Map<String, Task> getMapOfTask(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    Set<String> leadIds = new Set<String>();
    Map<String, Task> mapTask = new Map<String, Task>();

    for (Lead selectLead : records) {
      Lead oldRec = oldMap != null ? oldMap.get(selectLead.id) : new Lead();
      //Followup date is changed on Lead
      if (
        selectLead.Followup_Date__c != oldRec.Followup_Date__c &&
        selectLead.Expiry_Date__c >= Date.today() &&
        (CCRMLeadUtil.isCCRMLeadType(selectLead) ||
        (CCRMLeadUtil.isMLCRMLeadType(selectLead) &&
        selectLead.Followup_Date__c != null &&
        selectLead.Followup_Date__c.addDays(
          Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate)
        ) > selectLead.Expiry_Date__c))
      ) {
        leadIds.add(selectLead.Id);
      }
    }

    if (leadids.size() > 0 && Schema.sObjectType.Task.isQueryable()) {
      for (Task a : [
        SELECT ActivityDate, WhoId
        FROM Task
        WHERE whoId = :leadIds
        ORDER BY createddate DESC
        LIMIT 1
      ]) {
        mapTask.put(a.WhoId, a);
      }
    }
    return mapTask;
  }

  /**
   * @description Populate fields of New Leads with the values from Previous lead id lookup
   * @name populateFromPreviousLead
   * @param records List of lead records.
   */
  public static void populateFromPreviousLead(List<Lead> records) {
    List<Id> previousLeadIds = new List<Id>();
    Map<Id, Lead> previousLeadMap = new Map<Id, Lead>();
    List<Lead> selectedLeads = new List<Lead>();
    for (Lead record : records) {
      if (
        (CCRMLeadUtil.isCCRMLeadType(record) ||
        CCRMLeadUtil.isMLCRMLeadType(record)) &&
        String.isNotBlank(record.Previous_Lead__c) &&
        record.Lead_Originator__c == 'Adobe'
      ) {
        previousLeadIds.add(record.Previous_Lead__c);
        selectedLeads.add(record);
      }
    }
    if (!previousLeadIds.isEmpty()) {
      previousLeadMap = getPreviousLeadRecords(previousLeadIds);
    }
    for (Lead selectedLead : selectedLeads) {
      for (
        Schema.FieldSetMember field : Schema.SObjectType.Lead.fieldSets.CCRM_Previous_Lead_Fields.getFields()
      ) {
        selectedLead.put(
          field.FieldPath,
          previousLeadMap.get(selectedLead.Previous_Lead__c)
            .get(field.FieldPath)
        );
      }
    }
  }

  /**
   * @description method to query previous lead records
   * @name getPreviousLeadRecords
   * @param previousLeadIds List of previous lead ids
   * @return Map<Id, Lead> map of previous lead records
   */
  private static Map<Id, Lead> getPreviousLeadRecords(
    List<Id> previousLeadIds
  ) {
    List<String> leadFields = new List<String>();
    List<Lead> previousLeads = new List<Lead>();
    for (
      Schema.FieldSetMember field : Schema.SObjectType.Lead.fieldSets.CCRM_Previous_Lead_Fields.getFields()
    ) {
      leadFields.add(field.FieldPath);
    }
    String leadQuery =
      'SELECT Id, ' +
      String.join(leadFields, ', ') +
      ' FROM Lead WHERE Id IN :previousLeadIds';

    previousLeads = Database.query(String.escapeSingleQuotes(leadQuery));
    Map<Id, Lead> previousLeadMap = new Map<Id, Lead>(previousLeads);
    return previousLeadMap;
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
    Set<String> relatedPartyIds = new Set<String>();
    for (Lead record : records) {
      if (
        (CCRMLeadUtil.isCCRMLeadType(record) ||
        CCRMLeadUtil.isMLCRMLeadType(record)) &&
        (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM ||
        record.Lead_Originator__c == MLCRMConstants.ORIGINATOR_MLCRM ||
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) &&
        String.isNotBlank(record.FinServ__RelatedAccount__c)
      ) {
        Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
        if (
          record.FinServ__RelatedAccount__c != null &&
          record.FinServ__RelatedAccount__c != oldRec.FinServ__RelatedAccount__c
        ) {
          relatedPartyIds.add(record.FinServ__RelatedAccount__c);
        }
      }
    }
    if (relatedPartyIds != null && !relatedPartyIds.isEmpty()) {
      new CCRMLeadMappingEngine()
        .prefillManualLeadsFromAccount(records, relatedPartyIds);
    }
  }

  /**
   * @description This method prefill data from Account to Leads when related party added on lead creation
   * @name prefillManualLeadsFromAccountOnInsert
   * @param records List of lead records
   */
  public static void prefillManualLeadsFromAccountOnInsert(List<Lead> records) {
    Set<String> relatedPartyIds = new Set<String>();
    for (Lead record : records) {
      if (
        (CCRMLeadUtil.isCCRMLeadType(record) ||
        CCRMLeadUtil.isMLCRMLeadType(record)) &&
        (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM ||
        record.Lead_Originator__c == MLCRMConstants.ORIGINATOR_MLCRM) &&
        String.isNotBlank(record.FinServ__RelatedAccount__c)
      ) {
        relatedPartyIds.add(record.FinServ__RelatedAccount__c);
      }
    }
    if (relatedPartyIds != null && !relatedPartyIds.isEmpty()) {
      new CCRMLeadMappingEngine()
        .prefillManualLeadsFromAccount(records, relatedPartyIds);
    }
  }

  /**
   * @description This method prefill data from Account to Leads for UNICA leads
   * @name prefillUnicaLeadsFromAccountOnInsert
   * @param records List of lead records
   */
  public static void prefillUnicaLeadsFromAccountOnInsert(List<Lead> records) {
    CCRMLeadMappingEngine leadMappingEngine = new CCRMLeadMappingEngine();
    Map<String, Account> accountMap = leadMappingEngine.getAccountsBySourceSystemId(
      records
    );
    List<Lead> listOfLeads = new List<Lead>();
    for (Lead record : records) {
      if (
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_UNICA &&
        !record.hasErrors() &&
        ((!String.isBlank(record.Customer_ID__c) ||
        !String.isBlank(record.Business_ID__c) ||
        !String.isBlank(record.CLG_ID__c)))
      ) {
        listOfLeads.add(record);
      }
    }

    if (accountMap != null && !accountMap.isEmpty() && listOfLeads.size() > 0) {
      leadMappingEngine.prefillUnicaLeads(listOfLeads, accountMap);
    }
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
    List<Lead> listOfLeads = new List<Lead>();
    for (Lead record : records) {
      if (
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM ||
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_UNICA
      ) {
        listOfLeads.add(record);
      }
    }
    if (listOfLeads.size() > 0) {
      CCRMLeadPlatformEventActions.publishManualLeads(listOfLeads);
    }
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
    List<Lead> listOfLeads = new List<Lead>();
    for (Lead record : records) {
      Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
      if (
        (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_UNICA ||
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM ||
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) &&
        record.SubStatus__c != oldRec.SubStatus__c
      ) {
        listOfLeads.add(record);
      }
    }
    if (listOfLeads.size() > 0) {
      CCRMLeadPlatformEventActions.publishLeadResponseUpdateToAdobeOrUnica(
        listOfLeads,
        oldMap
      );
    }
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
    List<Lead> listOfLeads = new List<Lead>();

    for (Lead record : records) {
      Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
      if (
        ((record.OwnerId != oldRec.OwnerId ||
        record.Expiry_Date__c != oldRec.Expiry_Date__c ||
        record.Status != oldRec.Status) && !CCRMLeadUtil.isIntegrationUser()) &&
        (record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE ||
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_UNICA ||
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM)
      ) {
        listOfLeads.add(record);
      }
    }

    if (listOfLeads.size() > 0) {
      CCRMLeadPlatformEventActions.publishLeadUpdateToUnicaOrAdobe(listOfLeads);
    }
  }

  /**
   * @description Check if the lead's ABN or ACN is added or removed and set ABN Validation Status
   * @name setValidationStatus
   * @param records leads to check
   * @param oldMap contains the map which holds the previous values of lead record
   */
  public static void setValidationStatus(Lead[] records, Map<Id, Lead> oldMap) {
    for (Lead record : records) {
      Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
      addValidationStatus(record, oldRec);
      if (oldRec != null) {
        removeValidationStatus(record, oldRec);
      }
      setDuplicateBlock(record, oldRec);
    }
  }

  /**
   * @description Check if the lead's ABN or ACN is added and set ABN or ACN validation status to validation inprogress
   * @param record lead record from the trigger
   * @param oldRec lead record with previous values from the trigger
   */
  public static void addValidationStatus(Lead record, Lead oldRec) {
    if (record.Registered_Company__c == 'Yes') {
      if (AbnAcnUtil.isABNValueEntered(record, oldRec)) {
        record.ABN_Validation_Status__c = CCRMConstants.ABN_ACN_STATUS_INPROGRESS;
      }
      if (AbnAcnUtil.isACNValueEntered(record, oldRec)) {
        record.ACN_Validation_Status__c = CCRMConstants.ABN_ACN_STATUS_INPROGRESS;
      }
    }
  }

  /**
   * @description Check if the lead's ABN or ACN is removed and set ABN or ACN validation status to null
   * @param record lead record from the trigger
   * @param oldRec lead record with previous values from the trigger
   */
  public static void removeValidationStatus(Lead record, Lead oldRec) {
    if (String.isBlank(record.ABN__c) && record.ABN__c != oldRec.ABN__c) {
      record.ABN_Validation_Status__c = '';
    }
    if (String.isBlank(record.ACN__c) && record.ACN__c != oldRec.ACN__c) {
      record.ACN_Validation_Status__c = '';
    }
  }
  /**
   * @description check if the ABN or ACN is added or changed and make a callout.
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in afterUpdate.
   */
  public static void validateAbnAcnForCallout(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    //make this callout only when the trigger contains one record
    if (records.size() == 1) {
      for (Lead record : records) {
        Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
        if (record.Registered_Company__c == 'Yes') {
          if (AbnAcnUtil.isABNValueEntered(record, oldRec)) {
            makeAbnCallout(record.ABN__c.deleteWhitespace(), record.Id);
          }
          if (AbnAcnUtil.isACNValueEntered(record, oldRec)) {
            makeAcnCallout(record.ACN__c.deleteWhitespace(), record.Id);
          }
        }
      }
    }
  }

  /**
   * @description method to make ABN callout and get abn status
   * @param abn Australian Business Number
   * @param leadId lead record id from the trigger
   */
  @future(callOut=true)
  public static void makeAbnCallout(String abn, String leadId) {
    List<Lead> updateLeads = new List<Lead>();
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel responseMap = apiRepo.validateAbn(abn);
    Lead leadRec = new Lead(id = leadId);
    if (responseMap != null) {
      leadRec.ABN_Validation_Status__c = responseMap.abnStatus;
    } else {
      leadRec.ABN_Validation_Status__c = CCRMConstants.ABN_ACN_STATUS_FAILED;
    }
    updateLeads.add(leadRec);

    if (
      Schema.sObjectType.Lead.fields.ABN_Validation_Status__c.isUpdateable()
    ) {
      List<Database.saveResult> results = Database.update(updateLeads, false);
      Logger.error('', results);
      Logger.saveLog();
    }
  }

  /**
   * @description method to make ACN callout and get acn status
   * @param acn Australian Company Number
   * @param leadId lead record id from the trigger
   */
  @future(callOut=true)
  public static void makeAcnCallout(String acn, String leadId) {
    List<Lead> updateLeads = new List<Lead>();
    CCRMAPIRepository apiRepo = new CCRMAPIRepository();
    CCRMValidateAbnAcnModel responseMap = apiRepo.validateAcn(acn);
    Lead leadRec = new Lead(id = leadId);
    if (responseMap != null) {
      leadRec.ACN_Validation_Status__c = responseMap.abnStatus;
    } else {
      leadRec.ACN_Validation_Status__c = CCRMConstants.ABN_ACN_STATUS_FAILED;
    }
    updateLeads.add(leadRec);

    if (
      Schema.sObjectType.Lead.fields.ACN_Validation_Status__c.isUpdateable()
    ) {
      List<Database.saveResult> results = Database.update(updateLeads, false);
      Logger.error('', results);
      Logger.saveLog();
    }
  }

  /**
   * @description Validate lead originated from UNICA and ADOBE
   * @name validateIngestedLeads
   * @param records List of lead NEW records.
   */
  public static void validateIngestedLeads(List<Lead> records) {
    CCRMLeadUtil.validateUnicaLeads(records);
    CCRMLeadUtil.validateAdobeLeads(records);
  }

  /**
   * @description Set field CCRM_Duplicate_Block__c to true if the lead's status is New or In progress
   * @name setDuplicateBlock
   * @param record current record
   * @param oldRec old record
   */
  private static void setDuplicateBlock(Lead record, Lead oldRec) {
    if (
      !CCRMLeadUtil.isCCRMLeadType(record) &&
      !CCRMLeadUtil.isMLCRMLeadType(record)
    ) {
      return;
    }
    if (oldRec != null && !CCRMLeadUtil.isLeadStatusChanged(record, oldRec)) {
      return;
    }
    CCRMLeadActionsHelper.setDuplicateBlock(record, oldRec);
  }

  /**
   * @description This method is used by Admin to resend PE Lead Update incase there is any error
   * @name resendAdobeOrUnicaOrCcrmLeadUpdatePlatformEvent
   * @param leadIds Set of lead ids
   */
  public static void resendAdobeOrUnicaOrCcrmLeadUpdatePlatformEvent(
    Set<Id> leadIds
  ) {
    sendLeadUpdateToUnicaOrAdobe(
      CCRMLeadPlatformEventHelper.getLeadData(leadIds),
      null
    );
  }

  /**
   * @description This method prefill Referrer when Referrer Email is populated or changed
   * @name referrerPrefill
   * @param records List of lead records
   * @param oldMap Mao of old lead records
   * author Ankit Garg
   * @US CC-1882
   */
  public static void referrerPrefill(List<Lead> records, Map<Id, Lead> oldMap) {
    Set<String> referrerEmails = new Set<String>();
    Set<Id> referrerIds = new Set<Id>();
    List<Lead> referredEmailLeads = new List<Lead>();
    List<Lead> referredLeads = new List<Lead>();
    Map<String, User> userEmailMap = new Map<String, User>();
    Map<Id, User> userMap = new Map<Id, User>();

    //filter all the ML leads for which Internal Referral or Referrer Email is changed
    for (Lead record : records) {
      if (
        CCRMLeadUtil.isMLCRMLeadType(record) &&
        String.isNotBlank(record.FinServ__ReferredByUser__c) &&
        (oldMap == null ||
        record.FinServ__ReferredByUser__c !=
        oldMap.get(record.id).FinServ__ReferredByUser__c)
      ) {
        referrerIds.add(record.FinServ__ReferredByUser__c);
        referredLeads.add(record);
      } else if (
        CCRMLeadUtil.isMLCRMLeadType(record) &&
        String.isNotBlank(record.Referrer_Email__c) &&
        record.LeadSource.equals(MLCRMConstants.INTERNAL_REFERRAL) &&
        (oldMap == null ||
        record.Referrer_Email__c != oldMap.get(record.id).Referrer_Email__c)
      ) {
        referrerEmails.add(record.Referrer_Email__c);
        referredEmailLeads.add(record);
      }
    }

    if (!referrerEmails.isEmpty() && Schema.sObjectType.User.isQueryable()) {
      userEmailMap = getReferrerUsers(referrerEmails);
    }
    if (!referrerIds.isEmpty() && Schema.sObjectType.User.isQueryable()) {
      userMap = getReferrerUsers(referrerIds);
    }
    if (
      !referredLeads.isEmpty() &&
      Schema.sObjectType.Lead.fields.Referrer_Email__c.isUpdateable()
    ) {
      populateReferrerDetails(referredLeads, userMap);
    }
    if (
      !referredEmailLeads.isEmpty() &&
      Schema.sObjectType.Lead.fields.FinServ__ReferredByUser__c.isUpdateable()
    ) {
      populateReferrer(referredEmailLeads, userEmailMap);
    }
  }

  /**
   * @description This method to query users matching with Referrer Emails
   * @name getReferrerUsers
   * @param referrerEmails Set of Email Ids
   * @return userEmailMap Map<String,User>()
   * @author Ankit Garg
   * @US CC-1882
   */
  private static Map<String, User> getReferrerUsers(
    Set<String> referrerEmails
  ) {
    Map<String, User> userEmailMap = new Map<String, User>();
    //query users matching with Referrer Emails
    for (User rUser : [
      SELECT Id, Name, Email
      FROM User
      WHERE Email = :referrerEmails AND isActive = TRUE
      LIMIT 10000
    ]) {
      if (!userEmailMap.containsKey(rUser.Email)) {
        userEmailMap.put(rUser.Email, rUser);
      }
    }
    return userEmailMap;
  }

  /**
   * @description This method to query users matching with Referrer Emails
   * @name getReferrerUsers
   * @param referrerIds Set of User Ids
   * @return userMap Map<Id,User>()
   * @author Ankit Garg
   * @US CC-1882
   */
  private static Map<Id, User> getReferrerUsers(Set<Id> referrerIds) {
    //query users matching with Internal Referrer Ids
    Map<Id, User> userMap = new Map<Id, User>(
      [
        SELECT Id, Name, Email
        FROM User
        WHERE Id = :referrerIds AND isActive = TRUE
        LIMIT 10000
      ]
    );
    return userMap;
  }

  /**
   * @description This method to populate Referrer Email and Referrer Name
   * @name populateReferrerDetails
   * @param referredLeads List of Lead records
   * @param userMap Map of users
   * @author Ankit Garg
   * @US CC-1882
   */
  private static void populateReferrerDetails(
    List<Lead> referredLeads,
    Map<Id, User> userMap
  ) {
    for (Lead record : referredLeads) {
      if (
        record.FinServ__ReferredByUser__c != null &&
        !userMap.isEmpty() &&
        userMap.containsKey(record.FinServ__ReferredByUser__c)
      ) {
        record.Referrer_Email__c = userMap.get(
            record.FinServ__ReferredByUser__c
          )
          .Email;
        record.Referrer_Name__c = userMap.get(record.FinServ__ReferredByUser__c)
          .Name;
      }
    }
  }
  /**
   * @description This method to populate Internal Referrer and Referrer Name
   * @name populateReferrer
   * @param referredLeads List of Lead records
   * @param userEmailMap Map of email with users
   * @author Ankit Garg
   * @US CC-1882
   */
  private static void populateReferrer(
    List<Lead> referredLeads,
    Map<String, User> userEmailMap
  ) {
    for (Lead record : referredLeads) {
      if (
        record.Referrer_Email__c != null &&
        !userEmailMap.isEmpty() &&
        userEmailMap.containsKey(record.Referrer_Email__c)
      ) {
        record.FinServ__ReferredByUser__c = userEmailMap.get(
            record.Referrer_Email__c
          )
          .Id;
        record.Referrer_Name__c = userEmailMap.get(record.Referrer_Email__c)
          .Name;
      } else {
        record.FinServ__ReferredByUser__c = null;
      }
    }
  }

  /**
   * @description This method to update lead status when response is logged.
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
    for (Lead record : records) {
      //CC-1069 Auto Update Lead status to In Progrees for MLCRM Manual lead update
      // Added CreatedDate and LastModifiedDate check due to existing code's insert trigger immediately invokes update trigger. This check ensures it happen only on update from UI.
      if (
        CCRMLeadUtil.isMLCRMLeadType(record) &&
        oldMap != null &&
        oldMap.get(record.Id).OwnerId == record.OwnerId &&
        record.Status == MLCRMConstants.STATUS_NEW &&
        record.Skip_Validations__c ==
        oldMap.get(record.Id).Skip_Validations__c &&
        !record.isNewLead__c
      ) {
        record.Status = MLCRMConstants.STATUS_IN_PROGRESS;
        record.Skip_Validations__c = MLCRMConstants.LEAD_NEW_TO_INPROGRESS;
      }
    }
  }
}
