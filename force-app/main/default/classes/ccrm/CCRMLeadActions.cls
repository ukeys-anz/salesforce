/**
 * @author Sahil S
 * @since  08/2021
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadActions is class to handle all the CCRM (Commercial CRM) Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMLeadActions {
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
    Map<Id, Lead> updateLeads = new Map<Id, Lead>();

    for (Lead record : records) {
      if (
        isCCRMLeadType(record) &&
        isLeadStatusChanged(record, oldMap?.get(record.id)) &&
        record.Status == CCRMConstants.STATUS_COMPLETED
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
      Boolean isAdobeNewLead =
        oldRec == null &&
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE;
      Boolean isLeadOwnerUpdated = isLeadOwnerChanged(record, oldRec);
      if (
        isCCRMLeadType(record) &&
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
        isCCRMLeadType(record) &&
        (String.isBlank(record.Lead_Id__c) ||
        record.Lead_Id__c.contains('null'))
      ) {
        Lead updateLead = new Lead(Id = record.id);
        updateLead.Lead_Id__c = record.Lead_Auto_Number__c;
        updateLeads.add(updateLead);
      }
    }

    if (
      Schema.sObjectType.Lead.fields.Lead_Id__c.isUpdateable() &&
      !updateLeads.isEmpty()
    ) {
      List<Database.saveResult> results = Database.update(updateLeads, false);
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'copyLeadId'
      );
      log.addDatabaseSaveResult('Lead', results, updateLeads);
      log.insertLogAsync();
    }
  }

  /**
   * @description Check if record type is of CCRM Lead type. As this Trigger will be used across various teams we identify lead record based on CCRM Lead record Type.
   * @name isCCRMLeadType
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of CCRM Lead type otherwise false.
   */
  public static Boolean isCCRMLeadType(Lead record) {
    if (record.RecordTypeId == CCRMConstants.CCRM_LEAD_RT_ID) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if this Lead record is re-assigned to a different Lead Owner.
   * @name isLeadOwnerChanged
   * @param record lead record
   * @param oldRec old lead record from trigger
   * @return `Boolean` True if the Lead Owner is updated otherwise false.
   */
  public static Boolean isLeadOwnerChanged(Lead record, Lead oldRec) {
    return oldRec != null && record.OwnerId != oldRec.OwnerId;
  }

  /**
   * @description Check if this Lead record has updated status to Completed
   * @name isLeadOwnerChanged
   * @param record lead record
   * @param oldRec old lead record from trigger
   * @return `Boolean` True if the Lead Owner is updated otherwise false.
   */
  public static Boolean isLeadStatusChanged(Lead record, Lead oldRec) {
    return oldRec != null && record.Status != oldRec.Status;
  }

  /**
   * @description Populate fields of New Leads before Inserting.
   *  - Priority__c: updated from campaign, or default value if not available
   *  - Description: updated from campaign if available
   *  - FinServ__RelatedAccount__c: updated by search for account matching Customer_ID__c/CLG_ID__c/Business_ID__c
   * @name populateFields
   * @param records List of lead records.
   */
  public static void populateFields(List<Lead> records) {
    List<Lead> selectedLeads = new List<Lead>();
    Set<String> campaignCodes = new Set<String>();
    Set<String> accountIds = new Set<String>();
    Map<String, Account> mapAccountRecord = new Map<String, Account>();
    Map<String, Campaign> mapCampaignCodeRecord = getCCRMLeadCampaigns(records);

    mapAccountRecord = new CCRMLeadMappingEngine()
      .getAccountsBySourceSystemId(records);

    for (Lead record : records) {
      if (isCCRMLeadType(record) && !String.isBlank(record.Campaign_Code__c)) {
        Decimal priorityValue = mapCampaignCodeRecord.containsKey(
            record.Campaign_Code__c
          ) &&
          mapCampaignCodeRecord.get(record.Campaign_Code__c).Priority__c !=
          Decimal.ValueOf(LABEL.CCRM_LeadDefaultPriorityValue)
          ? mapCampaignCodeRecord.get(record.Campaign_Code__c).Priority__c
          : Decimal.ValueOf(LABEL.CCRM_LeadDefaultPriorityValue);

        record.FinServ__RelatedAccount__c = !String.isBlank(
            record.Customer_ID__c
          ) && mapAccountRecord.containsKey(record.Customer_ID__c)
          ? mapAccountRecord.get(record.Customer_ID__c).Id
          : !String.isBlank(record.Business_ID__c) &&
              mapAccountRecord.containsKey(record.Business_ID__c)
              ? mapAccountRecord.get(record.Business_ID__c).Id
              : record.FinServ__RelatedAccount__c;
        record.Priority__c = priorityValue;
        record.Description = String.isBlank(record.Description)
          ? mapCampaignCodeRecord.get(record.Campaign_Code__c).Description
          : record.Description;
      }
    }
  }

  /**
   * @description After Insert to create Campaign Member to link Leads with their respective Campaigns.
   * @name createCampaignMember
   * @param records List of lead records.
   */
  public static void createCampaignMember(List<Lead> records) {
    List<Lead> selectedLeads = new List<Lead>();
    Set<String> campaignCodes = new Set<String>();
    List<CampaignMember> newCampaignMembers = new List<CampaignMember>();

    Map<String, Campaign> mapCampaignCodeRecord = getCCRMLeadCampaigns(records);

    for (Lead selectLead : records) {
      if (
        isCCRMLeadType(selectLead) &&
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
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'createCampaignMember'
      );
      log.addDatabaseSaveResult('CampaignMember', results, newCampaignMembers);
      log.insertLogAsync();
    }
  }

  /**
   * @description Get list of Campaigns from Campaign_Code__c on CCRM Leads.
   * @name getCCRMLeadCampaigns
   * @param records List of lead records.
   * @return Map<String, Campaign> Type where Key is Campaign_Code__c.
   */
  public static Map<String, Campaign> getCCRMLeadCampaigns(List<Lead> records) {
    Set<String> campaignCodes = new Set<String>();
    Map<String, Campaign> mapCampaignCodeRecord = new Map<String, Campaign>();

    for (Lead selectLead : records) {
      if (
        isCCRMLeadType(selectLead) &&
        !String.isBlank(selectLead.Campaign_Code__c)
      ) {
        campaignCodes.add(selectLead.Campaign_Code__c);
      }
    }

    if (Schema.sObjectType.Campaign.isQueryable()) {
      for (Campaign campaignRecord : [
        SELECT Id, Code__c, Priority__c, Description, Description__c
        FROM Campaign
        WHERE Code__c IN :campaignCodes
      ]) {
        mapCampaignCodeRecord.put(campaignRecord.Code__c, campaignRecord);
      }
    }

    return mapCampaignCodeRecord;
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
        if (isLeadOwnerChanged(record, oldRec) && isCCRMLeadType(record)) {
          if (record.Expiry_Date__c == Date.today()) {
            string dayName = DateTimeUtils.getDay(record.Expiry_Date__c);
            switch on dayName {
              when 'Mon', 'Tue', 'Wed', 'Thu' {
                record.Expiry_Date__c = record.Expiry_Date__c + 1;
              }
            }
          } else {
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

    if (task != null && task.ActivityDate != null) {
      newExpiryDate = task.ActivityDate.addDays(
          integer.valueOf(System.Label.CCRM_MinDaysExpiryDateExtends)
        ) >
        record.Expiry_Date__c.addDays(
          integer.valueOf(System.Label.CCRM_MaxDaysExpiryDateExtends)
        )
        ? record.Expiry_Date__c.addDays(
            integer.valueOf(System.Label.CCRM_MaxDaysExpiryDateExtends)
          )
        : task.ActivityDate.addDays(
            integer.valueOf(System.Label.CCRM_MinDaysExpiryDateExtends)
          );
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
        selectLead.Expiry_Date__c >= Date.today()
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
        isCCRMLeadType(record) &&
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
        isCCRMLeadType(record) &&
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
        isCCRMLeadType(record) &&
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
    if (accountMap != null && !accountMap.isEmpty()) {
      leadMappingEngine.prefillUnicaLeads(records, accountMap);
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
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_CCRM &&
        CCRMLeadActions.isCCRMLeadType(record)
      ) {
        listOfLeads.add(record);
      }
    }
    if (listOfLeads.size() > 0) {
      CCRMLeadActionsHelper.publishManualLeads(
        listOfLeads,
        oldMap,
        CCRMConstants.ORIGINATOR_CCRM
      );
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
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE) &&
        record.SubStatus__c != oldRec.SubStatus__c
      ) {
        listOfLeads.add(record);
      }
    }
    if (listOfLeads.size() > 0) {
      CCRMLeadActionsHelper.publishLeadResponseUpdateToAdobeOrUnica(
        listOfLeads,
        oldMap
      );
    }
  }

  /**
   * @description This method send adobe lead update to adobe
   * @name sendAdobeLeadUpdateToAdobe
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void sendAdobeLeadUpdateToAdobe(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> listOfLeads = new List<Lead>();
    for (Lead record : records) {
      Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
      if (
        record.Lead_Originator__c == CCRMConstants.ORIGINATOR_ADOBE &&
        (record.OwnerId != oldRec.OwnerId ||
        record.Expiry_Date__c != oldRec.Expiry_Date__c ||
        record.Status != oldRec.Status)
      ) {
        listOfLeads.add(record);
      }
    }
    if (listOfLeads.size() > 0) {
      CCRMLeadActionsHelper.publishManualLeads(
        listOfLeads,
        oldMap,
        CCRMConstants.ORIGINATOR_ADOBE
      );
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
    }
  }

  /**
   * @description Check if the lead's ABN or ACN is added and set ABN or ACN validation status to validation inprogress
   * @param record lead record from the trigger
   * @param oldRec lead record with previous values from the trigger
   */
  public static void addValidationStatus(Lead record, Lead oldRec) {
    if (!record.Not_Registered__c) {
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
        if (!record.Not_Registered__c) {
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
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'makeAbnCallout'
      );
      log.addDatabaseSaveResult('Lead', results, updateLeads);
      log.insertLog();
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
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'makeAcnCallout'
      );
      log.addDatabaseSaveResult('Lead', results, updateLeads);
      log.insertLog();
    }
  }

  /**
   * @description Set Controlling Post information on Leads
   * @name retrieveControllingPost
   * @param records List of lead NEW records.
   * @param oldMap  Map of old records with Id as key
   */
  public static void retrieveControllingPost(
    List<Lead> records,
    Map<Id, SObject> oldMap
  ) {
    Map<Id, List<Lead>> leadOwners = new Map<Id, List<Lead>>();

    for (Lead lead : records) {
      if (CCRMLeadActions.isCCRMLeadType(lead)) {
        if (
          oldMap != null &&
          CCRMLeadActions.isLeadOwnerChanged(lead, (Lead) oldMap.get(lead.id))
        ) {
          lead.CPID__c = null;
          lead.CPID_Owner__c = null;
          lead.Controlling_Post__c = null;
        }
        if (leadOwners.containsKey(lead.OwnerId)) {
          leadOwners.get(lead.OwnerId).add(lead);
        } else {
          List<Lead> newLeads = new List<Lead>();
          newLeads.add(lead);
          leadOwners.put(lead.OwnerId, newLeads);
        }
      }
    }

    if (leadOwners.isEmpty()) {
      return;
    }

    Set<Id> leadOwnerIds = leadOwners.keySet();

    Set<Id> managerIds = new Set<Id>();
    Map<String, User> employeeUsers = new Map<String, User>();
    Map<Id, List<Lead>> mappedLeadOwners = new Map<Id, List<Lead>>();

    for (User user : [
      SELECT Id, ManagerId, Employee_Id__c
      FROM User
      WHERE Id IN :leadOwnerIds
      WITH SECURITY_ENFORCED
    ]) {
      if (user.Employee_Id__c != null) {
        employeeUsers.put(user.Employee_Id__c, user);
      }
      mappedLeadOwners.put(user.ManagerId, leadOwners.get(user.Id));
      managerIds.add(user.ManagerId);
    }

    Map<String, User> managerUsers = new Map<String, User>();
    for (User user : [
      SELECT Id, Employee_Id__c
      FROM User
      WHERE Id IN :managerIds
      WITH SECURITY_ENFORCED
    ]) {
      if (user.Employee_Id__c != null) {
        managerUsers.put(user.Employee_Id__c, user);
      }
    }

    List<Controlling_Post__c> employeeControllingPosts = getControllingPosts(
      employeeUsers.keySet()
    );
    List<Controlling_Post__c> managerControllingPosts = getControllingPosts(
      managerUsers.keySet()
    );

    updateCPIDs(leadOwners, employeeUsers, employeeControllingPosts);

    updateCPIDs(mappedLeadOwners, managerUsers, managerControllingPosts);
  }

  /**
   * @description Get a List of Controlling Posts
   * @name getControllingPosts
   * @param employeeIds A Set of User.Employee_Id__c
   * @return `List<Controlling_Post__c>` Returns List of Controlling Posts of Users
   */
  private static List<Controlling_Post__c> getControllingPosts(
    Set<String> employeeIds
  ) {
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
  private static void updateCPIDs(
    Map<Id, List<Lead>> leadOwners,
    Map<String, User> users,
    List<Controlling_Post__c> controllingPosts
  ) {
    for (Controlling_Post__c controllingPost : controllingPosts) {
      if (users.containsKey(controllingPost.Responsible_Employee_Id__c)) {
        User user = users.get(controllingPost.Responsible_Employee_Id__c);
        List<Lead> mappedLeads = leadOwners.get(user.id);

        if (controllingPost.CPID__c != null) {
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
  }
}
