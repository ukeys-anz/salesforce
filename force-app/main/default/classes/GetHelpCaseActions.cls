/**
 *
 * @author Boobalakrishnan Duraisamy
 * @since 04/2020
 * @description GetHelpCaseActions class is to handle all the Get Help Case Actions
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 * StdCyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings(
  'PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.ExcessivePublicCount'
)
public with sharing class GetHelpCaseActions {
  public static final String DUPLICATE_DISPUTE_ERROR = 'Error occurred while creating dispute. An open dispute already exists for this transaction. Case number: ';
  public static final String DUPLICATE_KYCQA_ERROR = 'Error occurred while creating KYC QA Case. A KYC QA Case already exists for this customer. Case number: ';

  private static Map<String, String> caseTypeLabelByValue = new Map<String, String>();

  private static Map<String, String> caseSubtypeLabelByValue = new Map<String, String>();

  private static List<Case> notificationCaseList = new List<Case>();

  public static final String MISALIGNED_FINANCIAL_ACCOUNT_ERROR = 'Error occurred while create dispute.  There is a misalignment between customer\'s OCV ID and Financial Account';

  public static final String SLA_BREACH = 'Breached';
  public static final String SLA_WARNING = 'Warning';
  public static final String SLA_BREACH_NOTIFICATION_BODY = 'Please review and ensure case is being managed by Customer Resolution Centre.';
  public static final String SLA_WARNING_NOTIFICATION_BODY = 'Please review and action this case.';

  public static Group accountClosureQueue = CommonUtil.getQueueByName(
    'Account_Closure_Queue'
  );
  public static Group cobFraudCheckQueue = CommonUtil.getQueueByName(
    'COB_Fraud_Check_Queue'
  );

  /**
   * @description beforeUpdate(oldMap, records) method handles the following
   * 1. Validate Additional Type - Validates the selected additional types and addError if it has more than 2 values selected or if the Type value is same as one of the additional values
   * 2. Handle Populate Case Subject- Check the case type and populate its subject accordingly.
   * 3. Validate Parent Case - Validates the case record and throws an error if the record is having child cases
   * 4. Complete milestones - updates the milestone to closed when the case status is updated to clsoed
   * 5. Automatically assign dispute cases to relevant queues
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onBeforeUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @param records from the trigger
   */
  public static void beforeUpdate(Map<Id, SObject> oldMap, List<Case> records) {
    List<Id> caseIds = new List<Id>();
    List<Case> validateCaseList = new List<Case>();
    Set<Id> milestoneCaseIds = new Set<Id>();

    for (Case record : (List<Case>) records) {
      Case oldRecord = (Case) oldMap.get(record.id);
      if (
        oldRecord.Status != GetHelpConstants.CLOSED_STATUS &&
        record.Status == GetHelpConstants.CLOSED_STATUS
      ) {
        updateCaseDurationTime(record);
      }

      if (record.RecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID) {
        if (
          String.isNotBlank(record.ParentId) &&
          record.ParentId != oldRecord.ParentId
        ) {
          caseIds.add(record.id);
          validateCaseList.add(record);
        }
      } else if (CheckCaseRecordType.isDispute(record)) {
        // Reset case SLA Status on Dispute cases to blank/none when switching case status.
        // This would aid notifications based on SLA_Status__c to work correctly;
        //    * when "Resolution Time" mielstone resulted in a SLA Status change before entering "Investigation Time" milestone
        //    * if/when the same case enters "Investigation Time" milestone more than once
        if (oldRecord.Status != record.Status) {
          record.SLA_Status__c = '';
        }

        //Checks if card token number needs to be deleted
        GetHelpCaseActionsHelper.handleCardTokenNumber(record);
      } else if (record.RecordTypeId == GetHelpConstants.KYCQA_RT_ID) {
        if (
          ((oldRecord != null &&
          oldRecord.Sub_Status__c !=
          GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT) || oldRecord == null) &&
          record.Sub_Status__c == GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT
        ) {
          GetHelpCaseActionsHelper.populateKYCQACaseClosedNoDefectDefaults(
            record
          );
        }
      } else if (
        CheckCaseRecordType.isAccountClosure(record, null) &&
        record.Status == GetHelpConstants.ESCALATED_STATUS &&
        oldRecord.Status != GetHelpConstants.ESCALATED_STATUS
      ) {
        //Set owner of case to account closure queue if its set to escalated
        record.OwnerId = accountClosureQueue.Id;
      } else if (CheckCaseRecordType.isANZPlusComplaint(record)) {
        GetHelpCaseActionsHelper.handleEntitlementForUpdate(record, oldRecord);
      }
    }

    handlePopulateCaseSubject((List<Case>) records, (Map<Id, Case>) oldMap);
    CaseChangeRecordTypeController.recordTypeChangeValidation(
      (List<Case>) records,
      (Map<Id, Case>) oldMap
    );
    validateAdditionalTypes((List<Case>) records, (Map<Id, Case>) oldMap);

    if (!caseIds.isEmpty()) {
      GetHelpCaseActionsHelper.validateParentCase(caseIds, validateCaseList);
    }

    MilestoneHandler.updateMilestone(
      (Map<Id, Case>) oldMap,
      (List<Case>) records
    );
    GetHelpCaseAssignmentRules.assignDisputeCases(
      records,
      (Map<Id, Case>) oldMap
    );
  }

  /**
   * @description validate the selected additional types
   * @param caseList The case list to validate the additional types on
   * @param oldCaseMap old case map
   */
  public static void validateAdditionalTypes(
    List<Case> caseList,
    Map<Id, Case> oldCaseMap
  ) {
    List<Case> additionalTypeCheckCases = new List<Case>();
    for (Case record : caseList) {
      if (
        GetHelpCaseActionsHelper.isEnquiryOrAdditionalCheckRequired(
          record,
          oldCaseMap
        )
      ) {
        additionalTypeCheckCases.add(record);
      }
    }
    GetHelpCaseActionsHelper.checkAdditionalTypes(additionalTypeCheckCases);
  }

  /**
   * @description  This method validates Case Type and Additional Type to populate Case Subject.
   * @param caseList list of cases from the trigger
   * @param oldCaseMap old case map
   */
  public static void handlePopulateCaseSubject(
    List<Case> caseList,
    Map<Id, Case> oldCaseMap
  ) {
    List<Case> accountClosureCases = new List<Case>();
    Set<Id> accountIds = new Set<Id>();
    for (Case record : caseList) {
      Case oldRecord = oldCaseMap != null ? oldCaseMap.get(record.Id) : null;
      // Check for General Inquiry Cases
      if (
        GetHelpCaseActionsHelper.isEnquiryOrAdditionalCheckRequired(
          record,
          oldCaseMap
        )
      ) {
        populateGeneralEnquiryCaseSubject(record);
      }

      // Check for Fraud Cases
      // Note: We are excluding the possibility of 'Type' being empty, because we only care about data entered via UI (required field) or controlled entries via API, both of which should have values for 'Type'
      if (CheckCaseRecordType.isFraud(record, oldRecord)) {
        populateFraudCaseSubject(record);
      }

      // Check for Dispute Cases
      if (CheckCaseRecordType.isDispute(record)) {
        populateDisputeCaseSubject(record);
      }

      // Check for Complaint Cases
      if (CheckCaseRecordType.isComplaint(record, oldRecord)) {
        populateComplaintCaseSubject(record);
      }

      // Check for ANZx Non Customer Complaint Cases
      if (CheckCaseRecordType.isANZxNonCustomerComplaint(record, oldCaseMap)) {
        populateANZxNonCustomerComplaintCaseSubject(record);
      }

      // Check for Account Closure Cases
      if (CheckCaseRecordType.isAccountClosure(record, oldRecord)) {
        accountClosureCases.add(record);
        accountIds.add(record.AccountId);
      }
    }

    if (!accountClosureCases.isEmpty()) {
      if (PermissionUtils.canQuery('Account')) {
        Map<Id, Account> accountList = new Map<Id, Account>(
          [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );
        populateAccountClosureCaseSubject(accountClosureCases, accountList);
      }
    }
  }

  /**
   * @description  This method populates Case subject based on Case type and additional type values
   * @param record Case record from trigger
   */
  public static void populateGeneralEnquiryCaseSubject(Case record) {
    List<String> caseTypeList = new List<String>();

    if (String.isNotBlank(record.Type)) {
      fetchCaseTypeLabelsByValues();
      caseTypeList.add(caseTypeLabelByValue.get(record.Type));
    }
    if (String.isNotBlank(record.Sub_Type__c)) {
      fetchCaseSubtypeLabelsByValues();
      for (String subTypeValue : record.Sub_Type__c.split(';')) {
        caseTypeList.add(caseSubtypeLabelByValue.get(subTypeValue));
      }
    }
    //populate case subject
    if (!caseTypeList.isEmpty()) {
      record.Subject = String.join(caseTypeList, ' - ');
    }
  }

  /**
   * @description  This method populates subject on Fraud cases based on Record Type and Type
   * @param record Case record from trigger
   */
  public static void populateFraudCaseSubject(Case record) {
    if (String.isNotBlank(record.Type)) {
      fetchCaseTypeLabelsByValues();
      // Setting a different Subject format for KYC QA Cases
      if (record.RecordTypeId == GetHelpConstants.KYCQA_RT_ID) {
        record.Subject = caseTypeLabelByValue.get(record.Type);
      } else {
        record.Subject =
          Schema.getGlobalDescribe()
            .get('Case')
            .getDescribe()
            .getRecordTypeInfosById()
            .get(record.RecordTypeId)
            .getName() +
          ' - ' +
          caseTypeLabelByValue.get(record.Type);
      }
    }
  }

  /**
   * @description  This method populates the subject of Dispute cases based on Record Type and Dispute Reason
   * @param record Case record from trigger
   */
  public static void populateDisputeCaseSubject(Case record) {
    // For dispute cases, subject will be text comprising "<Record Type Name> - <Dispute Reason>
    if (String.isNotBlank(record.Dispute_Reason__c)) {
      record.Subject =
        Schema.getGlobalDescribe()
          .get('Case')
          .getDescribe()
          .getRecordTypeInfosById()
          .get(record.RecordTypeId)
          .getName() +
        ' - ' +
        record.Dispute_Reason__c;
    }
  }

  /**
   * @description  This method populates complaint Case subject based on Case record type and issue values
   * @param record Case record from trigger
   */
  public static void populateComplaintCaseSubject(Case record) {
    String typeLabel = CommonUtil.getSinglePicklistLabel(
      Case.Type,
      record.Type
    );
    record.Subject = 'ANZ Plus Complaint - ' + typeLabel;
  }

  /**
   * @description  This method populates ANZx Non Customer Complaint Case subject based on Case record type
   * @param record Case record from trigger
   */
  public static void populateANZxNonCustomerComplaintCaseSubject(Case record) {
    String typeLabel = CommonUtil.getSinglePicklistLabel(
      Case.Type,
      record.Type
    );
    record.Subject = 'Non-Customer Complaint - ' + typeLabel;
  }

  /**
   * @description Fetches (if not already available) a map of Case 'Type' Picklist Labels by Values
   */
  public static void fetchCaseTypeLabelsByValues() {
    if (caseTypeLabelByValue.isEmpty()) {
      caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(Case.Type);
    }
  }

  /**
   * @description Fetches (if not already available) a map of Case 'Sub_Type__c' Picklist Labels by Values
   */
  public static void fetchCaseSubtypeLabelsByValues() {
    if (caseSubtypeLabelByValue.isEmpty()) {
      caseSubtypeLabelByValue = CommonUtil.getPicklistLabelsByValues(
        Case.Sub_Type__c
      );
    }
  }

  /**
   * @description Sets default values on Priority based on different Case record types
   * @param caseList list of cases from the trigger
   */
  public static void setPriority(List<Case> caseList) {
    for (Case c : caseList) {
      c.IDR_Correspondence_Reviewed_Date__c = Date.Today();
      if (
        (c.RecordTypeId == GetHelpConstants.DIRECT_DEBIT_DISPUTE_RT_ID ||
        c.RecordTypeId == GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID) &&
        c.Effective_Date__c != null
      ) {
        if (System.Today().isSameDay(c.Effective_Date__c)) {
          c.Priority = 'High';
        } else {
          Datetime currentDate = System.Today();
          Datetime previousWorkingDay = DateTimeUtils.substractBusinessDays(
            c.BusinessHoursId,
            currentDate,
            1
          );
          if (
            previousWorkingDay.isSameDay(c.Effective_Date__c) &&
            (Datetime.now().hour() <= 15 &&
            Datetime.now().minute() <= 30)
          ) {
            c.Priority = 'High';
          }
        }
      }
    }
  }

  /**
   * @description This method updates the entitlement field on the case
   * if the case is of General Inquiry, ANZX Complaint, or any of the Dispute record types
   * @param caseList list of cases from the trigger
   */
  public static void updateEntitlement(List<Case> caseList) {
    List<Id> accountIds = new List<Id>();
    Map<Id, Id> entMap = new Map<Id, Id>();

    accountIds = GetHelpCaseActionsHelper.getEntitlementAccountIds(caseList);

    if (Entitlement.sObjectType.getDescribe().isQueryable()) {
      List<Entitlement> entList;
      entList = GetHelpCaseActionsHelper.getEntitlements(
        accountIds,
        'Basic Subscription'
      );

      for (Entitlement en : entList) {
        entMap.put(en.AccountId, en.Id);
      }
    }

    GetHelpCaseActionsHelper.updateEntitlementIdOnCase(caseList, entMap);
  }

  /**
   * @description This method updates the entitlement field on the case
   * if the case is converted from AEM to General Inquiry/ANZX Complaint/Non-Cusotmer Complaint
   * @param oldMap old trigger case map<id, case>
   * @param caseList list of cases from the trigger
   */
  public static void updateEntitlementOnConvertedCase(
    Map<Id, Case> oldMap,
    List<Case> caseList
  ) {
    List<Case> filteredCases = GetHelpCaseActionsHelper.filterAEMConvertedCases(
      oldMap,
      caseList
    );
    if (filteredCases.size() == 0) {
      return;
    }

    List<Id> accountIds = new List<Id>();
    Map<Id, Id> entMap = new Map<Id, Id>();

    accountIds = GetHelpCaseActionsHelper.getEntitlementAccountIds(
      filteredCases
    );

    if (Entitlement.sObjectType.getDescribe().isQueryable()) {
      List<Entitlement> entList;
      entList = GetHelpCaseActionsHelper.getEntitlements(
        accountIds,
        'Basic Subscription'
      );

      for (Entitlement en : entList) {
        entMap.put(en.AccountId, en.Id);
      }
    }

    GetHelpCaseActionsHelper.updateEntitlementIdOnCase(caseList, entMap);
  }

  /**
   * @description future method to recalculate in a deletion scenario, because if done in before delete, the rollup will be wrong. does not check record type, do this before calling
   * @param bugIdSet set of salesforce bug id's to recalculate
   */
  @future
  public static void futureRollupRelatedBug(Set<Id> bugIdSet) {
    List<Reported_Bug__c> bugs = new List<Reported_Bug__c>();
    if (
      Reported_Bug__c.SObjectType.getDescribe().isAccessible() &&
      Reported_Bug__c.SObjectType.getDescribe().isUpdateable()
    ) {
      bugs = GetHelpCaseActionsHelper.getReportedBugs(bugIdSet);
    }

    for (Reported_Bug__c bug : bugs) {
      bug.Number_of_Related_Cases__c = bug.Cases__r.size();
    }
    if (!bugs.isEmpty()) {
      List<Database.SaveResult> results = Database.Update(bugs, false);

      Logger.error('', results);
      Logger.saveLog();
    }
  }

  /**
   * @description This method updates the case duration hours field for EA for further usage
   * when the case status is updated to closed
   * @param record case from the trigger
   */
  public static void updateCaseDurationTime(Case record) {
    CaseDurationObject.DurationTime durationTime = CaseDurationService.getCaseDurationTime(
      record.Id
    );
    record.Case_Hour_Duration__c = durationTime.dHours.setScale(
      2,
      RoundingMode.HALF_UP
    );
  }

  /**
   * @description This method updates the case business hours field
   * to be ANZ Plus specific
   * @param record the record we are updating
   */
  private static void setBusinessHours(Case record) {
    if (BusinessHours.SObjectType.getDescribe().isAccessible()) {
      BusinessHours bhs = CommonUtil.getBusinessHours();
      record.BusinessHoursId = bhs.Id;
    }
  }

  /**
   * @description This method masks case notes and description of issue fields
   * to be ANZ Plus specific
   * @param record the record we are updating
   */
  public static void maskTaxNumbers(Case record) {
    record.Description = TextUtils.maskDataAnzx(record.Description);
    record.Comments = TextUtils.maskDataAnzx(record.Comments);
    if (
      TextUtils.reactiveLogging(record.Description) ||
      TextUtils.reactiveLogging(record.Comments)
    ) {
      Logger.info(
        'CaseNumber: ' +
        record.CaseNumber +
        '; Description: ' +
        record.Description +
        '; Notes: ' +
        record.Comments +
        '; Reason for logging: User entered long digits without needing to mask'
      );
      Logger.saveLog();
    }
  }

  /**
   * @description Escalates the Record to CMOS IDR Everyday Banking Queue
   * @param records The record list to which we escalate
   */
  public static void beforeUpdateCaseToCMOS(List<Case> records) {
    CaseEscalateToCMOS.beforeUpdateCaseToCMOS(records);
  }

  /**
   * @description applyDefaults is called onBeforeInsert to set the following values as defaults
   * 1. Update business hours field to match ANZ Plus business hours
   * 2. Mask description and comments fields if it contains sensitive information
   * 3. Automatically assign dispute cases to relevant queues
   * @param records The record list form which we need to apply defaults
   */
  public static void applyDefaults(List<Case> records) {
    for (Case record : records) {
      if (CheckCaseRecordType.isANZPlusCaseType(record)) {
        setBusinessHours(record);
        maskTaxNumbers(record);
      }
    }
    GetHelpCaseAssignmentRules.setTransactionStatus(records);
    GetHelpCaseAssignmentRules.assignDisputeCases(records, null);
    GetHelpCaseActionsHelper.setANZxCustomerNonCustomerComplaints(records);
    GetHelpCaseAssignmentRules.assignUnauthenticatedEnquiryCases(records);
  }

  /**
   * @description checkOpenDisputeOnTransaction is called onBeforeInsert to check if there is already an open dispute for a particular transaction, if so,
   * throw an exception to prevent a duplicate dispute from being created
   * @param records a list of cases
   */
  public static void checkOpenDisputeOnTransaction(List<Case> records) {
    Set<String> transactionIds = new Set<String>();
    List<Case> disputeCases = new List<Case>();
    for (Case c : records) {
      if (
        String.isNotBlank(c.Transaction_Id__c) &&
        CheckCaseRecordType.isDispute(c)
      ) {
        transactionIds.add(c.Transaction_Id__c);
        disputeCases.add(c);
      }
    }
    Map<String, String> caseNumberByTransactionId = GetHelpCaseActionsHelper.getCaseNumberByTransactionId(
      transactionIds
    );
    for (Case c : disputeCases) {
      String caseNumber = caseNumberByTransactionId.get(c.Transaction_Id__c);
      if (caseNumber != null) {
        c.addError(DUPLICATE_DISPUTE_ERROR + caseNumber);
      }
    }
  }

  /**
   * @description Check if the provided financial account is ACTIVE and linked to the provided customer account
   * @param records The list of cases whose financial accounts need to be validated
   */
  public static void validateFinancialAccByAccId(List<Case> records) {
    Map<Integer, Case> caseByIndexMap = new Map<Integer, Case>();
    Map<Integer, String> combinedKeyByCaseIndexMap = new Map<Integer, String>();
    Set<Id> customerAccountIdSet = new Set<Id>();
    Set<Id> financialAccountIdSet = new Set<Id>();
    for (Integer i = 0; i < records.size(); i++) {
      Case record = records[i];
      if (
        record.AccountId != null &&
        record.FinServ__FinancialAccount__c != null
      ) {
        caseByIndexMap.put(i, record); // Get a map of each case by its index
        combinedKeyByCaseIndexMap.put(
          i,
          String.valueOf(record.FinServ__FinancialAccount__c) +
          String.valueOf(record.AccountId) // Get a map of each case's combined key (financial account Id + customer account Id) by the case's index
        );
        customerAccountIdSet.add(record.AccountId);
        financialAccountIdSet.add(record.FinServ__FinancialAccount__c);
      }
    }

    Map<Id, FinServ__FinancialAccountRole__c> financialAccRolesByIdMap = GetHelpCaseActionsHelper.getFinancialAccountRolesMap(
      customerAccountIdSet,
      financialAccountIdSet,
      true
    ); // Get a list of ACTIVE financial account roles which are linked to the provided customer accounts and financial accounts

    Map<String, FinServ__FinancialAccountRole__c> roleByCombinedKeyMap = new Map<String, FinServ__FinancialAccountRole__c>();
    for (
      FinServ__FinancialAccountRole__c record : financialAccRolesByIdMap.values()
    ) {
      // Loop through the list of ACTIVE financial account roles, get a map of each role and its combined key (financial account Id + customer account Id)
      roleByCombinedKeyMap.put(
        String.valueOf(record.FinServ__FinancialAccount__c) +
        String.valueOf(record.FinServ__RelatedAccount__c),
        record
      );
    }

    for (Integer caseIndex : combinedKeyByCaseIndexMap.keySet()) {
      if (
        !roleByCombinedKeyMap.containsKey(
          combinedKeyByCaseIndexMap.get(caseIndex)
        )
      ) {
        // If an active financial role does not exist for a case's combined key, aka this case does not have an ACTIVE financial role between its customer account and financial account
        caseByIndexMap.get(caseIndex)
          .addError(MISALIGNED_FINANCIAL_ACCOUNT_ERROR); // The case will not be created
      }
    }
  }

  /**
   * @description handle SLA related notifications
   * @param records New record instances to process
   * @param oldMap Map of the old values of the records to process
   */
  public static void handleSLANotifications(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    if (!oldMap.isEmpty()) {
      CustomNotificationType type = CommonUtil.getCustomNotificationTypeByName(
        'Case_SLA'
      );

      for (Case newCase : records) {
        if (
          newCase.SLA_Status__c != null &&
          !newCase.SLA_Status__c.Equals(oldMap.get(newCase.Id).SLA_Status__c)
        ) {
          String messageBody = '';

          if (newCase.SLA_Status__c == SLA_WARNING) {
            messageBody = SLA_WARNING_NOTIFICATION_BODY;
          } else if (newCase.SLA_Status__c == SLA_BREACH) {
            messageBody = SLA_BREACH_NOTIFICATION_BODY;
          }

          if (!String.isBlank(messageBody)) {
            String messageTitle =
              'SLA status for ' +
              Schema.getGlobalDescribe()
                .get('Case')
                .getDescribe()
                .getRecordTypeInfosById()
                .get(newCase.RecordTypeId)
                .getName() +
              ' ' +
              newCase.CaseNumber +
              ' has changed to ' +
              newCase.SLA_Status__c;

            InAppNotificationWrapper notificationWrapper = new InAppNotificationWrapper(
              type.Id,
              newCase.Id,
              newCase.OwnerId,
              messageTitle,
              messageBody
            );

            CommonUtil.sendInAppNotification(notificationWrapper);
          }
        }
      }
    }
  }

  /**
   * @description A list of platform events that test class can access for assertion purpose
   */
  @TestVisible
  private static List<sObject> pegaPEList;
  /**
   * @description Check if a case should be sent to PEGA, these includes
   * submitted disputes with record types: Card, NPP, ATM. If yes, generate a platform event.
   * @param records New record instances to process
   * @param oldMap Map of the old values of the records to process
   */
  public static void handleDisputesPEGAIntegration(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> casesToProcess = new List<Case>();
    if (Trigger.isAfter && Trigger.isUpdate) {
      // Process cases for AFTER UPDATE
      for (Case c : records) {
        if (
          c.Submitted__c != oldMap.get(c.Id).Submitted__c &&
          GetHelpCaseActionsHelper.isValidPegaDispute(c)
        ) {
          casesToProcess.add(c);
        }
      }
    } else {
      // Process cases for AFTER INSERT
      for (Case c : records) {
        if (GetHelpCaseActionsHelper.isValidPegaDispute(c)) {
          casesToProcess.add(c);
        }
      }
    }

    if (casesToProcess.size() > 0) {
      // Get a list of platform events
      List<sObject> peList = GetHelpCaseActionsHelper.buildPegaPlatformEvents(
        casesToProcess
      );
      pegaPEList = peList;

      // Publish platform events
      if (peList.size() > 0) {
        PlatformEventUtils.publishEvents(peList);
      }
    }
  }

  /**
   * @description populate ocv id field on case if the record type is an
   * ANZx complaint
   * @param records List of cases
   */
  public static void populateOCVOnComplaint(List<Case> records) {
    List<Id> accountIds = new List<Id>();

    //Loop through case to create list of account ids
    for (Case c : records) {
      if (
        c.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID &&
        !String.isBlank(c.AccountId)
      ) {
        accountIds.add(c.AccountId);
      }
    }

    //Get map of account ocv ids
    Map<Id, Account> accountList = new Map<Id, Account>(
      [SELECT Id, OCV_ID__c FROM Account WHERE Id IN :accountIds]
    );

    //Loop through cases again and assign ocv id
    if (!accountList.isEmpty() && PermissionUtils.canQuery('Account')) {
      for (Case c : records) {
        c.OCV_Id__c = accountList.get(c.AccountId).OCV_ID__c;
      }
    }
  }

  /**
   * @description afterUpdate(oldMap, records) method handles validating the case status and add them into notification list.
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @param records from the trigger
   */

  public static void afterUpdate(Map<Id, SObject> oldMap, List<Case> records) {
    for (Case record : records) {
      Case oldRec = (Case) oldMap.get(record.Id);
      if (
        CheckCaseRecordType.isAEM(oldRec) &&
        CheckCaseRecordType.isANZPlusComplaint(record)
      ) {
        notificationCaseList.add(record);
      }
    }
  }

  /**
   * @description completeAfterActions() is called post onAfterUpdate
   */
  public static void completeAfterActions() {
    CheckRecursive.run();
    NotificationTriggerHandler.insertNotificationHandler(notificationCaseList);
    notificationCaseList.clear();
  }

  /**
   * @description populate default fields on KYC QA cases if the status is Closed and Sub Status is No Defect
   * @param records List of cases
   */
  public static void populateKYCQACasesClosedNoDefectDefaults(
    List<Case> records
  ) {
    for (Case record : records) {
      if (
        record.RecordTypeId == GetHelpConstants.KYCQA_RT_ID &&
        record.Sub_Status__c == GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT
      ) {
        GetHelpCaseActionsHelper.populateKYCQACaseClosedNoDefectDefaults(
          record
        );
      }
    }
  }

  /**
   * @description Prevent Duplicate KYC QA Against a Customer (Account)
   * @param theCases List of cases
   */
  public static void validateDuplicateKYCQACasePerAccount(List<Case> theCases) {
    Map<Id, Case> accountIdAndCaseMap = new Map<Id, Case>();
    for (Case theCase : theCases) {
      if (theCase.RecordTypeId == GetHelpConstants.KYCQA_RT_ID) {
        accountIdAndCaseMap.put(theCase.AccountId, theCase);
      }
    }
    if (
      Schema.sObjectType.Case.isQueryable() && accountIdAndCaseMap.size() > 0
    ) {
      List<Case> existingKYCQACases = [
        SELECT Id, CaseNumber, AccountId
        FROM Case
        WHERE
          RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
          AND AccountId IN :accountIdAndCaseMap.keySet()
      ];
      for (Case existingKYCQACase : existingKYCQACases) {
        Case theCase = accountIdAndCaseMap.get(existingKYCQACase.AccountId);
        theCase.addError(DUPLICATE_KYCQA_ERROR + existingKYCQACase.CaseNumber);
      }
    }
  }

  /**
   * @description  This method populates Account Closure Case subject based on Case record type
   * @param caseList Case records from trigger
   * @param accountList List of accounts for cases
   */
  public static void populateAccountClosureCaseSubject(
    List<Case> caseList,
    Map<Id, Account> accountList
  ) {
    for (Case c : caseList) {
      c.Subject = 'Account Closure - ' + accountList.get(c.AccountId).Name;
    }
  }

  /**
   * @description Creates a Fraud Check case everytime a ID Ops Assists case gets changed to 'Potential Fraud' status
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   */
  public static void createFraudCheckCase(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> fraudCheckCases = new List<Case>();

    for (Case c : records) {
      Case oldC = oldMap.get(c.Id);

      if (
        CheckCaseRecordType.isIDOpsAssistance(c) &&
        c.Status == GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS &&
        oldC?.Status != GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS
      ) {
        Case fraudCheckCase = new Case(
          RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID,
          ParentId = c.Id,
          OwnerId = cobFraudCheckQueue.Id,
          Subject = 'Fraud Check Case',
          CustomerOnboardingApplication__c = c.CustomerOnboardingApplication__c,
          PersonaId__c = c.PersonaId__c
        );

        fraudCheckCase.Status = GetHelpConstants.COB_ID_OPS_TO_FRAUD_CHECK_STATUS_MAP.get(
          oldC?.Status
        );

        fraudCheckCases.add(fraudCheckCase);
      }
    }

    if (!fraudCheckCases.isEmpty()) {
      List<Database.SaveResult> results = Database.insert(
        fraudCheckCases,
        false
      );

      Logger.debug('Results of inserting Fraud Check cases', results);
      Logger.saveLog();
    }
  }

  /**
   * @description Update an ID Ops Assistance case with a corresponding Fraud Check Case Status everytime a Fraud Check case status is updated
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   */
  public static void updateIdOpsCaseStatus(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    //Create a Map of ID Ops case ids (parentId) with the Fraud Check Case status
    Map<Id, Case> parentIdAndChildCasedMap = new Map<Id, Case>();

    for (Case newFraudCheckCase : records) {
      Case oldFraudCheckCase = oldMap.get(newFraudCheckCase.Id);

      //Check if it's a correct record type and the status of the case is changed
      if (
        CheckCaseRecordType.isFraudCheck(newFraudCheckCase) &&
        GetHelpCaseActionsHelper.isStatusChanged(
          newFraudCheckCase,
          oldFraudCheckCase
        )
      ) {
        parentIdAndChildCasedMap.put(
          newFraudCheckCase.ParentId,
          newFraudCheckCase
        );
      }
    }

    List<Case> idOpsCases = GetHelpCaseActionsHelper.setIDOpsCaseStatus(
      parentIdAndChildCasedMap
    );

    DMLUtil.updateRecords(idOpsCases, false, true);
  }

  /**
   * @description create task on case closure
   * @param records Case records from trigger
   * @param oldMap oldMap of the cases
   */
  public static void createTaskOnDisputeCaseClosure(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Task> taskList = new List<Task>();
    Map<Id, Case> mapClosedCases = new Map<Id, Case>();
    List<Case> closedCases = [
      SELECT
        Id,
        AccountId,
        Subject,
        BusinessHoursId,
        LastModifiedBy.Profile.Name,
        IsClosed,
        RecordTypeId,
        Status
      FROM Case
      WHERE Id IN :records
    ];
    for (Case record : closedCases) {
      Case oldCase = oldMap.get(record.Id);
      if (
        GetHelpCaseActionsHelper.CASE_CLOSURE_EMAIL_DISPUTE_RT_IDS.contains(
          record.RecordTypeId
        ) &&
        !record.LastModifiedBy.Profile.Name.endsWith('Standard User') &&
        record.IsClosed &&
        record.Status != oldCase.Status
      ) {
        mapClosedCases.put(record.Id, record);
      }
    }

    if (Schema.sObjectType.External_Case_Status__c.isQueryable()) {
      Map<String, Id> queueMap = IDRCaseAssignmentRules.getAnzxWorkbaskets();
      Id taskOwnerId = queueMap.get(
        GetHelpConstants.CARD_DISPUTE_GENERAL_QUEUE
      );
      for (External_Case_Status__c externalCaseStatus : [
        SELECT Id, External_Status__c, Case__c, Case__r.ContactId
        FROM External_Case_Status__c
        WHERE Case__c IN :mapClosedCases.keySet()
      ]) {
        if (
          externalCaseStatus.External_Status__c == 'Resolved-WriteOff' ||
          externalCaseStatus.External_Status__c == 'Resolved-AcqAccepted' ||
          externalCaseStatus.External_Status__c == 'Resolved-AcquirerLiable' ||
          externalCaseStatus.External_Status__c == 'Resolved-Duplicate' ||
          externalCaseStatus.External_Status__c == 'Resolved-PreArbAccepted' ||
          externalCaseStatus.External_Status__c == 'Resolved-PreArbGranted'
        ) {
          taskList.add(
            GetHelpCaseActionsHelper.createTask(
              mapClosedCases.get(externalCaseStatus.Case__c),
              externalCaseStatus,
              taskOwnerId
            )
          );
        }
      }
    }
    if (!taskList.isEmpty()) {
      DMLUtil.insertRecords(taskList, false, true);
    }
  }
}
