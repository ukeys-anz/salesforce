/**
 * @author Victor Wang
 * @since 08/2021
 * @description QualityAssessmentActions class is to handle Quality Assessment process actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class QualityAssessmentActions {
  public static final String STATUS_UNASSIGNED = 'Unassigned';
  public static final String STATUS_REFERRED = 'Referred';
  public static final String STATUS_IN_PROGRESS = 'In Progress';
  public static final String STATUS_COMPLETE = 'Complete';
  public static final String SUB_STATUS_OTHER = 'Other';
  public static final String SUB_STATUS_COMPLIANCE_REVIEW = 'Compliance Review';
  public static final String SUB_STATUS_EVALUATION_COMPLETED = 'Evaluation Completed';
  public static final String EVALUATION_TYPE_MAPPING_ERROR = 'Please note that the selected evaluation type does not align to the select case or record type. Please review your selection.';
  public static final Map<String, String> CASE_RECORDTYPE_TO_QA_EVALUATION_TYPE = new Map<String, String>{
    'Scam' => 'Fraud & Dispute',
    'Fraud' => 'Fraud & Dispute',
    'Recipient_Mule' => 'Fraud & Dispute',
    'Card_Dispute' => 'Fraud & Dispute',
    'ATM_Dispute' => 'Fraud & Dispute',
    'Identity' => 'Identity & KYC',
    'KYC_QA' => 'Identity & KYC'
  };

  public static final String GROUP_ASSURANCE_TEAM = 'Assurance Team Group';
  public static final String GROUP_COACH_LEAD = 'Coach Lead Group';
  public static final String GROUP_JOIN_LEAD = 'Join Lead Group';
  public static final String CHATTER_FEED_STRING = 'There is a new item for review.';

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
   * @description method to determine if a Case is a Dispute case, not CMOS case, if Dispute case, add this case to qaQualifiedCases List
   * @param record case record to determine
   * @return Boolean
   */
  @testVisible
  private static Boolean isDisputeCaseType(Case record) {
    return DISPUTE_CASE_RT_IDS.contains(record.RecordTypeId);
  }
  /**
   * @description populate fields on before triggers
   * @param records new values
   * @param oldMap old values
   */
  public static void populateFieldsBeforeTrigger(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Set<Id> interactionIds = new Set<Id>();
    for (Quality_Assessment__c record : records) {
      Id oldRelatedInteraction = oldMap?.get(record.id).Interaction__c;
      if (record.Interaction__c != oldRelatedInteraction) {
        interactionIds.add(record.Interaction__c);
      }
    }

    if (interactionIds.size() > 0) {
      Map<Id, Interaction> interations = getInteractions(interactionIds);
      for (Quality_Assessment__c record : records) {
        record.Interaction_Date_Time__c = interations.get(record.Interaction__c)
          ?.CreatedDate;
        record.Lead__c = interations.get(record.Interaction__c)?.Lead__c;
        record.Related_Case__c = interations.get(record.Interaction__c)
          ?.CaseId__c;
        record.Customer__c = interations.get(record.Interaction__c)?.AccountId;
      }
    }
  }
  /**
   * @description populate fields on quality assessment record
   * @param records
   * @param oldMap old value map
   */
  public static void populateFields(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> qaRecordsWithRelatedCase = new List<Quality_Assessment__c>();

    for (Quality_Assessment__c record : records) {
      Id oldRelatedCase = oldMap?.get(record.id).Related_Case__c;
      if (record.Related_Case__c != oldRelatedCase) {
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
          Evaluation_Type__c,
          RecordTypeId,
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
    record.Case_Closure_Date__c = record.Related_Case__r?.ClosedDate;
    if (record.Interaction_Date_Time__c == null) {
      record.Interaction_Date_Time__c = record.Related_Case__r?.ClosedDate;
    }
    record.Interaction_Owner__c = record.Related_Case__r?.Owner.Type == 'User'
      ? record.Related_Case__r.OwnerId
      : null;
    if (String.isBlank(record.Interaction_Type__c)) {
      if (
        record.RecordTypeId != GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID
      ) {
        String interactionType = calculateInteractionType(
          record.Related_Case__r?.Origin
        );
        record.Interaction_Type__c = interactionType;
      }
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
        }
      }
    }
  }

  /**
   * @description validate the record before saving
   * @param records quality assessment records in trigger new
   */
  public static void validateEvaluationType(
    List<Quality_Assessment__c> records
  ) {
    //validate evaluation type for fraud case
    List<Id> caseIds = new List<Id>();
    List<Quality_Assessment__c> qaHasRelatedCase = new List<Quality_Assessment__c>();

    for (Quality_Assessment__c qa : records) {
      if (
        qa.Related_Case__c != null &&
        qa.RecordTypeId == GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID
      ) {
        caseIds.add(qa.Related_Case__c);
        qaHasRelatedCase.add(qa);
      }
    }
    if (!caseIds.isEmpty() && Case.SObjectType.getDescribe().isAccessible()) {
      List<Case> relatedCases = [
        SELECT RecordType.DeveloperName
        FROM Case
        WHERE Id IN :caseIds
      ];
      for (Quality_Assessment__c qa : qaHasRelatedCase) {
        for (Case c : relatedCases) {
          String evaluationType = CASE_RECORDTYPE_TO_QA_EVALUATION_TYPE.get(
            c.RecordType.DeveloperName
          );
          if (
            qa.Related_Case__c == c.Id &&
            qa.Evaluation_Type__c != evaluationType &&
            evaluationType != null
          ) {
            qa.addError(EVALUATION_TYPE_MAPPING_ERROR);
          }
        }
      }
    }
  }

  /**
   * @description method to create sharing record
   * @param records quality assessment records to update
   * @param oldMap map hold old value in trigger context
   */
  public static void createQAShareRecord(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    List<Quality_Assessment__c> qaToCreateSharingRecord = new List<Quality_Assessment__c>();
    for (Quality_Assessment__c qa : records) {
      if (oldMap != null) {
        Quality_Assessment__c oldRecord = oldMap.get(qa.id);
        //share evaluation completed QA with interaction owner
        if (
          qa.Interaction_Owner__c != null &&
          oldRecord.Sub_Status__c != 'Evaluation Completed' &&
          qa.Sub_Status__c == 'Evaluation Completed'
        ) {
          qaToCreateSharingRecord.add(qa);
        }
      }
    }
    if (!qaToCreateSharingRecord.isEmpty()) {
      List<Quality_Assessment__Share> qaShareRecords = new List<Quality_Assessment__Share>();
      for (Quality_Assessment__c qa : qaToCreateSharingRecord) {
        Quality_Assessment__Share newQAShare = new Quality_Assessment__Share(
          AccessLevel = 'Read',
          ParentId = qa.Id,
          UserOrGroupId = qa.Interaction_Owner__c
        );
        qaShareRecords.add(newQAShare);
      }
      try {
        if (
          Quality_Assessment__Share.SObjectType.getDescribe().isCreateable()
        ) {
          insert qaShareRecords;
        }
      } catch (Exception e) {
        lib_systemLog log = new lib_systemLog(
          CommonUtil.class.getName(),
          'createQAShareRecord'
        );
        log.error(
          'Error creating Quality Assessment Sharing Record: ',
          e.getMessage()
        );
        log.publishEvent();
      }
    }
  }
  /**
   * @description update related case after QA is inserted or updated
   * @param records quality assessment records to update
   * @param oldMap map hold old value in trigger context
   */
  public static void updateRelatedCases(
    List<Quality_Assessment__c> records,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Set<Id> caseIds = new Set<Id>();
    List<Case> casesToUpdate = new List<Case>();

    for (Quality_Assessment__c qa : records) {
      if (oldMap != null) {
        Quality_Assessment__c oldRecord = oldMap.get(qa.id);
        if (
          qa.Related_Case__c != null &&
          qa.Related_Case__c != oldRecord.Related_Case__c
        ) {
          caseIds.add(qa.Related_Case__c);
        }
      } else if (qa.Related_Case__c != null) {
        caseIds.add(qa.Related_Case__c);
      }
    }
    if (caseIds.isEmpty()) {
      return;
    }
    for (Id caseId : caseIds) {
      Case caseToUpdate = new Case(Id = caseId, Has_Assessment__c = true);
      casesToUpdate.add(caseToUpdate);
    }
    SystemModeActions actions = new SystemModeActions(
      'QualityAssessmentActions',
      'populateFields'
    );
    actions.updateRecords(casesToUpdate, 'Case');
  }
  /**
   * @description create chatter post when QA meet certain criterias
   * @param qaRecords quality assessment records to update
   * @param oldMap map hold old value in trigger context
   */
  public static void createChatterPost(
    List<Quality_Assessment__c> qaRecords,
    Map<Id, Quality_Assessment__c> oldMap
  ) {
    Map<String, Id> groupsByName = getCollaborationGroup();
    Id joinGroupId = groupsByName.get(GROUP_JOIN_LEAD);
    Id coachLeadGroupId = groupsByName.get(GROUP_COACH_LEAD);
    Id assuranceTeamGroupId = groupsByName.get(GROUP_ASSURANCE_TEAM);

    for (Quality_Assessment__c qa : qaRecords) {
      String oldSubstatus = oldMap?.get(qa.id).Sub_Status__c;
      if (qa.Sub_Status__c == oldSubstatus) {
        continue;
      }

      String mentionGroups;
      if (
        qa.RecordTypeId == GetHelpConstants.QUALITY_ASSESSMENT_JOIN_RT_ID &&
        (qa.Sub_Status__c == SUB_STATUS_OTHER ||
        qa.Sub_Status__c == SUB_STATUS_COMPLIANCE_REVIEW)
      ) {
        mentionGroups = '{' + joinGroupId + '}';
      } else if (
        qa.RecordTypeId == GetHelpConstants.QUALITY_ASSESSMENT_GETHELP_RT_ID
      ) {
        if (qa.Sub_Status__c == SUB_STATUS_OTHER) {
          mentionGroups = '{' + coachLeadGroupId + '}';
        }
        if (qa.Sub_Status__c == SUB_STATUS_COMPLIANCE_REVIEW) {
          mentionGroups =
            '{' +
            coachLeadGroupId +
            '}, ' +
            '{' +
            assuranceTeamGroupId +
            '}';
        }
      }
      if (mentionGroups != null) {
        ConnectApi.FeedElement fe = ConnectApiHelper.postFeedItemWithMentions(
          null,
          qa.Id,
          CHATTER_FEED_STRING +
          '   ' +
          mentionGroups
        );
      }
    }
  }
  /**
   * @description get chatter groups
   * @return  `Map<String, Id>` return chatter group in a map
   */
  public static Map<String, Id> getCollaborationGroup() {
    Map<String, Id> groupsByName = new Map<String, Id>();
    if (CollaborationGroup.SObjectType.getDescribe().isQueryable()) {
      for (CollaborationGroup gp : [SELECT Id, Name FROM CollaborationGroup]) {
        groupsByName.put(gp.Name, gp.Id);
      }
    }
    return groupsByName;
  }
  /**
   * @description get related interaction by ids
   * @param interactionIds interaction ids
   * @return  `Map<Id, Interaction>` map of interaction
   */
  public static Map<Id, Interaction> getInteractions(Set<Id> interactionIds) {
    Map<Id, Interaction> interactions = new Map<ID, Interaction>();
    if (Interaction.SObjectType.getDescribe().isQueryable()) {
      interactions = new Map<ID, Interaction>(
        [
          SELECT Id, CreatedDate, Lead__c, CaseId__c, AccountId
          FROM Interaction
          WHERE Id IN :interactionIds
        ]
      );
    }
    return interactions;
  }
}
