/**
 * @author Pavan Kumar Ananta
 * @since  02/2020
 * @description IDRCaseActions is class to handle all the IDR (Internal Dispute Resolution) Actions
 * Note: Since Case Owner is a lookup of either User or Group Salesforce has common object in which only few fields are accessible as found in the link https://skaruz.com/salesforce-how-to-access-owner-custom-fields-in-a-soql-query/
 * So we need to query the Users and update the records accordingly.
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveClassLength')
public with sharing class IDRCaseActions {
  // IDR Customer Record Type ID
  @TestVisible
  static final Id CUSTOMER_COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Customer_Complaint')
    .getRecordTypeId();

  // IDR Non Customer Record Type ID
  @TestVisible
  static final Id NON_CUSTOMER_COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Non_Customer_Complaint')
    .getRecordTypeId();

  // IDR General Inquiry record type
  @TestVisible
  static final Id GENERAL_INQUIRY_CMOS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry_CMOS')
    .getRecordTypeId();

  public static final Id IDR_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('IDR_Task')
    .getRecordTypeId();

  @TestVisible
  private static final String OPEN_STATUS = 'Open';
  @TestVisible
  private static final String UNDER_INVESTIGATION_STATUS = 'Under Investigation';
  private static final String ESCALATED_STATUS = 'Escalated';
  private static final String REOPENED_STATUS = 'Re-opened';
  private static final String CLOSED_STATUS = 'Closed';
  private static final String RESOLVED_STATUS = 'Resolved';
  private static final String WITHDRAWN_STATUS = 'Withdrawn';
  @TestVisible
  private static final string DAY_3_ESCALATION_REASON = 'Day 3 auto escalation';
  @TestVisible
  private static final string DAY_5_ESCALATION_REASON = 'Day 5 auto escalation';

  // IDR Case Status for which notifications need to be sent.
  private static final Set<String> NOTIFICATION_STATUS = new Set<String>{
    OPEN_STATUS,
    UNDER_INVESTIGATION_STATUS,
    ESCALATED_STATUS,
    REOPENED_STATUS,
    CLOSED_STATUS,
    RESOLVED_STATUS,
    WITHDRAWN_STATUS
  };

  //These templates ids are email and sms template ids which are setup on notification broker.
  //These templates is used in platform events to send it to mulesoft which inturn invokes notification broker.
  private static final Map<String, String> TEMPLATE_ID_MAP = new Map<String, String>{
    OPEN_STATUS => 'AgCaseOpen',
    UNDER_INVESTIGATION_STATUS => 'AgCaseUdInvest',
    ESCALATED_STATUS => 'AgCaseEsclt',
    REOPENED_STATUS => 'AgCaseReopen',
    CLOSED_STATUS => 'AgCaseClosed',
    RESOLVED_STATUS => 'AgCaseRslvd',
    WITHDRAWN_STATUS => 'AgCaseWthdrwn'
  };

  private static final String ESCALATED_TO_CRC_API_NAME = '1';

  private static final String YES_VALUE = 'Yes';

  private static final String CRC_QUEUE_DEVELOPER_NAME = 'CRC_Team';

  private static final String SI_QUEUE_DEVELOPER_NAME = 'Systemic_Issue_Team';

  private static final String QUEUE_TYPE = 'Queue';

  private static final String DELETE_ERROR = 'You cannot delete cases';

  private static final String CUSTOMER_NUMBER_VALIDATION_ERROR = 'This field can no longer be edited. In the event that the Customer Number is incorrect, the case must be withdrawn and a new case created with the correct Customer Number.';

  @TestVisible
  public static final String IDR_TASK_SUBJECT = 'Please Review PSI';

  //IDR_Notification_Event__e for sending notifications to Notification Broker based on status.
  @TestVisible
  private static List<IDR_Notification_Event__e> idrNotifications;

  @TestVisible
  private static List<IDR_CRC_Escalation_Event__e> idrCaseEscalations;

  //Case Owner Id's for getting the Division to be copied in IDR_Office__c.
  private static Set<ID> caseOwnerIds = new Set<Id>();

  //changeOfficeCaseList list of cases which needs IDR_Office__c updates.
  //This is held in a seperate list as we dont want to update all the records.
  //We update only the records for which owner has changed and the owner is User.
  private static List<Case> changeOfficeCaseList = new List<Case>();

  //notificationCaseList list of cases for which Notifications need to be sent.
  //Only the cases if they are new and is one of NOTIFICATION_STATUS statuses
  private static List<Case> notificationCaseList = new List<Case>();

  private static List<Case> caseEscalationList = new List<Case>();

  //User Map to get the User Division for IDR_Office__c as we dont want to query everytime
  //We query all the caseOwnerIds for the case records.
  private static Map<ID, User> userMap = new Map<Id, User>();

  @TestVisible
  private static Group queue = [
    SELECT id
    FROM group
    WHERE developername = :CRC_QUEUE_DEVELOPER_NAME AND Type = :QUEUE_TYPE
  ];

  public static Group siQueue = [
    SELECT id
    FROM group
    WHERE developername = :SI_QUEUE_DEVELOPER_NAME AND Type = :QUEUE_TYPE
  ];

  /**
   * @description applyDefaults is called onBeforeInsert to set the following values as defaults
   * 1. IDR_Account_Card_Policy_Number__c field masking as part of Customer Complaint Recording in IDR {@link #handleMasking(record) handleMasking}.
   * 2. Handle anonymous names if complainant doesnt want to share their info. This is for NON ANZ Customer rasing a complaint {@link #handleAnonymousNames(record) handleAnonymousNames}.
   * 3. Handle case status changes such as updating IsEscalated to true if the case is created as escalated case. Change the reopen date if case is created with re-opened status {@link #handleCaseStatusChanges(record) handleCaseStatusChanges}.
   * 4. Handle office assignment based on the case Owner's Division of the current case. {@link handleOfficeAssignment(cases) handleOfficeAssignment}.
   * 5. Update Date/Time PSI Ticked if complaint is flagged as PSI
   * @param records The record list form which we need to apply defaults
   * <p>
   * <b>Note:</b> It is always good to change/update values in on onBeforeInsert rather than in onAfterInsert
   * However in situations where the ID or CaseNumber is used which is only generated in onAfterInsert that logic needs to go in onAfterInsert.
   */
  public static void applyDefaults(List<Case> records) {
    Id entitlementId = getEntitlement();
    //future use do not remove the below commented code
    // salesforce limitation ,business hours id is not populated at this point in time get the  complaints business hours (default value) for SLA calculation;
    /*Id businessHoursId ;
    if(BusinessHours.sObjectType.getDescribe().isQueryable()) {
      list<BusinessHours> bh = new list<BusinessHours>();
      bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
      if(bh.size() > 0){
         businessHoursId = bh[0].Id ;
      }      
    }*/
    Case[] updatePsiTicked = new List<Case>();
    for (Case record : records) {
      if (isIDRComplaintType(record)) {
        record.EntitlementId = entitlementId;
        record.IDR_Milestone_Sla__c = IDRConstants.MILESTONE_SLA_NORMAL;
        // record.IDR_Milestone_Sla__c = getMilestoneSla(record.Status, record.IDR_Date_Received__c , businessHoursId);
        handleMasking(record);
        handleAnonymousNames(record);
        handleCaseStatusChanges(record);
        if (((String) record.OwnerId).startsWith(Label.ID_Prefix_User)) {
          caseOwnerIds.add(record.OwnerId);
          changeOfficeCaseList.add(record);
        }
        handleCaseEscalationRules(record, new Case());
        if (record.IDR_Is_Common__c == 'Yes') {
          updatePsiTicked.add(record);
        }
      }
    }
    handleOfficeAssignment(changeOfficeCaseList);
    stampQueueName(records, null);
    //Update Date/Time PSI Ticked if complaint is flagged as PSI
    if (!updatePsiTicked.isEmpty()) {
      updateDateTimePsiTicked(updatePsiTicked);
    }
    triggerCollectionActivities(records, null);
  }

  /**
   * @description afterInsert(records) After isert IDR actions which
   * @param records
   */
  public static void afterInsert(List<Case> records) {
    for (Case record : records) {
      if (isIDRComplaintType(record)) {
        if (NOTIFICATION_STATUS.contains(record.Status)) {
          notificationCaseList.add(record);
        }
        checkForCRCEscalation(record);
      }
    }
    possibleSystemicIssueActions(records, null);
  }

  /**
   * @description beforeUpdate(oldMap, records) method handles the following
   * 1. Handle Masking - IDR_Account_Card_Policy_Number__c field masking as part of Customer Complaint Recording in IDR {@link #handleMasking(record) handleMasking}.
   * 2. Handle anonymous names if complainant doesnt want to share their info. This is for NON ANZ Customer rasing a complaint {@link #handleAnonymousNames(record) handleAnonymousNames}.
   * 3. Identify records for which owner is changed for IDR_Office__c to be updated. Note we need to update only the records for which the owner has changed and the owner is User(not Group).
   * 4. Handle case status changes only for records which had a status change. Actions such as updating IsEscalated to true if the case is created as escalated case. Change the reopen date if case is created with re-opened status {@link #handleCaseStatusChanges(record) handleCaseStatusChanges}.
   * 5. Update Date/Time PSI Ticked when complaint is flagged or unflagged
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onBeforeUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @param records from the trigger
   */
  public static void beforeUpdate(Map<Id, SObject> oldMap, List<Case> records) {
    Id entitlementId = getEntitlement();
    Case[] updatePsiTicked = new List<Case>();
    for (Integer i = 0; i < records.size(); i++) {
      if (isIDRComplaintType(records.get(i))) {
        validateCaseNumber(
          records.get(i),
          (case) oldMap.get(records.get(i).id)
        );
        handleMasking(records.get(i));
        handleAnonymousNames(records.get(i));
        handleEntitlementForUpdate(
          records.get(i),
          (Case) oldMap.get(records.get(i).id),
          entitlementId
        );
        identifyOwnerChangeRecords(
          records.get(i),
          ((Case) oldMap.get(records.get(i).id)).OwnerId
        );
        if (
          records.get(i).Status != ((Case) oldMap.get(records.get(i).id)).Status
        ) {
          handleCaseStatusChanges(records.get(i));
        }
        handleCaseEscalationRules(
          records.get(i),
          (case) oldMap.get(records.get(i).id)
        );
        if (
          records.get(i).IDR_Is_Common__c !=
          ((Case) oldMap.get(records.get(i).id)).IDR_Is_Common__c
        ) {
          updatePsiTicked.add(records.get(i));
        }
      }
    }
    //calling handleOfficeAssignment for all case records for which the IDR_Office__c needs to be updated.
    handleOfficeAssignment(changeOfficeCaseList);
    stampQueueName(records, (Map<Id, Case>) oldMap);
    //Update Date/Time PSI Ticked if complaint is flagged as PSI
    if (!updatePsiTicked.isEmpty()) {
      updateDateTimePsiTicked(updatePsiTicked);
    }
    triggerCollectionActivities(records, (Map<Id, Case>) oldMap);
  }

  /**
   * @description afterUpdate(oldMap, records) method handles the following
   * 1. Validates the case status and add them into notification list.
   * 2. Calls checkForCRCEscalation method to check if the case record needs to be sent for CRC escalation.
   * 3. Calls escalateExistingCommentsToCFMS to escalation case comments upon receiving COM IDs from CFMS
   * 4. Calls rollupToParentSI to update the counter of linked complaints on the parent systemic issue record
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @param records from the trigger
   */
  public static void afterUpdate(Map<Id, SObject> oldMap, List<Case> records) {
    for (Integer i = 0; i < records.size(); i++) {
      Case record = records[i];
      Case oldRec = (Case) oldMap.get(record.id);
      if (
        record.Status != oldRec.Status ||
        (oldRec.RecordTypeId == GENERAL_INQUIRY_CMOS_RT_ID &&
        isIDRComplaintType(record))
      ) {
        if (NOTIFICATION_STATUS.contains(record.Status)) {
          notificationCaseList.add(record);
        }
        checkForCRCEscalation(record);
      }
      IDRCaseCommentActions.escalateExistingCommentsToCFMS(oldMap, records);
    }
    possibleSystemicIssueActions(records, oldMap);
  }

  /**
   * @description Check if this case record needs to be sent for CRC escalation
   * @param record case record
   */
  private static void checkForCRCEscalation(Case record) {
    if (
      record.Status == ESCALATED_STATUS &&
      (record.IDR_Escalated_to__c == ESCALATED_TO_CRC_API_NAME ||
      (record.OwnerId.getSobjectType() == Group.SobjectType &&
      record.OwnerId == queue.Id))
    ) {
      caseEscalationList.add(record);
    }
  }

  /**
   * @description completeAfterActions() is called post onAfterInsert and onAfterUpdate
   */
  public static void completeAfterActions() {
    CheckRecursive.run();
    NotificationTriggerHandler.insertNotificationHandler(notificationCaseList);
    escalateToCFMS(caseEscalationList);
    executeAssignmentRule(caseEscalationList);
    notificationCaseList.clear();
    caseEscalationList.clear();
  }

  /**
   * @description method to trigger collections activity in downstream systems when collections flag is turned on for a customer on a complaint.
   * @param records List of Case records in current  trigger context
   * @param oldMap old Map of Case records in current  trigger context
   */
  private static void triggerCollectionActivities(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Database.SaveResult> publishResults = new List<Database.SaveResult>() ;
    List<IDR_Collections_Event__e> collectionsCasesEventList = new List<IDR_Collections_Event__e>();
    for (Case c : records) {
      if (c.recordTypeId == CUSTOMER_COMPLAINT_RT_ID) {
        if (
          oldMap == null &&
          (c.Priority == IDRConstants.PRIORITY_COLLECTIONS ||
          c.Priority == IDRConstants.PRIORITY_HARDSHIP) &&
          (c.Type == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.Type == IDRConstants.ISSUE_TYPE_COLLECTIONS ||
          c.IDR_Issue_Type_2__c == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.IDR_Issue_Type_2__c == IDRConstants.ISSUE_TYPE_COLLECTIONS ||
          c.IDR_Issue_Type_3__c == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.IDR_Issue_Type_3__c == IDRConstants.ISSUE_TYPE_COLLECTIONS)
        ) {
          // that means it is on insert
          collectionsCasesEventList.add(buildEvent(c));
          c.IDR_Stop_Collections__c = true;
        } else if (
          oldMap != null &&
          (oldMap.get(c.Id).Priority != c.Priority &&
          oldMap.get(c.Id).Priority != IDRConstants.PRIORITY_COLLECTIONS &&
          oldMap.get(c.Id).Priority != IDRConstants.PRIORITY_HARDSHIP &&
          (c.Priority == IDRConstants.PRIORITY_COLLECTIONS ||
          c.Priority == IDRConstants.PRIORITY_HARDSHIP)) &&
          ((oldMap.get(c.Id).Type != c.Type &&
          oldMap.get(c.Id).Type != IDRConstants.ISSUE_TYPE_HARDSHIP &&
          oldMap.get(c.Id).Type != IDRConstants.ISSUE_TYPE_COLLECTIONS &&
          (c.Type == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.Type == IDRConstants.ISSUE_TYPE_COLLECTIONS)) ||
          (oldMap.get(c.Id).IDR_Issue_Type_2__c != c.IDR_Issue_Type_2__c &&
          oldMap.get(c.Id).IDR_Issue_Type_2__c !=
          IDRConstants.ISSUE_TYPE_HARDSHIP &&
          oldMap.get(c.Id).IDR_Issue_Type_2__c !=
          IDRConstants.ISSUE_TYPE_COLLECTIONS &&
          (c.IDR_Issue_Type_2__c == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.IDR_Issue_Type_2__c == IDRConstants.ISSUE_TYPE_COLLECTIONS)) ||
          (oldMap.get(c.Id).IDR_Issue_Type_3__c != c.IDR_Issue_Type_3__c &&
          oldMap.get(c.Id).IDR_Issue_Type_3__c !=
          IDRConstants.ISSUE_TYPE_HARDSHIP &&
          oldMap.get(c.Id).IDR_Issue_Type_3__c !=
          IDRConstants.ISSUE_TYPE_COLLECTIONS &&
          (c.IDR_Issue_Type_3__c == IDRConstants.ISSUE_TYPE_HARDSHIP ||
          c.IDR_Issue_Type_3__c == IDRConstants.ISSUE_TYPE_COLLECTIONS)))
        ) {
          collectionsCasesEventList.add(buildEvent(c));
          c.IDR_Stop_Collections__c = true;
        }
      }
    }
    if (!collectionsCasesEventList.isEmpty()) {
      publishResults = EventBus.publish(collectionsCasesEventList);
    }
    for (Integer i = 0; i < publishResults.size(); i++) {
      Database.SaveResult sr = publishResults[i];
      if (!publishResults[i].isSuccess()) {
        for (Database.Error err : publishResults[i].getErrors()) {
          Lib_SystemLog.logAPIError(
            IDRCaseActions.class.getName(),
            'Error in publishing collection platform event for Case' +
            collectionsCasesEventList[i].IDR_Complaint_Number__c,
            err.getMessage(),
            null,
            IDRCaseActions.class.getName(),
            null,
            null
          );
        }
      }
    }
  }

  /**
   * @description method to trigger collections activity in downstream systems when collections flag is turned on for a customer on a complaint.
   * @param c A case record
   * @return Platform event record
   */
  private static IDR_Collections_Event__e buildEvent(Case c) {
    IDR_Collections_Event__e collectionsEvent = new IDR_Collections_Event__e();
    collectionsEvent.IDR_Customer_Number__c = c.IDR_Customer_Number__c;
    collectionsEvent.IDR_OCV_Id__c = null; // When AR&C Customer are in SF replace this line with Account's OCV
    collectionsEvent.IDR_Complaint_Created_Date__c = Date.newinstance(
      c.IDR_Date_Received__c.year(),
      c.IDR_Date_Received__c.month(),
      c.IDR_Date_Received__c.day()
    );

    if (
      c.Status == IDRConstants.RESOLVED_STATUS ||
      c.Status == IDRConstants.CLOSED_STATUS
    ) {
      collectionsEvent.IDR_Complaint_Resolved_Date__c = Date.newinstance(
        c.ClosedDate.year(),
        c.ClosedDate.month(),
        c.ClosedDate.day()
      );
    }

    collectionsEvent.IDR_Complaint_Number__c = c.CaseNumber;
    collectionsEvent.IDR_Complaint_Status__c = c.Status;
    collectionsEvent.IDR_Account_Details__c = getAccountListJson(c);

    return collectionsEvent;
  }

  /**
   * @description Method to return list of account to be sent for collections in a json string
   * @param c A case record
   * @return Json String
   */
  private static String getAccountListJson(Case c) {
    List<IDRCollectionsAccounts> collectionAcctsList = new List<IDRCollectionsAccounts>();

    collectionAcctsList.add(
      new IDRCollectionsAccounts(
        c.IDR_Account_Card_Policy_Number__c,
        null,
        null
      )
    );

    if (c.IDR_Second_Issue__c) {
      collectionAcctsList.add(
        new IDRCollectionsAccounts(
          c.IDR_Account_Card_Policy_Number_2__c,
          null,
          null
        )
      );
    }

    if (c.IDR_Third_Issue__c) {
      collectionAcctsList.add(
        new IDRCollectionsAccounts(
          c.IDR_Account_Card_Policy_Number_3__c,
          null,
          null
        )
      );
    }

    return Json.serialize(collectionAcctsList);
  }

  /**
   * @description Execute the assignment rules on escalated cases
   * @param caseList List of escalated cases
   */
  public static void executeAssignmentRule(List<Case> caseList) {
    List<Case> cList = new List<Case>();
    for (Case c : caseList) {
      Case caseRecord = new Case(id = c.id);
      Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.assignmentRuleHeader.useDefaultRule = true;
      caseRecord.setOptions(dmo);
      cList.add(caseRecord);
    }

    List<Database.SaveResult> saveResultList = Database.update(cList, false);

    for (Database.SaveResult sr : saveResultList) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          Lib_SystemLog.logAPIError(
            IDRCaseActions.class.getName(),
            'Error in executing case Assignment Rule for record id' +
            sr.getId(),
            err.getMessage(),
            null,
            IDRCaseActions.class.getName(),
            null,
            null
          );
        }
      }
    }
  }

  /**
   * @description onBeforeDelete of IDR Case records. No user is allowed to delete a complaint or a systemic issue.
   * Check if its IDR record type and prevent deleteing for anzx can handle other scenarios
   * @param records
   */
  public static void onBeforeDelete(List<Case> records) {
    for (Case record : records) {
      if (
        isIDRComplaintType(record) ||
        record.recordTypeId == SICaseActions.SI_RT_ID
      ) {
        record.addError(DELETE_ERROR);
      }
    }
  }

  /**
   * @description identifyOwnerChangeRecords checks if the record Owner is User (not Group).
   * It also checks if the owner has changed. We only want to copy the IDR_Office__c if the owner has changed.
   * @param record The actual case record from the trigger
   * @param  oldOwnerId old owner id to check if it changed
   */
  private static void identifyOwnerChangeRecords(
    Case record,
    String oldOwnerId
  ) {
    if (
      record.OwnerId.getSobjectType() == User.SobjectType &&
      record.OwnerId != oldOwnerId
    ) {
      caseOwnerIds.add(record.OwnerId);
      changeOfficeCaseList.add(record);
    }
  }

  /**
   * @description checks if teh owner is Queue or not and then stamps the Queue Name to the Queue field.
   * Once teh case owner accepts the case we lose the track of Queue, and hence the explicit field
   * @param caseList case list in current context
   * @param  oldCaseMap old map of the cases in current context
   */
  private static void stampQueueName(
    List<Case> caseList,
    Map<Id, Case> oldCaseMap
  ) {
    Set<Id> queueIds = new Set<Id>();

    for (Case c : caseList) {
      if (c.OwnerId.getSobjectType() == Group.SobjectType) {
        if (
          oldCaseMap != null &&
          oldCaseMap.containsKey(c.id) &&
          c.OwnerId != oldCaseMap.get(c.id).OwnerId
        ) {
          queueIds.add(c.OwnerId);
        } else if (oldCaseMap == null) {
          queueIds.add(c.OwnerId);
        }
      }
    }

    Map<Id, Group> queueMap = new Map<Id, Group>(
      [SELECT id, Name FROM Group WHERE Id IN :queueIds]
    );

    for (Case c : caseList) {
      if (queueMap.containsKey(c.OwnerId)) {
        c.Queue__c = queueMap.get(c.OwnerId).Name;
      }
    }
  }

  /**
   * @description handleAnonymousNames is used to handle when the complainant does not accept the consent and wants to remain anonymous.
   * So we note their name as Anonymous in the case.
   * @param record The actual case record from the trigger
   */
  private static void handleAnonymousNames(Case record) {
    if (
      record.RecordTypeId == NON_CUSTOMER_COMPLAINT_RT_ID &&
      record.IDR_NC_Is_Consent_Obtained__c == false &&
      record.IDR_NC_First_Name__c != Label.Anonymous_Complainant &&
      record.IDR_NC_Middle_Names__c != Label.Anonymous_Complainant &&
      record.IDR_NC_Last_Name__c != Label.Anonymous_Complainant
    ) {
      record.IDR_NC_First_Name__c = Label.Anonymous_Complainant;
      record.IDR_NC_Middle_Names__c = Label.Anonymous_Complainant;
      record.IDR_NC_Last_Name__c = Label.Anonymous_Complainant;
    }
  }

  /**
   * @description handleMasking method is used to mask the Account/Policy number as we dont want to store the account number in SF. So, we mask the number and store only last last 4 digits unmasked.
   * @param record The actual case record from the trigger
   */
  private static void handleMasking(Case record) {
    record.IDR_Account_Card_Policy_Number__c = TextUtils.maskData(
      record.IDR_Account_Card_Policy_Number__c
    );
    record.IDR_Account_Card_Policy_Number_2__c = TextUtils.maskData(
      record.IDR_Account_Card_Policy_Number_2__c
    );
    record.IDR_Account_Card_Policy_Number_3__c = TextUtils.maskData(
      record.IDR_Account_Card_Policy_Number_3__c
    );
    record.Description = TextUtils.maskData(record.Description);
    record.IDR_Complainant_Desired_Outcome__c = TextUtils.maskData(
      record.IDR_Complainant_Desired_Outcome__c
    );
    record.IDR_Description_of_Outcome__c = TextUtils.maskData(
      record.IDR_Description_of_Outcome__c
    );
    record.IDR_Systemic_Issue_Description__c = TextUtils.maskData(
      record.IDR_Systemic_Issue_Description__c
    );
  }
  /**
   * @description  handleCaseEscalationRules method is used to handle the case escalations
   * 1.First condition check is for auto esclated cases
   * 2.second condition checks for cases created as escalated.
   * 3.third condition checks for cases that have been esclated after create.
   * 4.Fourth condition checks for cases that have a change in 'escalated to' after the case is already escalated.
   * @param record The actual case record from the trigger
   * @param oldRec trigger context variable to check on old values.
   */
  private static void handleCaseEscalationRules(Case record, Case oldRec) {
    if (
      record.IsEscalated &&
      record.Status != ESCALATED_STATUS &&
      String.isBlank(record.IDR_Escalation_Reason__c)
    ) {
      // set default values for auto escalated cases , change status to escalated,
      //assign to CRC queue and send notifcation to CFMS
      if (oldRec.Status == OPEN_STATUS) {
        record.IDR_Escalation_Reason__c = DAY_3_ESCALATION_REASON;
      } else if (oldRec.Status == UNDER_INVESTIGATION_STATUS) {
        record.IDR_Escalation_Reason__c = DAY_5_ESCALATION_REASON;
      }
      record.Status = ESCALATED_STATUS;
    } else if (
      record.Status == ESCALATED_STATUS &&
      String.isBlank(record.IDR_Escalated_to__c)
    ) {
      record.IDR_Escalated_to__c = '1';
    }
  }

  /**
   * @description  handleCaseStatusChanges method is used to handle the case status changes as follows
   * 1. when a case is escalated mark the case's IsEscalated value to true and
   * 2. when a case is reopened mark the IDR_Date_Re_Opened__c as current date.
   * @param record The actual case record from the trigger
   */
  private static void handleCaseStatusChanges(Case record) {
    if (record.Status == ESCALATED_STATUS) {
      if (!record.IsEscalated) {
        record.IsEscalated = true;
      }
    }
    if (record.Status == REOPENED_STATUS) {
      record.IDR_Date_Re_Opened__c = System.today();
      record.IsEscalated = false;
    }
  }
  /**
   * @description  handleEntitlementForUpdate method is used to update the entitlment and time to escalation flag.
   * 1. when a case is updated by the indexing team. entitlment ID and Flag both need to be calculated.
   * 2. when a case has a status change. Flag status is needs to be recalculated.
   * Note : IDR_Milestone_Sla__c is updated by entitlment process. this code is to handle the edge case scenarios.
   * where the date received is back dated and milestones warning actions will not execute.
   * @param record The actual case record from the trigger
   * @param oldRec The old record values for the case
   * @param entitlementId Entitlment ID that needs to be populated on the complaints case.
   */
  private static void handleEntitlementForUpdate(
    Case record,
    Case oldRec,
    Id entitlementId
  ) {
    // this is a case where indexing team as updated the details and identified it as a complaint.
    // in this case we need to update the entitlement && flag on the case.
    if (string.isBlank(record.EntitlementId)) {
      record.EntitlementId = entitlementId;
      record.IDR_Milestone_Sla__c = getMilestoneSla(
        record.Status,
        record.IDR_Date_Received__c,
        record.BusinessHoursId
      );
    }

    // this is a case where complaint has changed status. we need to recalculate the flag status.
    if (
      record.Status != oldRec.Status &&
      (record.Status == UNDER_INVESTIGATION_STATUS ||
      record.Status == OPEN_STATUS)
    ) {
      record.IDR_Milestone_Sla__c = getMilestoneSla(
        record.Status,
        record.IDR_Date_Received__c,
        record.BusinessHoursId
      );
    }
  }

  /**
   * @description  getMilestoneSla method is used to identify the appropriate SLA flag that needs to be shown on the case.
   * 1. when a case is open for less than 1 business day or is under investgation for less than 3 days it should be green (normal)
   * 2. when a case is open for  1-2 business days or  is under investigation for  3-4 business days it should be flagged as amber
   * 3. when a case is open for more than 2 business days or  is under investigation for more than 4 business days it shoud be flagged as red.
   * 4. if the case is open 3 days  or more / is under investgation for 5 days/more it will be auto escalated ,mark as violated.
   * @param caseStatus status of the case record
   * @param dateReceived IDR_Date_Recieved field of the case
   * @param businessHoursId business hours of the case record.
   * @return string value of the flag calculated based on the time elapsed from dateReceuved
   */
  private static string getMilestoneSla(
    string caseStatus,
    dateTime dateReceived,
    ID businessHoursId
  ) {
    string milestoneSla;
    decimal duration = DateTimeUtils.calculateHoursBetween(
      dateReceived,
      system.NOW(),
      businessHoursId
    );
    if (
      (caseStatus == UNDER_INVESTIGATION_STATUS && duration.intValue() < 72) ||
      (caseStatus == OPEN_STATUS &&
      duration.intValue() < 24)
    ) {
      milestoneSla = IDRConstants.MILESTONE_SLA_NORMAL;
    } else if (
      (caseStatus == UNDER_INVESTIGATION_STATUS &&
      duration.intValue() >= 72 &&
      duration.intValue() < 96) ||
      (caseStatus == OPEN_STATUS &&
      duration.intValue() >= 24 &&
      duration.intValue() < 48)
    ) {
      milestoneSla = IDRConstants.MILESTONE_SLA_AMBER;
    } else if (
      (caseStatus == UNDER_INVESTIGATION_STATUS &&
      duration.intValue() >= 96 &&
      duration.intValue() < 120) ||
      (caseStatus == OPEN_STATUS &&
      duration.intValue() >= 48 &&
      duration.intValue() < 72)
    ) {
      milestoneSla = IDRConstants.MILESTONE_SLA_RED;
    } else {
      milestoneSla = IDRConstants.MILESTONE_SLA_VIOLATED;
    }
    return milestoneSla;
  }
  /**
   * @description Get the EntitlmentId that will be associated with this case
   *@return Id  - the Id of the entitlment record
   */
  public static Id getEntitlement() {
    list<Entitlement> et = new List<Entitlement>();
    if (Entitlement.sObjectType.getDescribe().isQueryable()) {
      et = [
        SELECT Id
        FROM Entitlement
        WHERE
          name = :IDRConstants.COMPLAINTS_ENTITLEMENT_NAME
          AND SlaProcess.Name = :IDRConstants.COMPLAINTS_ENTITLMENT_PROCESS
          AND STATUS = 'Active'
      ];
    }
    if (et.size() > 0) {
      return et[0].Id;
    } else {
      return null;
    }
  }
  /**
   * @description Escalate the list of Records to CRC by publishing a platform event.
   * @param recordsToBeEscalated
   */
  private static void escalateToCFMS(List<Case> recordsToBeEscalated) {
    if (recordsToBeEscalated.isEmpty()) {
      return;
    }
    idrCaseEscalations = new List<IDR_CRC_Escalation_Event__e>();
    for (Case c : recordsToBeEscalated) {
      idrCaseEscalations.add(
        new IDR_CRC_Escalation_Event__e(
          Account_Number__c = c.IDR_Account_Card_Policy_Number__c,
          Address_Line1__c = c.IDR_NC_Street__c,
          AFCA_Date__c = c.IDR_AFCA_Date__c,
          AFCA_Number__c = c.IDR_AFCA_Number__c,
          Age__c = IDRCaseActions.getPicklistLabel(
            Case.IDR_NC_Age__c,
            c.IDR_NC_Age__c
          ),
          Non_Financial_Remedy__c = c.IDR_Non_Financial_Remedy__c,
          Agent_License_Number__c = c.IDR_AuthRep_Licence_Number__c,
          Agent_License_Type__c = IDRCaseActions.getPicklistLabel(
            Case.IDR_AuthRep_Licence_or_registration_type__c,
            c.IDR_AuthRep_Licence_or_registration_type__c
          ),
          ANZ_Received_Date__c = c.IDR_Date_Received__c.date(),
          Case_Number__c = String.isNotBlank(c.CaseNumber__c)
            ? c.CaseNumber__c
            : c.CaseNumber,
          Customer_First_Name__c = c.IDR_NC_First_Name__c,
          Customer_Middle_Names__c = c.IDR_NC_Middle_Names__c,
          Customer_Last_Name__c = c.IDR_NC_Last_Name__c,
          Customer_Business_Name__c = c.IDR_NC_Business_Name__c,
          Complainant_Type__c = IDRCaseActions.getPicklistLabel(
            Case.IDR_Complainant_Type__c,
            c.IDR_Complainant_Type__c
          ),
          Complaint_Description__c = c.Description,
          Complaint_Desired_Outcome__c = c.IDR_Complainant_Desired_Outcome__c,
          Complaint_Issue__c = IDRCaseActions.getPicklistLabel(
            Case.Type,
            c.Type
          ),
          Complaint_Issue_Key__c = c.Type,
          Complaint_Subsequent_Issue__c = c.IDR_Subsequent_Issue__c,
          Country__c = c.IDR_NC_Country__c,
          Customer_Number__c = c.IDR_Customer_Number__c,
          Email__c = c.IDR_NC_Email__c,
          Gender__c = IDRCaseActions.getPicklistLabel(
            Case.IDR_NC_Gender__c,
            c.IDR_NC_Gender__c
          ),
          Is_Written_Response_Requested__c = c.IDR_Is_Written_Resp_Requested__c ==
            YES_VALUE
            ? true
            : false,
          Is_Written_Response_Required__c = c.IDR_Is_Written_Resp_Required__c ==
            YES_VALUE
            ? true
            : false,
          Mobile__c = c.IDR_NC_Mobile__c,
          Phone__c = c.IDR_NC_Phone__c,
          Post_Code__c = c.IDR_NC_Postcode__c,
          Remedy__c = IDRCaseActions.getPicklistLabel(
            Case.IDR_Complaint_Remedy__c,
            c.IDR_Complaint_Remedy__c
          ),
          State__c = c.IDR_NC_State__c == '11'
            ? 'OTHER TERRITORIES'
            : IDRCaseActions.getPicklistLabel(
                Case.IDR_NC_State__c,
                c.IDR_NC_State__c
              ),
          Suburb__c = c.IDR_NC_Suburb__c,
          Priority__c = c.Priority,
          Channel_Received__c = IDRCaseActions.getPicklistLabel(
            Case.Origin,
            c.Origin
          ),
          Relationship_To_Complainant__c = c.IDR_3rdParty_Relationship_To_Complainant__c,
          IDR_Is_Common__c = c.IDR_Is_Common__c,
          IDR_Systemic_Issue_Category__c = c.IDR_Systemic_Issue_Category__c,
          IDR_Systemic_Issue_Description__c = c.IDR_Systemic_Issue_Description__c
        )
      );
    }
    if (!idrCaseEscalations.isEmpty()) {
      List<Database.SaveResult> results = EventBus.publish(idrCaseEscalations);
      Lib_SystemLog log = new Lib_SystemLog(
        IDRCaseActions.class.getName(),
        'escalateToCFMS'
      );
      log.addDatabaseSaveResult(
        'IDR_CRC_Escalation_Event__e',
        results,
        idrCaseEscalations
      );
      log.insertLog();
    }
    //Todo handle errors further if needed.
  }

  /**
   * @description  sendNotifications method is to send out platform events for notifications to customers. Mulesoft subscribes to these notifications and makes Notification Broker API call.
   * @param records The records for which notifications needs to be sent out
   */
  private static void sendNotifications(List<Case> records) {
    if (records.isEmpty()) {
      return;
    }
    idrNotifications = new List<IDR_Notification_Event__e>();
    for (Case c : records) {
      // Don't publish to NB if there's no mobile nor email to send to
      if (
        c.RecordTypeId == CUSTOMER_COMPLAINT_RT_ID ||
        !String.isBlank(c.IDR_NC_Mobile__c) ||
        !String.isBlank(c.IDR_NC_Email__c) ||
        !String.isBlank(c.IDR_3rdParty_Mobile__c) ||
        !String.isBlank(c.IDR_3rdParty_Email__c)
      ) {
        idrNotifications.add(
          new IDR_Notification_Event__e(
            AuthorisedEmail__c = c.IDR_3rdParty_Email__c,
            AuthorisedFirstName__c = c.IDR_3rdParty_Name__c,
            AuthorisedMobile__c = c.IDR_3rdParty_Mobile__c,
            CAP_CIS_ID__c = c.IDR_Customer_Number__c,
            Case_ID__c = c.ID,
            Case_Number__c = IDRCaseActions.getFormattedCaseNumberToNotify(c),
            Case_Status__c = c.Status,
            Case_Status_Change_Date__c = System.now(),
            ComplainantEmail__c = c.IDR_NC_Email__c,
            ComplainantFirstName__c = c.IDR_NC_Is_Consent_Obtained__c == false
              ? ''
              : c.IDR_NC_First_Name__c,
            ComplainantMobile__c = c.IDR_NC_Mobile__c,
            EmailFlag__c = true,
            EmailTemplate__c = c.Isescalated
              ? TEMPLATE_ID_MAP.get(ESCALATED_STATUS)
              : TEMPLATE_ID_MAP.get(c.Status),
            MessageID__c = '' + c.ID + Datetime.now().millisecond(),
            SMSFlag__c = true,
            SMSTemplate__c = c.Isescalated
              ? TEMPLATE_ID_MAP.get(ESCALATED_STATUS)
              : TEMPLATE_ID_MAP.get(c.Status)
          )
        );
      }
    }
    if (!idrNotifications.isEmpty()) {
      List<Database.SaveResult> results = EventBus.publish(idrNotifications);
      Lib_SystemLog log = new Lib_SystemLog(
        IDRCaseActions.class.getName(),
        'sendNotifications'
      );
      log.addDatabaseSaveResult(
        'IDR_Notification_Event__e',
        results,
        idrNotifications
      );
      log.insertLog();
    }
    //Todo handle errors further if needed.
  }

  /**
   * @description isIDRComplaintType check if record type is of IDR type.
   * As this Trigger will be used across various teams we identify case record based on IDR record Type.
   *
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of IDR type false otherwise.
   */
  public static Boolean isIDRComplaintType(Case record) {
    if (
      record.RecordTypeId == CUSTOMER_COMPLAINT_RT_ID ||
      record.RecordTypeId == NON_CUSTOMER_COMPLAINT_RT_ID
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Copy the Case Owners Users division into the IDR_Office__c field.
   * Even if the division of case owner changes later this field shouldn't change.
   * Unless the case owner changes for the case do not update the field.
   * Note : Edge case if A and B are 2 Users and if A has a division1 and B has Division 2 and if case owner from A was changed to B Office will hold Division2.
   * If in the meanwhile if A has moved to division3 and owner is changed back from B to A we can only hold Division3 in Office field
   * @param cases cases to handle the owner changes
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  private static void handleOfficeAssignment(List<Case> cases) {
    if (caseOwnerIds.isEmpty()) {
      return;
    }
    if (
      userMap.size() != caseOwnerIds.size() &&
      User.sObjectType.getDescribe().isQueryable()
    ) {
      userMap.clear();
      List<User> users = [
        SELECT Id, Division
        FROM USER
        WHERE Id IN :caseOwnerIds
      ];
      userMap.putAll(users);
    }
    for (Case record : cases) {
      if (userMap.keySet().contains(record.OwnerId)) {
        record.IDR_Office__c = ((User) userMap.get(record.OwnerId)).Division;
      }
    }
  }

  /**
   * @description In notifications, use Use CaseNumber__c if available, CaseNumber otherwise. Also, remove the trailing zeros.
   * @param c Case to get the number from
   * @return the Case number, ready to be inserted in a nofification's body
   */
  @TestVisible
  private static String getFormattedCaseNumberToNotify(Case c) {
    return String.valueOf(
      Integer.valueOf(
        String.isNotBlank(c.CaseNumber__c) ? c.CaseNumber__c : c.CaseNumber
      )
    );
  }

  /**
   * @description Get a picklist label from it's value (API_Key).
   * @param field The picklist field, for example Case.IDR_NC_State__c
   * @param picklistValue The picklist value, for example '2'
   * @return the picklist label, for example 'VIC'
   */
  @TestVisible
  private static String getPicklistLabel(
    Schema.SobjectField field,
    String picklistValue
  ) {
    Schema.DescribeFieldResult fieldPicklist = field.getDescribe();
    Map<String, String> fieldMap = new Map<String, String>();
    for (Schema.PicklistEntry f : fieldPicklist.getPicklistValues()) {
      if (f.getValue() == picklistValue) {
        return f.getLabel();
      }
    }
    return '';
  }

  /**
   * @description  This method is used to restrict users from editing case number based on certain conditions
   * @param record The actual case record from the trigger
   * @param oldRec trigger context variable to check on old values.
   */
  private static void validateCaseNumber(Case record, Case oldRec) {
    if (
      record.RecordTypeId == CUSTOMER_COMPLAINT_RT_ID &&
      record.IDR_Customer_Number__c != oldRec.IDR_Customer_Number__c &&
      oldRec.RecordTypeId != GENERAL_INQUIRY_CMOS_RT_ID
    ) {
      record.addError(CUSTOMER_NUMBER_VALIDATION_ERROR);
    }
  }

  /**
   * @description possibleSystemicIssueActions(records, oldMap) method handles the following
   * 1. Calls rollupToParentSI to update the counter of linked complaints on the parent systemic issue record
   * 2. Calls createTaskforPSI method to generate task if the complaint is a PSI and created/updated by L1 user
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate.
   */
  private static void possibleSystemicIssueActions(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    Case[] childComplaints = new List<Case>(); //records to rollup on parent systemic issue
    Task[] siTasks = new List<Task>();

    for (Case record : records) {
      Case oldRec;
      if (oldMap != null) {
        oldRec = (Case) oldMap.get(record.id);
      }

      //should a parent systemic issue's rollup field be updated?
      if (
        isIDRComplaintType(record) &&
        (oldRec == null ||
        record.IDR_Parent_Systemic_Issue__c !=
        oldRec.IDR_Parent_Systemic_Issue__c)
      ) {
        //just linked or unliked?
        if (String.isNotBlank(record.IDR_Parent_Systemic_Issue__c)) {
          childComplaints.add(record);
        } else if (oldRec != null) {
          childComplaints.add(oldRec);
        }
      }

      //create task if it is a possible systemic issue and level 1 user is making the change
      if (
        isIDRComplaintType(record) &&
        record.IDR_Is_Common__c == 'Yes' &&
        FeatureManagement.checkPermission('IDR_Level_1') &&
        (oldRec == null ||
        record.IDR_Is_Common__c != oldRec.IDR_Is_Common__c)
      ) {
        siTasks.add(createTaskForPSI(record));
      }
    }

    //rollup on parent systemic issue
    if (!childComplaints.isEmpty()) {
      SICaseActions.rollupToParentSI(childComplaints);
    }

    //insert SI Tasks
    if (!siTasks.isEmpty() && Task.sObjectType.getDescribe().isCreateable()) {
      insert siTasks;
    }
  }

  /**
   * @description Create a task and assign it to SI team for review
   * @param c Parent case of the tasks
   * @return An instance of a Task
   */
  private static Task createTaskForPSI(Case c) {
    Date activityDate = Date.today().addDays(5);
    return new Task(
      RecordTypeId = IDR_TASK_RT_ID,
      OwnerId = siQueue.Id,
      WhatId = c.Id,
      Subject = IDR_TASK_SUBJECT,
      ActivityDate = activityDate,
      IsReminderSet = true,
      ReminderDateTime = (DateTime) (activityDate - 2)
    );
  }

  /**
   * @description Update Date/Time PSI Ticked when complaint is flagged or unflagged. Before calling, check whether all cases are complaints and the PSI flag has just been ticked or unticked
   * @param records from the trigger
   */
  private static void updateDateTimePsiTicked(List<Case> records) {
    for (Case record : records) {
      if (record.IDR_Is_Common__c == 'Yes') {
        record.IDR_Datetime_PSI_Ticked__c = Datetime.now();
      } else {
        record.IDR_Datetime_PSI_Ticked__c = null;
      }
    }
  }
}
