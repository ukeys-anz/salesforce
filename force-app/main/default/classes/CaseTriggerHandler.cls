/**
 * @author Pavan Kumar Ananta
 * @since 02/2020
 * @description  CaseTriggerHandler is the handler class for Case Trigger which extends Lib_TriggerHandler the trigger framework used.
 * We are checking recursion in after update so that update doesnt get called repeatedly for the same transaction.
 * Recursion is checked based on https://help.salesforce.com/articleView?id=000332407&type=1&mode=1
 * Note: Since Case Owner is a lookup of either User or Group Salesforce has common object in which only few fields are accessible as found in the link https://skaruz.com/salesforce-how-to-access-owner-custom-fields-in-a-soql-query/
 * So we need to query the Users and update the records accordingly.
 */

@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class CaseTriggerHandler extends Lib_TriggerHandler {
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

  // IDR Case Status for which notifications needs to be sent.
  //Todo confirm the case status that needs notifications to be sent out for.
  private static final Set<String> NOTIFICATION_STATUS = new Set<String>{
    'Open',
    'Under Investigation',
    'Escalated',
    'Re-opened',
    'Closed',
    'Resolved',
    'Withdrawn'
  };

  //Length of the field IDR_Account_Card_Policy_Number__c which doesn't need to be masked.
  private static final Integer ACCOUNT_UNMASK_LENGTH = 4;

  //Regex to check if the field IDR_Account_Card_Policy_Number__c is digits and atleast 5 digits for masking.
  private static final String REGEX_PATTERN =
    '([^\\d]*\\d){' +
    (ACCOUNT_UNMASK_LENGTH + 1) +
    ',}';

  private Pattern accountPattern = Pattern.compile(REGEX_PATTERN);

  //IDR_Notification_Event__e for sending notifications to Notification Broker based on status.
  @TestVisible
  private static List<IDR_Notification_Event__e> idrNotifications;

  //Case Owner Id's for getting the Division to be copied in IDR_Office__c.
  private static Set<ID> caseOwnerIds = new Set<Id>();

  //changeOfficeCaseList list of cases which needs IDR_Office__c updates.
  //This is held in a seperate list as we dont want to update all the records.
  //We update only the records for which owner has changed and the owner is User.
  private List<Case> changeOfficeCaseList = new List<Case>();

  //notificationCaseList list of cases foe which Notifications needs to be sent.
  //Only the cases if they are new and is one of NOTIFICATION_STATUS statuses
  private List<Case> notificationCaseList = new List<Case>();

  //User Map to get the User Division for IDR_Office__c as we dont want to query everytime
  //We query all the caseOwnerIds for the case records.
  private Map<ID, User> userMap = new Map<Id, User>();

  //updateCaseList is the list of cases that needs to be updated.
  //This is the list which holds all the case records that needs to be updated so we call update once for performace.
  private List<Case> updateCaseList = new List<Case>();

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CaseTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle following actions
   * 1. IDR_Account_Card_Policy_Number__c field masking as part of Customer Complaint Recording in IDR {@link #handleMasking(originalRecord, caseToBeChanged) handleMasking}.
   * 2. Handle anonymous names if complainant doesnt want to share their info. This is for NON ANZ Customer rasing a complaint {@link #handleAnonymousNames(originalRecord, caseToBeChanged) handleAnonymousNames}.
   * 3. Handle case stutus changes such as updating IsEscalated to true if the case is created as escalated case. Change the reopen date if case is created with re-opened status {@link #handleCaseStatusChanges(originalRecord, caseToBeChanged) handleCaseStatusChanges}.
   * 4. Handle office assignment based on the case Owner's Division of the current case. {@link handleOfficeAssignment(cases) handleOfficeAssignment}.
   * <p>
   * <b>Note:</b> It is always good to change/update values in on onBeforeInsert rather than in onAfterInsert
   * However in situations where the ID or CaseNumber is used which is only generated in onAfterInsert that logic needs to go in onAfterInsert.
   */
  public override void onBeforeInsert() {
    for (Case record : (List<Case>) records) {
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
   * @description onAfterInsert to handle the following actions.
   * 1. Send notifications if the cases were created as new, closed or escalated etc directly.
   * 2. Copy CaseNumber to CaseNumber__c for backup and Restore
   * <p>
   * <b>Note:</b> It is important to clear {@link CheckRecursive.#setOfIDs setOfIDs} as we are updating the same object (Case) in onAfterInsert
   * and we don't want the update to interfere with the update DML if it were in same transaction.
   */
  public override void onAfterInsert() {
    for (Case record : (List<Case>) records) {
      Case caseToBeUpdated = new Case(ID = record.ID);
      if (NOTIFICATION_STATUS.contains(record.Status)) {
        notificationCaseList.add(record);
      }
      copyCaseNumber(record, caseToBeUpdated);
      updateCaseList.add(caseToBeUpdated);
    }
    if (
      Case.sObjectType.getDescribe().isUpdateable() && !updateCaseList.isEmpty()
    ) {
      update updateCaseList;
    }
    sendNotifications(notificationCaseList);
    //It is improtant to clear the CheckRecursive Set of Ids here as the onAfterInsert has already updated its records above
    //and shouldn't interfere with the records which are meant for update DML.
    CheckRecursive.setOfIDs.clear();
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions. Following are the actions handled in after update
   * 1. Handle Masking - IDR_Account_Card_Policy_Number__c field masking as part of Customer Complaint Recording in IDR {@link #handleMasking(originalRecord, caseToBeChanged) handleMasking}.
   * 2. Handle anonymous names if complainant doesnt want to share their info. This is for NON ANZ Customer rasing a complaint {@link #handleAnonymousNames(originalRecord, caseToBeChanged) handleAnonymousNames}.
   * 3. Identify records for which owner is changed for IDR_Office__c to be updated. Note we need to update only the records for which the owner has changed and the owner is User(not Group).
   * 4. Handle case stutus changes only for records which had a status change. Actions such as updating IsEscalated to true if the case is created as escalated case. Change the reopen date if case is created with re-opened status {@link #handleCaseStatusChanges(originalRecord, caseToBeChanged) handleCaseStatusChanges}.
   *
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   *
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    for (Case record : (List<Case>) records) {
      if (!CheckRecursive.SetOfIDs.contains(record.Id)) {
        Case caseToBeUpdated = new Case(ID = record.ID);
        if (isIDRComplaintType(record)) {
          handleMasking(record, caseToBeUpdated);
          handleAnonymousNames(record, caseToBeUpdated);
          identifyOwnerChangeRecords(record, caseToBeUpdated);
          if (record.Status != ((Case) oldMap.get(record.id)).Status) {
            handleCaseStatusChanges(record, caseToBeUpdated);
            notificationCaseList.add(record);
          }
        }
        updateCaseList.add(caseToBeUpdated);
        CheckRecursive.setOfIDs.add(record.ID);
      }
    }
    //calling handleOfficeAssignment for all case records for which the IDR_Office__c needs to be updated.
    handleOfficeAssignment(changeOfficeCaseList);
    sendNotifications(notificationCaseList);
    if (
      Case.sObjectType.getDescribe().isUpdateable() && !updateCaseList.isEmpty()
    ) {
      update updateCaseList;
    }
  }

  /**
   * @description identifyOwnerChangeRecords checks if the record Owner is User (not Group).
   * It also checks if the owner has changed. We only want to copy the IDR_Office__c if the owner has changed.
   * @param originalRecord The actual case record
   * @param caseToBeUpdated The record that needs to be changed
   */
  private void identifyOwnerChangeRecords(
    Case originalRecord,
    Case caseToBeUpdated
  ) {
    if (
      ((String) originalRecord.OwnerId).startsWith(Label.ID_Prefix_User) &&
      originalRecord.OwnerId !=
      ((Case) Trigger.oldMap.get(originalRecord.id)).OwnerId
    ) {
      caseOwnerIds.add(originalRecord.OwnerId);
      caseToBeUpdated.OwnerId = originalRecord.OwnerId;
      changeOfficeCaseList.add(caseToBeUpdated);
    }
  }

  /**
   * @description handleAnonymousNames is used to handle when the complainant does not accept the concent and wants to remain anonymous.
   * So we note their name as Anonymous in the case.
   * @param originalRecord The actual case record
   * @param caseToBeChanged The record that needs to be changed
   */
  private void handleAnonymousNames(Case originalRecord, Case caseToBeChanged) {
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
  private void handleMasking(Case originalRecord, Case caseToBeChanged) {
    if (
      String.isNotBlank(originalRecord.IDR_Account_Card_Policy_Number__c) &&
      accountPattern.matcher(originalRecord.IDR_Account_Card_Policy_Number__c)
        .matches()
    ) {
      caseToBeChanged.IDR_Account_Card_Policy_Number__c =
        '*****' +
        originalRecord.IDR_Account_Card_Policy_Number__c.right(
          ACCOUNT_UNMASK_LENGTH
        );
    }
  }

  /**
   * @description  handleCaseStatusChanges method is used to handle the case status changes as follows
   * 1. when a case is escalated mark the case's IsEscalated value to true and
   * 2. when a case is reopened mark the IDR_Date_Re_Opened__c as current date.
   * @param originalRecord The actual case record
   * @param caseToBeChanged The record that needs to be changed
   */
  private void handleCaseStatusChanges(
    Case originalRecord,
    Case caseToBeChanged
  ) {
    if (originalRecord.Status == 'Escalated') {
      caseToBeChanged.IsEscalated = true;
    } else if (originalRecord.Status == 'Re-opened') {
      caseToBeChanged.IDR_Date_Re_Opened__c = System.today();
    }
  }

  /**
   * @description  sendNotifications method is to send out platform events for notifications to customers. Mulesoft subscribes to these notifications and makes Notification Broker API call.
   * @param records The records for which notifications needs to be sent out
   */
  private void sendNotifications(List<Case> records) {
    if (records.isEmpty()) {
      return;
    }
    idrNotifications = new List<IDR_Notification_Event__e>();
    for (Case c : records) {
      idrNotifications.add(
        new IDR_Notification_Event__e(
          AuthorisedEmail__c = c.IDR_3rdParty_Email__c,
          AuthorisedFirstName__c = c.IDR_3rdParty_Name__c,
          AuthorisedMobile__c = c.IDR_3rdParty_Mobile__c,
          CAP_CIS_ID__c = c.IDR_Customer_Number__c,
          Case_ID__c = c.ID,
          Case_Number__c = c.CaseNumber,
          Case_Status__c = c.Status,
          Case_Status_Change_Date__c = System.now(),
          ComplainantEmail__c = c.IDR_NC_Email__c,
          ComplainantFirstName__c = c.IDR_NC_First_Name__c,
          ComplainantMobile__c = c.IDR_NC_Mobile__c,
          EmailFlag__c = true,
          EmailTemplate__c = 'emailTemplate', //Todo change when actual template id is stored and retrieved
          MessageID__c = '' + c.ID + Datetime.now().millisecond(),
          SMSFlag__c = true,
          SMSTemplate__c = 'smstemplate' //Todo change when actual template id is stored and retrieved
        )
      );
    }
    List<Database.SaveResult> results = EventBus.publish(idrNotifications);
    //Todo handle errors if needed.
  }
  /**
   * @description isIDRComplaintType check if record type is of IDR type.
   * As this Trigger will be used across various teams we identify case record based on IDR record Type.
   *
   * @param record The record for which the recordType needs to be checked
   * @return `Boolean` True if the the record type is of IDR type false otherwise.
   */
  private Boolean isIDRComplaintType(Case record) {
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
  private void handleOfficeAssignment(List<Case> cases) {
    if (caseOwnerIds.isEmpty()) {
      return;
    }
    if (userMap.isEmpty() && User.sObjectType.getDescribe().isQueryable()) {
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
   * @description  Copy case Number to Original Case Number(CaseNumber__c) if CaseNumber__c is empty
   * @param originalRecord The actual case record
   * @param caseToBeChanged The record that needs to be changed
   */
  private void copyCaseNumber(Case originalRecord, Case caseToBeChanged) {
    if (String.isBlank(originalRecord.CaseNumber__c)) {
      caseToBeChanged.CaseNumber__c = originalRecord.CaseNumber;
    }
  }
}
