/**
 * @author Pavan Kumar Ananta
 * @since  02/2020
 * @description IDRCaseActions is class to handle all the IDR (Internal Dispute Resolution) Actions
 * Note: Since Case Owner is a lookup of either User or Group Salesforce has common object in which only few fields are accessible as found in the link https://skaruz.com/salesforce-how-to-access-owner-custom-fields-in-a-soql-query/
 * So we need to query the Users and update the records accordingly.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
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

  private static final String OPEN_STATUS = 'Open';
  private static final String UNDER_INVESTIGATION_STATUS = 'Under Investigation';
  private static final String ESCALATED_STATUS = 'Escalated';
  private static final String REOPENED_STATUS = 'Re-opened';
  private static final String CLOSED_STATUS = 'Closed';
  private static final String RESOLVED_STATUS = 'Resolved';
  private static final String WITHDRAWN_STATUS = 'Withdrawn';
  private static final string ESCALATION_REASON = '6';

  // IDR Case Status for which notifications needs to be sent.
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

  private static final String QUEUE_TYPE = 'Queue';

  private static final String DELETE_ERROR = 'You cannot delete cases';

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

  //notificationCaseList list of cases foe which Notifications needs to be sent.
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
   * 1. IDR_Account_Card_Policy_Number__c field masking as part of Customer Complaint Recording in IDR {@link #handleMasking(originalRecord, caseToBeChanged) handleMasking}.
   * 2. Handle anonymous names if complainant doesnt want to share their info. This is for NON ANZ Customer rasing a complaint {@link #handleAnonymousNames(originalRecord, caseToBeChanged) handleAnonymousNames}.
   * 3. Handle case stutus changes such as updating IsEscalated to true if the case is created as escalated case. Change the reopen date if case is created with re-opened status {@link #handleCaseStatusChanges(originalRecord, caseToBeChanged) handleCaseStatusChanges}.
   * 4. Handle office assignment based on the case Owner's Division of the current case. {@link handleOfficeAssignment(cases) handleOfficeAssignment}.
   * @param records The record list form which we need to apply defaults
   * <p>
   * <b>Note:</b> It is always good to change/update values in on onBeforeInsert rather than in onAfterInsert
   * However in situations where the ID or CaseNumber is used which is only generated in onAfterInsert that logic needs to go in onAfterInsert.
   */
  public static void applyDefaults(List<Case> records) {
    for (Case record : records) {
      if (isIDRComplaintType(record)) {
        handleMasking(record, record);
        handleAnonymousNames(record, record);
        handleCaseStatusChanges(record, record);
        if (((String) record.OwnerId).startsWith(Label.ID_Prefix_User)) {
          caseOwnerIds.add(record.OwnerId);
          changeOfficeCaseList.add(record);
        }
      }
    }
    handleOfficeAssignment(changeOfficeCaseList);
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
  }

  /**
   * @description afterUpdate(oldMap, records, caseToBeChanged) method handles the following
   * 1. Handle Masking - IDR_Account_Card_Policy_Number__c field masking as part of Customer Complaint Recording in IDR {@link #handleMasking(originalRecord, caseToBeChanged) handleMasking}.
   * 2. Handle anonymous names if complainant doesnt want to share their info. This is for NON ANZ Customer rasing a complaint {@link #handleAnonymousNames(originalRecord, caseToBeChanged) handleAnonymousNames}.
   * 3. Identify records for which owner is changed for IDR_Office__c to be updated. Note we need to update only the records for which the owner has changed and the owner is User(not Group).
   * 4. Handle case stutus changes only for records which had a status change. Actions such as updating IsEscalated to true if the case is created as escalated case. Change the reopen date if case is created with re-opened status {@link #handleCaseStatusChanges(originalRecord, caseToBeChanged) handleCaseStatusChanges}.
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @param records The original record list
   * @param caseToBeChanged The record list that needs to be changed
   */
  public static void afterUpdate(
    Map<Id, SObject> oldMap,
    List<Case> records,
    List<Case> caseToBeChanged
  ) {
    for (Integer i = 0; i < caseToBeChanged.size(); i++) {
      if (isIDRComplaintType(records.get(i))) {
        handleMasking(records.get(i), caseToBeChanged.get(i));
        handleAnonymousNames(records.get(i), caseToBeChanged.get(i));
        identifyOwnerChangeRecords(
          records.get(i),
          caseToBeChanged.get(i),
          ((Case) oldMap.get(records.get(i).id)).OwnerId
        );
        if (
          records.get(i).Status != ((Case) oldMap.get(records.get(i).id)).Status
        ) {
          handleCaseStatusChanges(records.get(i), caseToBeChanged.get(i));
          if (NOTIFICATION_STATUS.contains(records.get(i).Status)) {
            notificationCaseList.add(records.get(i));
          }
          checkForCRCEscalation(records.get(i));
        }
        handleCaseEscalationRules(
          records.get(i),
          caseToBeChanged.get(i),
          (case) oldMap.get(records.get(i).id)
        );
      }
      //calling handleOfficeAssignment for all case records for which the IDR_Office__c needs to be updated.
      handleOfficeAssignment(changeOfficeCaseList);
    }
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
    //sendNotifications(notificationCaseList);
    NotificationTriggerHandler.insertNotificationHandler(notificationCaseList);
    escalateToCFMS(caseEscalationList);
    notificationCaseList.clear();
    caseEscalationList.clear();
  }

  /**
   * @description onBeforeDelete of IDR Case records. FOr complaints no user is allowed to delete a complaint.
   * Check if its IDR record type and prevent deleteing for anzx can handle other scenarios
   * @param records
   */
  public static void onBeforeDelete(List<Case> records) {
    for (Case record : records) {
      if (isIDRComplaintType(record)) {
        record.addError(DELETE_ERROR);
      }
    }
  }

  /**
   * @description identifyOwnerChangeRecords checks if the record Owner is User (not Group).
   * It also checks if the owner has changed. We only want to copy the IDR_Office__c if the owner has changed.
   * @param originalRecord The actual case record
   * @param caseToBeUpdated The record that needs to be changed
   * @param  oldOwnerId old owner id to check if it changed
   */
  private static void identifyOwnerChangeRecords(
    Case originalRecord,
    Case caseToBeUpdated,
    String oldOwnerId
  ) {
    if (
      originalRecord.OwnerId.getSobjectType() == User.SobjectType &&
      originalRecord.OwnerId != oldOwnerId
    ) {
      caseOwnerIds.add(originalRecord.OwnerId);
      caseToBeUpdated.OwnerId = originalRecord.OwnerId;
      changeOfficeCaseList.add(caseToBeUpdated);
    }
  }

  /**
   * @description handleAnonymousNames is used to handle when the complainant does not accept the consent and wants to remain anonymous.
   * So we note their name as Anonymous in the case.
   * @param originalRecord The actual case record
   * @param caseToBeChanged The record that needs to be changed
   */
  private static void handleAnonymousNames(
    Case originalRecord,
    Case caseToBeChanged
  ) {
    if (
      originalRecord.RecordTypeId == NON_CUSTOMER_COMPLAINT_RT_ID &&
      originalRecord.IDR_NC_Is_Consent_Obtained__c == false &&
      originalRecord.IDR_NC_First_Name__c != Label.Anonymous_Complainant &&
      originalRecord.IDR_NC_Middle_Names__c != Label.Anonymous_Complainant &&
      originalRecord.IDR_NC_Last_Name__c != Label.Anonymous_Complainant
    ) {
      caseToBeChanged.IDR_NC_First_Name__c = Label.Anonymous_Complainant;
      caseToBeChanged.IDR_NC_Middle_Names__c = Label.Anonymous_Complainant;
      caseToBeChanged.IDR_NC_Last_Name__c = Label.Anonymous_Complainant;
    }
  }

  /**
   * @description handleMasking method is used to mask the Account/Policy number as we dont want to store the account number in SF. So, we mask the number and store only last last 4 digits unmasked.
   * @param originalRecord The actual case record
   * @param caseToBeChanged The record that needs to be changed
   */
  private static void handleMasking(Case originalRecord, Case caseToBeChanged) {
    caseToBeChanged.IDR_Account_Card_Policy_Number__c = TextUtils.maskData(
      originalRecord.IDR_Account_Card_Policy_Number__c
    );
    caseToBeChanged.Description = TextUtils.maskData(
      originalRecord.Description
    );
    caseToBeChanged.IDR_Complainant_Desired_Outcome__c = TextUtils.maskData(
      originalRecord.IDR_Complainant_Desired_Outcome__c
    );
    caseToBeChanged.IDR_Description_of_Outcome__c = TextUtils.maskData(
      originalRecord.IDR_Description_of_Outcome__c
    );
    caseToBeChanged.IDR_Systemic_Issue_Description__c = TextUtils.maskData(
      originalRecord.IDR_Systemic_Issue_Description__c
    );
  }
  /**
   * @description  handleCaseEscalationRules method is used to handle the case escalations
   * 1.First condition check is for auto esclated cases
   * 2.second condition checks for cases created as escalated.
   * 3.third condition checks for cases that have been esclated after create.
   * 4.Fourth condition checks for cases that have a change in 'escalated to' after the case is already escalated.
   * @param originalRecord The actual case record
   * @param caseToBeChanged The record that needs to be changed
   * @param oldRec trigger context variable to check on old values.
   */
  private static void handleCaseEscalationRules(
    Case originalRecord,
    Case caseToBeChanged,
    Case oldRec
  ) {
    if (
      originalRecord.IsEscalated &&
      originalRecord.Status != ESCALATED_STATUS &&
      originalRecord.OwnerId.getSobjectType() == Group.SobjectType &&
      originalRecord.OwnerId == queue.Id
    ) {
      // set default values for auto escalated cases , change status to escalated,
      //assign to CRC queue and send notifcation to CFMS
      caseToBeChanged.IDR_Escalated_to__c = ESCALATED_TO_CRC_API_NAME;
      caseToBeChanged.Status = ESCALATED_STATUS;
      caseTobeChanged.IDR_Escalation_Reason__c = ESCALATION_REASON;
      caseEscalationList.add(originalRecord);
      notificationCaseList.add(originalRecord);
    } else if (
      originalRecord.IsEscalated &&
      originalRecord.Status != ESCALATED_STATUS &&
      !string.isBlank(originalRecord.IDR_Escalation_Reason__c)
    ) {
      // escalated on insert cases , change status to escalated, assign to CRC queue and send notifcation to CFMS
      caseToBeChanged.Status = ESCALATED_STATUS;
      caseTobeChanged.OwnerId = queue.Id;
      caseEscalationList.add(originalRecord);
    } else if (
      originalRecord.IDR_Escalated_to__c == ESCALATED_TO_CRC_API_NAME &&
      originalRecord.OwnerId != queue.Id &&
      originalRecord.Status == ESCALATED_STATUS &&
      oldRec.Status != ESCALATED_STATUS
    ) {
      // Escalated by updating the case , change status to escalated
      caseTobeChanged.OwnerId = queue.Id;
    } else if (
      originalRecord.IDR_Escalated_to__c == ESCALATED_TO_CRC_API_NAME &&
      oldRec.IDR_Escalated_to__c != ESCALATED_TO_CRC_API_NAME &&
      originalRecord.OwnerId != queue.Id &&
      originalRecord.Status == ESCALATED_STATUS
    ) {
      // Escalated to has changed for already escalated case, assign to CRC queue and send notifcation to CFMS
      caseTobeChanged.OwnerId = queue.Id;
      caseEscalationList.add(originalRecord);
    }
  }

  /**
   * @description  handleCaseStatusChanges method is used to handle the case status changes as follows
   * 1. when a case is escalated mark the case's IsEscalated value to true and
   * 2. when a case is reopened mark the IDR_Date_Re_Opened__c as current date.
   * @param originalRecord The actual case record
   * @param caseToBeChanged The record that needs to be changed
   */
  private static void handleCaseStatusChanges(
    Case originalRecord,
    Case caseToBeChanged
  ) {
    if (originalRecord.Status == ESCALATED_STATUS) {
      if (!originalRecord.IsEscalated) {
        caseToBeChanged.IsEscalated = true;
      }
    }
    if (originalRecord.Status == REOPENED_STATUS) {
      caseToBeChanged.IDR_Date_Re_Opened__c = System.today();
      caseToBeChanged.IsEscalated = false;
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
          State__c = IDRCaseActions.getPicklistLabel(
            Case.IDR_NC_State__c,
            c.IDR_NC_State__c
          ),
          Suburb__c = c.IDR_NC_Suburb__c,
          Priority__c = c.Priority,
          Channel_Received__c = IDRCaseActions.getPicklistLabel(
            Case.Origin,
            c.Origin
          ),
          Relationship_To_Complainant__c = c.IDR_3rdParty_Relationship_To_Complainant__c
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
  private static Boolean isIDRComplaintType(Case record) {
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
}