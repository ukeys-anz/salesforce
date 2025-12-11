/**
 * @author Sanskriti Routray
 * @since 09/2025
 * @description Action class for Case Management- Signing Auth uplift.
 */
public with sharing class SigningAuthorityUpdateActions {
  private static final String DEFAULT_SUBJECT = 'Signing Authority Update ';
  public static final String CASE_STATUS_UNDER_INVESTIGATION = 'Under Investigation';
  public static final String CASE_SUB_STATUS_FAILED = 'Failed';
  public static final String CASE_SUB_STATUS_PROCESSING = 'Processing';
  public static final String CASE_SUB_STATUS_SUCCESS = 'Success';
  public static final String CASE_STATUS_CLOSED = 'Closed';
  public static final String CASE_STATUS_ESCALATED = 'Escalated';
  private static final String ON_HOLD_CASE_STATUS = 'On Hold';

  private static final SigningAuthorityUpdateRepository SIGN_AUTH_REPO = (SigningAuthorityUpdateRepository) Lib_InstanceProvider.forType(
    SigningAuthorityUpdateRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description populate related Subject on Case records
   * @param records Case records that are inserted/updated
   */
  public static void setSubject(List<Case> records) {
    try {
      Set<Id> accountIds = ListUtil.getIds(
        records,
        Case.FinServ__FinancialAccount__c
      );
      Map<Id, FinServ__FinancialAccount__c> accountRecords = new Map<Id, FinServ__FinancialAccount__c>(
        SIGN_AUTH_REPO.getFinancialAccountsWithCaseId(accountIds)
      );

      for (Case record : records) {
        String subject = DEFAULT_SUBJECT;
        if (accountRecords.containsKey(record.FinServ__FinancialAccount__c)) {
          subject =
            subject +
            '- ' +
            accountRecords.get(record.FinServ__FinancialAccount__c)
              ?.FinServ__FinancialAccountNumber__c;
        }
        record.Subject = subject;
      }
    } catch (Exception exp) {
      for (Case record : records) {
        Logger.error(
          'Error processing Case record: ' + JSON.serialize(record),
          exp
        );
      }
      Logger.saveLog();
    }
  }
  /**
   * @description Remove reference to Financial account if issue type is changed and financial account is populated on Case records.
   * @param records Case records that are inserted/updated
   * @param oldMap old map of Case records
   * @param
   */
  public static void dereferenceFA(List<Case> records, Map<Id, Case> oldMap) {
    List<Case> eligibleRecords = ListUtil.filter(records, oldMap)
      .changed(Case.Type)
      .isNotNull(Case.FinServ__FinancialAccount__c)
      .toList();
    ListUtil.setField(eligibleRecords, Case.FinServ__FinancialAccount__c, null);
  }

  /**
   * @description Update the case status/sub status to Under Investigation/Processing or Failed based on success or failure of callout.
   * @param caseRecordId Case record Id that is updated
   * @param response true or false depending on callout was successful or not
   * @param
   */
  public static void caseStatusUpdate(Id caseRecordId, Boolean response) {
    try {
      Case caseRecord = new Case(Id = caseRecordId);
      caseRecord.Status = CASE_STATUS_UNDER_INVESTIGATION;
      caseRecord.Sub_Status__c = response
        ? CASE_SUB_STATUS_PROCESSING
        : CASE_SUB_STATUS_FAILED;
      DML.doUpdate(caseRecord);
    } catch (Exception exp) {
      Logger.error('SigningAuthorityUpdateActions  ' + exp.getMessage(), exp);
      Logger.saveLog();
    }
  }

  /**
   * @description updates owner of Case to their Manager if SLA Status is breached
   * @param records Case records that are updated
   * @param oldMap old map of Case records
   */
  public static void caseEscalationUpdate(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Set<Id> ownerIds = new Set<Id>();
    List<Case> eligibleRecordsForOwnerUpdate = new List<Case>();
    List<Case> eligibleRecordsForEscalation = ListUtil.filter(records, oldMap)
      .changed(Case.SLA_Status__c)
      .equals(Case.SLA_Status__c, 'Breached')
      .toList();

    ListUtil.setField(
      eligibleRecordsForEscalation,
      Case.Status,
      CASE_STATUS_ESCALATED
    );

    ownerIds = ListUtil.getIds(eligibleRecordsForEscalation, Case.OwnerId);
    Map<Id, User> userDetails = (Map<Id, User>) ListUtil.mapBy(
      SIGN_AUTH_REPO.getManagerInfo(ownerIds),
      User.Id
    );

    eligibleRecordsForOwnerUpdate = ListUtil.filter(
        eligibleRecordsForEscalation
      )
      .equals(Case.OwnerId, userDetails.keySet())
      .toList();

    for (Case caseRecord : eligibleRecordsForOwnerUpdate) {
      User ownerUser = userDetails.get(caseRecord.OwnerId);
      caseRecord.OwnerId = ownerUser.ManagerId;
    }
  }

  /**
   * @description makes a chatter post on successful update of Case record
   * @param records Case records that are updated
   * @param oldMap old map of Case records
   */
  public static void chatterPostOnSuccessfulUpdate(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> eligibleRecordsForEscalation = ListUtil.filter(records)
      .changed(Case.Sub_Status__c)
      .equals(Case.Status, CASE_STATUS_CLOSED)
      .equals(Case.Sub_Status__c, CASE_SUB_STATUS_SUCCESS)
      .toList();

    Map<String, String> issueTypeMap = new Map<String, String>{
      'Change to All to Sign' => 'All to Sign',
      'Change to Any to Sign' => 'Any to Sign'
    };

    for (Case caseRecord : eligibleRecordsForEscalation) {
      ChatterUtils.makeAPost(
        caseRecord.Id,
        'Joint Account Signing Authority changed to "' +
          issueTypeMap.get(caseRecord.Type) +
          '" Case ID: ' +
          caseRecord.CaseNumber,
        ChatterUtils.POST_TYPE_RICH_TEXT
      );
    }
  }

  /**
   * @description close the milestone once status of Case is closed
   * @param records Case records that are updated
   * @param oldMap old map of Case records
   */
  public static void completeMilestone(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> eligibleRecordsForClosure = ListUtil.filter(records, oldMap)
      .changedTo(Case.Status, CASE_STATUS_CLOSED)
      .toList();

    Map<Id, Case> caseMap = new Map<Id, Case>(eligibleRecordsForClosure);

    MilestoneUtils.completeMilestone(
      new List<Id>(caseMap.keySet()),
      CaseGroupCaseConstants.RESOLUTION_TIME_MILESTONE,
      System.now()
    );
  }

  /**
   * @description Get a list of account Ids related to entitlement enabled cases
   * @param caseList a list of cases that we need to get account ids from
   */
  public static void updateEntitlementOnCase(List<Case> caseList) {
    List<Case> eligibleRecords = ListUtil.filter(caseList)
      .isNotNull(Case.AccountId)
      .toList();

    Set<Id> accountIds = ListUtil.getIds(eligibleRecords, Case.AccountId);

    Map<Id, Entitlement> entMap = (Map<Id, Entitlement>) ListUtil.mapBy(
      SIGN_AUTH_REPO.getEntitlements(
        accountIds,
        GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
      ),
      Case.AccountId
    );
    for (Case caseRecord : eligibleRecords) {
      if (entMap.containsKey(caseRecord.AccountId)) {
        caseRecord.EntitlementId = entMap.get(caseRecord.AccountId).Id;
      }
    }
  }

  /**
   * @description Marks the IsStopped field base on Status.
   * @param records Case records from trigger
   * @param oldMap map of records id and old records
   */
  public static void markSLAStatus(List<Case> records, Map<Id, Case> oldMap) {
    List<Case> onHoldCases = ListUtil.filter(records, oldMap)
      .changed(Case.Status)
      .toList();
    for (Case caseRecord : onHoldCases) {
      caseRecord.IsStopped = (caseRecord.Status == ON_HOLD_CASE_STATUS);
    }
  }
}
