/**
 * @author Victor Wang
 * @since 08/2021
 * @description QualityAssessmentActions class is to handle Quality Assessment process actions
 */
public with sharing class QualityAssessmentActions {
  public static final String STATUS_UNASSIGNED = 'Unassigned';
  public static final String STATUS_REFERRED = 'Referred';
  public static final String SUB_STATUS_COMPLIANCE_REVIEW = 'Compliance Review';

  private static final List<Id> DISPUTE_CASE_RT_IDS = new List<Id>{
    GetHelpConstants.GENERAL_INQUIRY_RT_ID,
    GetHelpConstants.ATM_DISPUTE_RT_ID,
    GetHelpConstants.CARD_DISPUTE_RT_ID,
    GetHelpConstants.DIRECT_DEBIT_DISPUTE_RT_ID,
    GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
    GetHelpConstants.COMPLAINT_RT_ID
  };

  private static final List<String> ANZX_CASE_CLOSED_STATUS = new List<String>{
    GetHelpConstants.CLOSED_STATUS,
    GetHelpConstants.RESOLVED_STATUS,
    GetHelpConstants.WITHDRAWN_STATUS,
    GetHelpConstants.CLOSED_STATUS_EDUCATED,
    GetHelpConstants.CLOSED_STATUS_FUTURE_RELEASE,
    GetHelpConstants.CLOSED_STATUS_RESOLVED,
    GetHelpConstants.CLOSED_STATUS_NO_FIX
  };

  /**
   * @description create quality assessment record with related cases, if a case's status was not closed but now is closed
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   */
  public static void createQualityAssessmentWithRelatedCase(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> qaQualifiedCases = getQAQualifiedCases(records, oldMap);

    List<Quality_Assessment__c> newGeneralQARecords = initNewGeneralQARecords(
      qaQualifiedCases
    );

    List<Case> casesToUpdate = QualityAssessmentCaseActions.setCaseClosedOnce(
      qaQualifiedCases
    );

    insertGeneralQARecords(newGeneralQARecords);

    QualityAssessmentCaseActions.updateCaseClosedOnce(casesToUpdate);
  }

  /**
   * @description filter out a list of cases that are closed and eligible to invoke QA creation
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   * @return List<Case>
   */
  private static List<Case> getQAQualifiedCases(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> qaQualifiedCases = new List<Case>();

    for (Case record : records) {
      if (oldMap == null) {
        if (isCaseClosed(record)) {
          qaQualifiedCases.add(record);
        }
      } else {
        Case oldRecord = oldMap.get(record.id);

        if (isCaseClosed(record, oldRecord)) {
          qaQualifiedCases.add(record);
        }
      }
    }

    return qaQualifiedCases;
  }

  /**
   * @description method to decide is a Case is Close when Created
   * @param record Case record
   * @return Boolean
   */
  private static Boolean isCaseClosed(Case record) {
    return ANZX_CASE_CLOSED_STATUS.contains(record.Status) &&
      isDisputeCaseType(record) &&
      !QualityAssessmentCaseActions.isCaseClosedOnce(record);
  }

  /**
   * @description method to decide is a Case is changed to closed
   * @param record Case record
   * @param oldRecord old version of Case record
   * @return Boolean
   */
  private static Boolean isCaseClosed(Case record, Case oldRecord) {
    return !ANZX_CASE_CLOSED_STATUS.contains(oldRecord.Status) &&
      isCaseClosed(record);
  }

  /**
   * @description bulk create general QA records for qualified cases
   * @param qaQualifiedCases case records that have desired status or status change
   * @return List<Quality_Assessment__c> a list of new init General record type Quality Assessment records
   */
  @testVisible
  private static List<Quality_Assessment__c> initNewGeneralQARecords(
    List<Case> qaQualifiedCases
  ) {
    List<Quality_Assessment__c> qualityAssessments = new List<Quality_Assessment__c>();

    for (Case record : qaQualifiedCases) {
      Quality_Assessment__c qa = new Quality_Assessment__c(
        Related_Case__c = record.Id,
        RecordTypeId = GetHelpConstants.QUALITY_ASSESSMENT_GENERAL_RT_ID
      );

      qualityAssessments.add(qa);
    }

    return qualityAssessments;
  }

  /**
   * @description method to insert General type QA records
   * @param records quality assessment records to insert
   */
  private static void insertGeneralQARecords(
    List<Quality_Assessment__c> records
  ) {
    if (records == null || records.size() == 0) {
      return;
    }

    List<Database.SaveResult> results = Database.insert(records, false);

    //log errors to application log
    lib_systemLog log = new lib_systemLog(
      'QualityAssessmentActions',
      'insertGeneralQARecords'
    );

    log.addDatabaseSaveResult('Quality_Assessment__c', results, records);

    log.insertLogAsync();
  }

  /**
   * @description method to determine if a Case is a Dispute case, not CMOS case, if Dispute case, add this case to qaQualifiedCases List
   * @param record case record to determine
   * @return Boolean
   */
  @testVisible
  private static Boolean isDisputeCaseType(Case record) {
    return DISPUTE_CASE_RT_IDS.contains(record.RecordTypeId);
  }

  /**
   * @description populate fields on quality assessment record
   * @param records
   */
  public static void populateFields(List<Quality_Assessment__c> records) {
    List<Quality_Assessment__c> qaRecordsWithRelatedCase = new List<Quality_Assessment__c>();

    for (Quality_Assessment__c record : records) {
      if (String.isNotBlank(record.Related_Case__c)) {
        qaRecordsWithRelatedCase.add(record);
      }
    }

    List<Quality_Assessment__c> recordsToUpdate = assignRelatedCaseFieldsToQA(
      qaRecordsWithRelatedCase
    );

    SystemModeActions actions = new SystemModeActions(
      'QualityAssessmentActions',
      'populateFields'
    );
    actions.updateRecords(recordsToUpdate, 'Quality_Assessment__c');
  }

  /**
   * @description assigne related case fields to quality assessment record
   * @param qaRecordsWithRelatedCase a list of Quality_Assessment__c with Related_Case__c
   * @return List<Quality_Assessment__c> a list of Quality_Assessment__c with pre-populated fields from Related_Case__c
   */
  @testVisible
  private static List<Quality_Assessment__c> assignRelatedCaseFieldsToQA(
    List<Quality_Assessment__c> qaRecordsWithRelatedCase
  ) {
    if (
      qaRecordsWithRelatedCase == null ||
      qaRecordsWithRelatedCase.size() == 0
    ) {
      return null;
    }

    Map<Id, Quality_Assessment__c> qaMap = new Map<Id, Quality_Assessment__c>(
      qaRecordsWithRelatedCase
    );

    List<Quality_Assessment__c> recordsToUpdate = new List<Quality_Assessment__c>();

    if (Quality_Assessment__c.SObjectType.getDescribe().isAccessible()) {
      for (Quality_Assessment__c record : [
        SELECT
          Id,
          Interaction_Type__c,
          Interaction_Date_Time__c,
          Related_Case__c,
          Related_Case__r.CaseNumber,
          Related_Case__r.Owner.Type,
          Related_Case__r.OwnerId,
          Related_Case__r.Origin,
          Related_Case__r.AccountId,
          Related_Case__r.ClosedDate,
          toLabel(Related_Case__r.Type),
          toLabel(Related_Case__r.IDR_Subsequent_Issue__c)
        FROM Quality_Assessment__c
        WHERE Id IN :qaMap.keySet()
      ]) {
        calculateAndAssignFieldsToQA(record);
        recordsToUpdate.add(record);
      }
    }

    return recordsToUpdate;
  }

  /**
   * @description method to assign field value to a Quality Assessment record
   * @param record quality assessment record
   */
  @testVisible
  private static void calculateAndAssignFieldsToQA(
    Quality_Assessment__c record
  ) {
    record.Issue_Type__c = record.Related_Case__r?.Type;
    record.Subsequent_Issue_Type__c = record.Related_Case__r
      ?.IDR_Subsequent_Issue__c;
    record.Customer__c = record.Related_Case__r?.AccountId;
    record.Interaction_Date_Time__c = record.Related_Case__r?.ClosedDate;
    record.Interaction_Owner__c = record.Related_Case__r?.Owner.Type == 'User'
      ? record.Related_Case__r.OwnerId
      : null;
    if (String.isBlank(record.Interaction_Type__c)) {
      String interactionType = calculateInteractionType(
        record.Related_Case__r?.Origin
      );
      record.Interaction_Type__c = interactionType;
    }
  }

  /**
   * @description method to calculate Interaction Type based on Related Case origin value
   * @param caseOrigin related case origin
   * @return String Interaction Type
   */
  @testVisible
  private static String calculateInteractionType(String caseOrigin) {
    switch on caseOrigin {
      when 'Chat' {
        return 'Chat';
      }
      when 'Voice Call', 'Phone' {
        return 'Voice Call';
      }
      when 'Video Call' {
        return 'Video Call';
      }
      when 'Email', 'Secure Mail' {
        return 'Email';
      }
      when 'anz.com' {
        return 'Website';
      }
      when 'Store' {
        return 'Store';
      }
      when null, '' {
        return null;
      }
      when else {
        return 'Other';
      }
    }
  }

  /**
   * @description method to assign owner to Queue.
   * @param records quality assessment records to update
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onAfterUpdate. Example to check if the Case Status value has changed we use the following to check record.Status != ((Case) oldMap.get(record.id)).Status
   */
  public static void assignToQueue(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<String> queueNameList = new List<String>{
      'Quality_Assessor',
      'Coach_Lead_Escalation'
    };

    Map<String, Group> queueMap = new Map<String, Group>();

    if (Group.SObjectType.getDescribe().isAccessible()) {
      for (Group q : [
        SELECT Id, DeveloperName
        FROM Group
        WHERE type = 'Queue' AND DeveloperName IN :queueNameList
      ]) {
        queueMap.put(q.DeveloperName, q);
      }
    }

    for (Quality_Assessment__c record : records) {
      if (oldMap != null) {
        Quality_Assessment__c oldRecord = oldMap.get(record.id);
        if (
          oldRecord.Sub_Status__c != 'Compliance Review' &&
          record.Sub_Status__c == 'Compliance Review'
        ) {
          record.OwnerId = queueMap.get('Coach_Lead_Escalation').Id;
        }
      } else {
        if (
          record.Status__c == 'Referred' &&
          record.Sub_Status__c == 'Compliance Review'
        ) {
          record.OwnerId = queueMap.get('Coach_Lead_Escalation').Id;
        } else {
          record.OwnerId = queueMap.get('Quality_Assessor').Id;
        }
      }
    }
  }
}
