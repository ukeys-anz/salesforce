/**
 * @author Pavan Kumar Ananta
 * @since  02/2020
 * @description IDRCaseActions is class to handle all the IDR (Internal Dispute Resolution) Actions
 * @group IDR(Internal Dispute Resolution)
 * Note: Since Case Owner is a lookup of either User or Group Salesforce has common object in which only few fields are accessible as found in the link https://skaruz.com/salesforce-how-to-access-owner-custom-fields-in-a-soql-query/
 * So we need to query the Users and update the records accordingly.
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class IDRCaseActions {
  @TestVisible
  private static final string DAY_5_ESCALATION_REASON = 'Day 5 auto escalation';

  private static final String ESCALATED_TO_CRC_API_NAME = '1';

  private static final String CRC_QUEUE_DEVELOPER_NAME = 'CRC_Team';

  public static final String QUEUE_TYPE = 'Queue';

  private static final String DELETE_ERROR = 'You cannot delete cases';

  private static final String CUSTOMER_NUMBER_VALIDATION_ERROR = 'This field can no longer be edited. In the event that the Customer Number/Identifier is incorrect, the case must be withdrawn and a new case created with the correct Customer Number.';

  private static final String CANNOT_CLOSE_CASE_WITH_PENDING_TASK_ERROR = 'You cannot close the case as there is currently an open \'Pend Case\' task. Please review and action the open \'Pend Case\' task before closing the case.';

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

  /**
   * @description applyDefaults is called onBeforeInsert to set the following values as defaults
   * @param records The record list form which we need to apply defaults
   */
  public static void applyDefaults(List<Case> records) {
    Id entitlementId = getEntitlement();
    Case[] updatePsiTicked = new List<Case>();
    for (Case record : records) {
      if (isIDRComplaintType(record)) {
        record.EntitlementId = entitlementId;
        record.IDR_Milestone_Sla__c = IDRConstants.MILESTONE_SLA_NORMAL;
        populateSuppliedEmail(record, null);
        updateKnowledgeKeyWordCaseFields(records, null);
        IDRCollectionActions.populateCollectionNumber(record);
        CommonUtil.handleMasking(
          record,
          null,
          SObjectType.Case.FieldSets.IDR_Masked_Fields.getFields()
        );
        handleAnonymousNames(record);
        handleCaseStatusChanges(record);
        if (((String) record.OwnerId).startsWith(Label.ID_Prefix_User)) {
          caseOwnerIds.add(record.OwnerId);
          changeOfficeCaseList.add(record);
        }
        handleCaseEscalationRules(record, null);
        if (record.IDR_Is_Common__c == 'Yes') {
          updatePsiTicked.add(record);
        }
      }
    }
    handleOfficeAssignment(changeOfficeCaseList);
    IDRCaseAssignmentRules.assignProductFamily(records, null);
    IDRCaseAssignmentRules.assignCases(records, null);
    stampQueueName(records, null);
    //Update Date/Time PSI Ticked if complaint is flagged as PSI
    if (!updatePsiTicked.isEmpty()) {
      updateDateTimePsiTicked(updatePsiTicked);
    }
  }

  /**
   * @description afterInsert(records) After isert IDR actions which
   * @param records
   */
  public static void afterInsert(List<Case> records) {
    for (Case record : records) {
      if (isIDRComplaintType(record)) {
        if (
          !record.IDR_SwitchOff_Customer_Notification__c ||
          (record.IDR_3rdParty_Name__c != null &&
          !record.IDR_SwicthOff_3rd_Party_Notification__c)
        ) {
          notificationCaseList.add(record);
        }
        checkForCRCEscalation(record, null);
      }

      if (record.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID) {
        if (record.Customer_Notification_Consent__c == 'Yes') {
          notificationCaseList.add(record);
        }
      }
    }
    IDRTaskActions.possibleSystemicIssueActions(records, null);
    IDRCollectionActions.stopCollections(records, null);
    IDRCollectionActions.startCollections(records, null);
    IDRComplaintFlagActions.setComplaintsFlag(records, null);
  }

  /**
   * @description beforeUpdate(oldMap, records) method handles before update automations for CMOS complaints. Refer to the doc of each method invoked.
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onBeforeUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @param records from the trigger
   */
  public static void beforeUpdate(Map<Id, SObject> oldMap, List<Case> records) {
    Id entitlementId = getEntitlement();
    Case[] updatePsiTicked = new List<Case>();
    for (Case record : records) {
      if (isIDRComplaintType(record)) {
        Case oldRecord = (case) oldMap.get(record.id);
        if (
          record.RecordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID &&
          oldRecord != null &&
          ((IDRCollectionActions.isCollectionsIssue(
            oldRecord.Type,
            oldRecord.IDR_Subsequent_Issue__c
          ) &&
          !IDRCollectionActions.isCollectionsIssue(
            record.Type,
            record.IDR_Subsequent_Issue__c
          )) ||
          (IDRCollectionActions.isCollectionsIssue(
            oldRecord.IDR_Issue_Type_2__c,
            oldRecord.IDR_Subsequent_Issue_2__c
          ) &&
          !IDRCollectionActions.isCollectionsIssue(
            record.IDR_Issue_Type_2__c,
            record.IDR_Subsequent_Issue_2__c
          )) ||
          (IDRCollectionActions.isCollectionsIssue(
            oldRecord.IDR_Issue_Type_3__c,
            oldRecord.IDR_Subsequent_Issue_3__c
          ) &&
          !IDRCollectionActions.isCollectionsIssue(
            record.IDR_Issue_Type_3__c,
            record.IDR_Subsequent_Issue_3__c
          )))
        ) {
          record.addError(IDRConstants.CANNOT_CHANGE_ISSUE_MESSAGE);
        }
        populateSuppliedEmail(record, oldRecord);
        updateKnowledgeKeyWordCaseFields(records, (Map<Id, Case>) OldMap);
        validateCaseNumber(record, oldRecord);
        IDRCollectionActions.populateCollectionNumber(record);
        IDRCollectionActions.validateAccNumberPattern(record, oldRecord);
        CommonUtil.handleMasking(
          record,
          oldRecord,
          SObjectType.Case.FieldSets.IDR_Masked_Fields.getFields()
        );
        handleAnonymousNames(record);
        handleEntitlementForUpdate(record, oldRecord, entitlementId);
        identifyOwnerChangeRecords(record, (oldRecord).OwnerId);
        if (record.Status != oldRecord.Status) {
          handleCaseStatusChanges(record);
        }
        handleCaseEscalationRules(record, oldRecord);
        if (record.IDR_Is_Common__c != oldRecord.IDR_Is_Common__c) {
          updatePsiTicked.add(record);
        }
      }
    }
    preventCloseStatusOnCaseWithPendingTask(records, (Map<Id, Case>) oldMap);
    //calling handleOfficeAssignment for all case records for which the IDR_Office__c needs to be updated.
    handleOfficeAssignment(changeOfficeCaseList);
    IDRCaseAssignmentRules.assignProductFamily(records, (Map<Id, Case>) oldMap);
    IDRCaseAssignmentRules.assignCases(records, (Map<Id, Case>) oldMap);
    stampQueueName(records, (Map<Id, Case>) oldMap);
    //Update Date/Time PSI Ticked if complaint is flagged as PSI
    if (!updatePsiTicked.isEmpty()) {
      updateDateTimePsiTicked(updatePsiTicked);
    }
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
    for (Case record : records) {
      Case oldRec = (Case) oldMap.get(record.id);
      if (
        (oldRec.RecordTypeId == IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID &&
        isIDRComplaintType(record))
      ) {
        notificationCaseList.add(record);
        checkForCRCEscalation(record, oldRec);
      }
    }
    IDRCaseNotificationManager.notifyBankersForEscalation(records, oldMap);
    IDRTaskActions.possibleSystemicIssueActions(records, oldMap);
    IDRTaskActions.updateIDRMilestoneTask(records, oldMap);
    IDRCollectionActions.stopCollections(records, oldMap);
    IDRCollectionActions.startCollections(records, oldMap);
    IDRComplaintFlagActions.setComplaintsFlag(records, oldMap);
    completeMilestone(records, oldMap);
  }

  /**
   * @description Complete the CMOS Complaints Milestone when case is escalated or closed
   * @param records from the trigger
   * @param oldMap previous values of cases in current context of trigger
   */
  public static void completeMilestone(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    Set<Id> escalationCases = new Set<Id>();
    Set<Id> maxTimeFrameCases = new Set<Id>();
    for (Case c : records) {
      if (isIDRComplaintType(c)) {
        Case oldCase = (oldMap.containsKey(c.Id))
          ? (Case) oldMap.get(c.Id)
          : null;
        if (
          (oldCase != null &&
          ((oldCase.Status != IDRConstants.ESCALATED_STATUS &&
          c.Status == IDRConstants.ESCALATED_STATUS) ||
          (oldCase.IDR_Milestone_Sla__c != 'Completed') &&
          c.IDR_Milestone_Sla__c == 'Completed'))
        ) {
          escalationCases.add(c.Id);
        }
        if (
          (oldCase != null &&
          (!oldCase.isClosed &&
          (c.isClosed || c.Status == IDRConstants.PROVISIONALLY_CLOSED_STATUS)))
        ) {
          maxTimeFrameCases.add(c.Id);
        }
      }
    }

    if (!escalationCases.isEmpty()) {
      MilestoneUtils.completeMilestones(
        escalationCases,
        new List<String>{
          'Open_Escalation_Time',
          'FPR 5 Business Day Resolution target'
        },
        System.now()
      );
    }

    if (!maxTimeFrameCases.isEmpty()) {
      MilestoneUtils.completeMilestones(
        maxTimeFrameCases,
        new List<String>{
          '21-day IDR Response Due',
          '30-day IDR Response Due',
          'Open_Escalation_Time',
          'AFCA Response Due',
          'FPR 5 Business Day Resolution target'
        },
        System.now()
      );
      IDRTaskActions.closeMaxTimeFrameTasks(maxTimeFrameCases);
    }
  }

  /**
   * @description Prepopulate Case Fields
   * @param record case record
   * @param oldCase Old copy of case record before this transaction intiated
   */
  private static void populateSuppliedEmail(Case record, Case oldCase) {
    if (
      oldCase == null ||
      (String.IsBlank(oldCase.IDR_NC_Email__c) &&
      String.IsNotBlank(record.IDR_NC_Email__c))
    ) {
      record.SuppliedEmail = record.IDR_NC_Email__c;
    }
  }

  /**
   * @description Check if this case record needs to be assigned to a CRP workbasket
   * @param record case record
   * @param oldRec old case record from trigger
   */
  private static void checkForCRCEscalation(Case record, Case oldRec) {
    if (
      record.Status == IDRConstants.ESCALATED_STATUS &&
      (oldRec == null ||
      oldRec.Status != IDRConstants.ESCALATED_STATUS)
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
    notificationCaseList.clear();
    caseEscalationList.clear();
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
        record.recordTypeId == IDRConstants.SI_RT_ID
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

    if (!queueIds.isEmpty()) {
      Map<Id, Group> queueMap = new Map<Id, Group>(
        [SELECT id, Name FROM Group WHERE Id IN :queueIds]
      );

      for (Case c : caseList) {
        if (queueMap.containsKey(c.OwnerId)) {
          c.Queue__c = queueMap.get(c.OwnerId).Name;
        }
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
      record.RecordTypeId == IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID &&
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
   * @description  handleCaseEscalationRules method is used to handle the case escalations.
   * @param record The actual case record from the trigger
   * @param oldRec trigger context variable to check on old values.
   */
  private static void handleCaseEscalationRules(Case record, Case oldRec) {
    if (
      record.IsEscalated &&
      record.Status != IDRConstants.ESCALATED_STATUS &&
      String.isBlank(record.IDR_Escalation_Reason__c)
    ) {
      // set default values for auto escalated cases: Status, Escalated To, Escalation Reason
      record.Status = IDRConstants.ESCALATED_STATUS;
      if (
        oldRec != null &&
        (oldRec.Status == IDRConstants.UNDER_INVESTIGATION_STATUS ||
        oldRec.Status == IDRConstants.OPEN_STATUS)
      ) {
        record.IDR_Escalation_Reason__c = DAY_5_ESCALATION_REASON;
      }
    }
    if (
      record.Status == IDRConstants.ESCALATED_STATUS &&
      String.isBlank(record.IDR_Escalated_to__c)
    ) {
      record.IDR_Escalated_to__c = ESCALATED_TO_CRC_API_NAME;
    }
  }

  /**
   * @description  handleCaseStatusChanges method is used to handle the case status changes as follows
   * 1. when a case is escalated mark the case's IsEscalated value to true and
   * 2. when a case is reopened mark the IDR_Date_Re_Opened__c as current date.
   * 3. When an escalated case is closed, mark the case's IsEscalated value to false
   * @param record The actual case record from the trigger
   */
  private static void handleCaseStatusChanges(Case record) {
    if (record.Status == IDRConstants.ESCALATED_STATUS && !record.IsEscalated) {
      record.IsEscalated = true;
    }
    if (record.Status == IDRConstants.REOPENED_STATUS) {
      record.IDR_Date_Re_Opened__c = System.today();
      record.IsEscalated = false;
    }
    if (
      (record.Status == IDRConstants.CLOSED_STATUS ||
      record.Status == IDRConstants.PROVISIONALLY_CLOSED_STATUS) &&
      record.IsEscalated
    ) {
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
      (record.Status == IDRConstants.UNDER_INVESTIGATION_STATUS ||
      record.Status == IDRConstants.OPEN_STATUS)
    ) {
      record.IDR_Milestone_Sla__c = getMilestoneSla(
        record.Status,
        record.IDR_Date_Received__c,
        record.BusinessHoursId
      );
    }

    // if the date received has been updated , this information needs to flow on to SlaStartDate field. for the entitlments to work as expected.
    if (record.IDR_Date_Received__c != oldRec.IDR_Date_Received__c) {
      record.SlaStartDate = record.IDR_Date_Received__c;
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
      (caseStatus == IDRConstants.UNDER_INVESTIGATION_STATUS &&
      duration.intValue() < 72) ||
      (caseStatus == IDRConstants.OPEN_STATUS &&
      duration.intValue() < 24)
    ) {
      milestoneSla = IDRConstants.MILESTONE_SLA_NORMAL;
    } else if (
      (caseStatus == IDRConstants.UNDER_INVESTIGATION_STATUS &&
      duration.intValue() >= 72 &&
      duration.intValue() < 96) ||
      (caseStatus == IDRConstants.OPEN_STATUS &&
      duration.intValue() >= 24 &&
      duration.intValue() < 48)
    ) {
      milestoneSla = IDRConstants.MILESTONE_SLA_AMBER;
    } else if (
      (caseStatus == IDRConstants.UNDER_INVESTIGATION_STATUS &&
      duration.intValue() >= 96 &&
      duration.intValue() < 120) ||
      (caseStatus == IDRConstants.OPEN_STATUS &&
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
   * @return Id  - the Id of the entitlment record
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
   * @description On escalation, we prefer passing the developer name of the queue the case is assigned to, instead of its label.
   * Label could change in the future and it'd break Mulesoft mapping to CFMS' workbasket.
   * @param cases Cases to get the queues's names from
   * @return a map with queue ids as keys and queue records as values
   */
  private static Map<Id, Group> getQueuesToEscalate(Case[] cases) {
    Group[] queues = new List<Group>();
    if (Group.sObjectType.getDescribe().isQueryable()) {
      Set<Id> queueIds = new Set<Id>();
      for (Case c : cases) {
        if (String.valueOf(c.OwnerId).startsWith('00G')) {
          queueIds.add(c.OwnerId);
        }
      }
      queues = [SELECT DeveloperName FROM Group WHERE Id IN :queueIds];
    }
    return new Map<Id, Group>(queues);
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
      record.RecordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID ||
      record.RecordTypeId == IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
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
   * @description  This method is used to restrict users from editing case number based on certain conditions
   * @param record The actual case record from the trigger
   * @param oldRec trigger context variable to check on old values.
   */
  private static void validateCaseNumber(Case record, Case oldRec) {
    if (
      record.RecordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID &&
      (record.IDR_Customer_Number__c != oldRec.IDR_Customer_Number__c ||
      record.IDR_Customer_Identifier__c != oldRec.IDR_Customer_Identifier__c) &&
      oldRec.RecordTypeId != IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID &&
      oldRec.RecordTypeId != GetHelpConstants.COMPLAINT_RT_ID
    ) {
      record.addError(CUSTOMER_NUMBER_VALIDATION_ERROR);
    }
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

  /**
   * @description Prevents a complaints case moving to Closed status when it has any non-complete complaints task with 'Pending Case' type
   * @param records  List of cases from the trigger
   * @param oldMap Map of pre-update cases supplied from the trigger as well
   */
  private static void preventCloseStatusOnCaseWithPendingTask(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> closedComplaintCases = new List<Case>();
    for (Case c : records) {
      if (
        (c.Status == IDRConstants.CLOSED_STATUS) &&
        oldMap.get(c.Id).Status != c.Status &&
        isIDRComplaintType(c)
      ) {
        closedComplaintCases.add(c);
      }
    }
    if (!closedComplaintCases.isEmpty()) {
      List<Task> openpendingtasks = [
        SELECT Id, WhatId
        FROM Task
        WHERE
          WhatId = :closedComplaintCases
          AND RecordTypeId = :IDRConstants.IDR_TASK_RT_ID
          AND Status != 'Completed'
          AND Type = 'Pend Case'
        WITH SECURITY_ENFORCED
      ];

      Map<Id, Task> caseTaskMap = new Map<Id, Task>();
      for (Task t : openpendingtasks) {
        caseTaskMap.put(t.WhatId, t);
      }

      for (Case c : closedComplaintCases) {
        if (caseTaskMap.containskey(c.id)) {
          c.addError(CANNOT_CLOSE_CASE_WITH_PENDING_TASK_ERROR);
        }
      }
    }
  }
  /**
   * @description Updates both Knowledge Keyword fields if the fields they are tracking has changed. The Knowledge keyword fields are there to help recommend the correct Knowledge articles for CMOS
   * @param records  List of cases from the trigger
   * @param oldMap Map of pre-update cases supplied from the trigger as well, will be null on beforeInsert
   */
  private static void updateKnowledgeKeyWordCaseFields(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Map<String, String> issueTypeMap = new Map<String, String>();
    Map<String, String> subsequentIssueTypeMap = new Map<String, String>();
    Schema.DescribeFieldResult field = Case.Type.getDescribe();
    for (Schema.PicklistEntry f : field.getPicklistValues()) {
      issueTypeMap.put(f.getValue(), f.getLabel());
    }
    field = Case.IDR_Subsequent_Issue__c.getDescribe();
    for (Schema.PicklistEntry f : field.getPicklistValues()) {
      subsequentIssueTypeMap.put(f.getValue(), f.getLabel());
    }

    for (Case c : records) {
      if (
        oldMap == null ||
        c.IDR_Knowledge_Keyword_1__c == null ||
        (c.IDR_Issue_Type_2__c != oldMap.get(c.Id).IDR_Issue_Type_2__c ||
        c.IDR_Subsequent_Issue_2__c !=
        oldMap.get(c.Id).IDR_Subsequent_Issue_2__c)
      ) {
        c.IDR_Knowledge_Keyword_1__c =
          issueTypeMap.get(c.IDR_Issue_Type_2__c) +
          ' ' +
          subsequentIssueTypeMap.get(c.IDR_Subsequent_Issue_2__c);
      }
      if (
        oldMap == null ||
        c.IDR_Knowledge_Keyword_2__c == null ||
        (c.IDR_Issue_Type_3__c != oldMap.get(c.Id).IDR_Issue_Type_3__c ||
        c.IDR_Subsequent_Issue_3__c !=
        oldMap.get(c.Id).IDR_Subsequent_Issue_3__c)
      ) {
        c.IDR_Knowledge_Keyword_2__c =
          issueTypeMap.get(c.IDR_Issue_Type_3__c) +
          ' ' +
          subsequentIssueTypeMap.get(c.IDR_Subsequent_Issue_3__c);
      }
    }
  }
}
