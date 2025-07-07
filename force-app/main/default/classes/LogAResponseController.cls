/**
 * @author Ashwin Mohan
 * @since May 2025
 * @description This is controller class for leadLogAResponse Lightning Web Component.
 */
public with sharing class LogAResponseController {
  private static final String TASK_STATUS_NEW = 'Open';
  public static final String TASK_STATUS_COMPLETED = 'Completed';
  private static final String TASK_SUBJECT = 'Customer Meeting';
  private static final String ABN_ACN_STATUS_ACTIVE = 'Active';
  public static final String ABN_ACN_VALIDATION_MESSAGE = 'Capture valid ABN / ACN details';

  private static final LogAResponseRepository LOG_A_RESPONSE_REPO = (LogAResponseRepository) Lib_InstanceProvider.forType(
    LogAResponseRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Fetch the list of DCRM Lead Response Conversation Guide metadata and Lead Stage Automation records
   * @name getLeadResponseGuidanceMapping
   * @param leadId
   * @return String serialized Map<String, List<Response_Type__c>>.
   */
  @AuraEnabled(cacheable=true)
  public static String getLeadResponseGuidanceMapping(String leadId) {
    Lead leadInstance = LOG_A_RESPONSE_REPO.getLeadInstance(leadId);
    // get Load stage automation metadata to get what's next info for the current lead response status
    Map<String, String> mapOfLeadStatusResponseAndNextStep = getResponseStatusAndNextStepMap(
      leadInstance
    );

    // get LeadGuidance class instance values to return to the calling method
    LeadGuidance leadGuidanceInstance = getLeadGuidanceInstance(
      leadInstance,
      mapOfLeadStatusResponseAndNextStep
    );

    return JSON.serialize(leadGuidanceInstance);
  }

  /**
   * @description to get Load stage automation metadata to get what's next info for the current lead response status
   * @name getResponseStatusAndNextStepMap
   * @param leadInstance Instance of lead
   * @return Map<String, String>
   */
  private static Map<String, String> getResponseStatusAndNextStepMap(
    Lead leadInstance
  ) {
    Map<String, String> mapOfLeadStatusResponseAndNextStep = new Map<String, String>();
    List<Lead_Stage_Automation__mdt> leadStageAutMdtByRecType = ListUtil.filter(
        LOG_A_RESPONSE_REPO.getLeadStageAutomationMetadata()
      )
      .equals(
        Lead_Stage_Automation__mdt.Lead_Record_Type__c,
        leadInstance.RecordType.DeveloperName
      )
      .toList();
    Boolean isCreateOppResponseTypeSettingCheckNeeded = (leadInstance.RecordTypeId ==
    RTLead.commercialLead);
    for (Lead_Stage_Automation__mdt iterator : leadStageAutMdtByRecType) {
      String key1 =
        iterator.Response_Status__c +
        iterator.Response_Type_CreateOpportunity__c;
      if (mapOfLeadStatusResponseAndNextStep.containsKey(key1)) {
        continue;
      }
      String createOppRTKey = isCreateOppResponseTypeSettingCheckNeeded
        ? iterator.Response_Type_CreateOpportunity__c ?? 'false'
        : '';
      String key2 = iterator.Response_Status__c + createOppRTKey;
      mapOfLeadStatusResponseAndNextStep.put(
        key2,
        iterator.What_happens_next__c
      );
    }
    return mapOfLeadStatusResponseAndNextStep;
  }

  /**
   * @description to get LeadGuidance class instance values to return to the calling method
   * @name getLeadGuidanceInstance
   * @param leadInstance Instance of lead
   * @param mapOfLeadStatusResponseAndNextStep map of response vs next step
   * @return LeadGuidance
   */
  private static LeadGuidance getLeadGuidanceInstance(
    Lead leadInstance,
    Map<String, String> mapOfLeadStatusResponseAndNextStep
  ) {
    List<DCRM_Lead_Response_Conversation_Guide__mdt> dcrmLeadResponseConversationGuidList = ListUtil.filter(
        LOG_A_RESPONSE_REPO.getLeadResponseConvGuide()
      )
      .equals(
        DCRM_Lead_Response_Conversation_Guide__mdt.Profile__c,
        leadInstance.Owner.Profile.Name
      )
      .toList();

    if (dcrmLeadResponseConversationGuidList.isEmpty()) {
      return new LeadGuidance('', '', mapOfLeadStatusResponseAndNextStep);
    }

    if (dcrmLeadResponseConversationGuidList.size() == 1) {
      return new LeadGuidance(
        dcrmLeadResponseConversationGuidList[0].Campaign_Lead_URL__c,
        dcrmLeadResponseConversationGuidList[0].Conversation_Guide_URL__c,
        mapOfLeadStatusResponseAndNextStep
      );
    }

    List<DCRM_Lead_Response_Conversation_Guide__mdt> filterLeadRespBasedOnRole = ListUtil.filter(
        dcrmLeadResponseConversationGuidList
      )
      .contains(
        DCRM_Lead_Response_Conversation_Guide__mdt.User_Role__c,
        leadInstance.Owner.UserRole.Name
      )
      .toList();
    if (filterLeadRespBasedOnRole.isEmpty()) {
      return new LeadGuidance('', '', mapOfLeadStatusResponseAndNextStep);
    }
    return new LeadGuidance(
      filterLeadRespBasedOnRole[0].Campaign_Lead_URL__c,
      filterLeadRespBasedOnRole[0].Conversation_Guide_URL__c,
      mapOfLeadStatusResponseAndNextStep
    );
  }

  /**
   * @description Fetch the list of Response Status and Outcome Reason dependent picklist..
   * @name responseStatusDependentValues
   * @param leadRecordId
   * @return String serialized Map<String, List<Response_Type__c>>.
   */
  @AuraEnabled(cacheable=true)
  public static String responseStatusDependentValues(String leadRecordId) {
    Map<String, List<Response_Type__c>> responseStatusOutcomeReasonMap = new Map<String, List<Response_Type__c>>();
    CampaignMember campaignMember = LOG_A_RESPONSE_REPO.getCampaignMemberRecord(
      leadRecordId
    );
    if (campaignMember == null) {
      return JSON.serialize(responseStatusOutcomeReasonMap);
    }
    responseStatusOutcomeReasonMap = (Map<String, List<Response_Type__c>>) ListUtil.groupBy(
      LOG_A_RESPONSE_REPO.getResponseTypeRecords(campaignMember.CampaignId),
      Response_Type__c.Response_Status__c
    );
    return JSON.serialize(responseStatusOutcomeReasonMap);
  }

  /**
   * @description Create a Lead Response Task Record.
   * @name createResponseRecord
   * @param leadRespString
   * @return String of New Record Id.
   */
  @AuraEnabled
  public static String createResponseRecord(String leadRespString) {
    try {
      LeadResponseWrapper leadRespWrapper = (LeadResponseWrapper) JSON.deserialize(
        leadRespString,
        LeadResponseWrapper.class
      );
      Lead leadRecord = LOG_A_RESPONSE_REPO.getLeadInstance(
        leadRespWrapper.leadId
      );
      String validationOutcome = validateLeadRecord(
        leadRecord,
        leadRespWrapper
      );
      if (validationOutcome != 'success') {
        return validationOutcome;
      }
      Task leadResponseTask = createTaskRecord(leadRecord, leadRespWrapper);
      Boolean campaignDateExpiry = validateCampaignDateMaxExpiry(
        leadRespWrapper.leadId
      );
      return JSON.serialize(
        new ResponseCapturedDataWrapper(leadResponseTask.Id, campaignDateExpiry)
      );
    } catch (Exception e) {
      Logger.error('Error occured while logging response', e);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Validations before creating Lead response task
   * @param leadRecord record of lead
   * @param leadRespWrapper lead response wrapper
   * @return String output of validation
   */
  private static String validateLeadRecord(
    Lead leadRecord,
    LeadResponseWrapper leadRespWrapper
  ) {
    // Validate Lead before logging response of Referred Status.
    List<Lead_Stage_Automation__mdt> referredLeadMetadata = ListUtil.filter(
        LOG_A_RESPONSE_REPO.getLeadStageAutomationMetadata()
      )
      .equals(Lead_Stage_Automation__mdt.Next_Lead_Status__c, 'Referred')
      .equals(
        Lead_Stage_Automation__mdt.Response_Status__c,
        leadRespWrapper.responseStatus
      )
      .toList();
    if (referredLeadMetadata.isEmpty()) {
      return 'success';
    }
    Boolean isABNValStatusNotActive = (leadRecord.ABN__C != null &&
    leadRecord.ABN_Validation_Status__c != ABN_ACN_STATUS_ACTIVE);
    Boolean isACNValStatusNotActive = (leadRecord.ACN__C != null &&
    leadRecord.ACN_Validation_Status__c != ABN_ACN_STATUS_ACTIVE);
    if (isABNValStatusNotActive || isACNValStatusNotActive) {
      return JSON.serialize('Error Message: ' + ABN_ACN_VALIDATION_MESSAGE);
    }
    return 'success';
  }

  /**
   * @description This method is used to create a log response task
   * @param leadRecord record of lead
   * @param leadRespWrapper lead response wrapper
   * @return Task created task
   */
  private static Task createTaskRecord(
    Lead leadRecord,
    LeadResponseWrapper leadRespWrapper
  ) {
    Task responseRecord = new Task(
      Response_Status__c = leadRespWrapper.responseStatus,
      Lead_Quality__c = leadRespWrapper.leadQuality,
      Status = leadRespWrapper.autoCreateActivities
        ? TASK_STATUS_NEW
        : TASK_STATUS_COMPLETED,
      Outcome_Reason__c = leadRespWrapper.outcomeReason,
      Description = leadRespWrapper.commentVal,
      RecordTypeId = RTTask.leadResponse,
      WhoId = Id.valueOf(leadRespWrapper.leadId),
      Response_Type__c = Id.valueOf(leadRespWrapper.responseTypeValue),
      ActivityDate = leadRespWrapper.autoCreateActivities
        ? leadRespWrapper.dueDate
        : leadRespWrapper.followUpDate,
      Subject = leadRespWrapper.autoCreateActivities
        ? TASK_SUBJECT +
          ' - ' +
          (leadRecord.FinServ__ExpressedInterest__c ?? '')
        : leadRespWrapper.responseStatus + ': ' + leadRespWrapper.outcomeReason
    );
    if (leadRecord.RecordTypeId == RTLead.mlcrmLead) {
      responseRecord.ActivityDate = leadRespWrapper.followUpDate;
      responseRecord.Subject =
        leadRespWrapper.responseStatus +
        ': ' +
        leadRespWrapper.outcomeReason;
    }
    // ML/CCRM users do not have access to Lead Response recordtype and they should not be created manually.
    // So inserting task in system mode.
    DML_REPOSITORY.doInsert(
      responseRecord,
      new DmlConfig()
        .errorLog('Error while creating Log Response task')
        .systemMode()
    );
    return responseRecord;
  }

  /**
   * @description This method is used to validate if campaign End Date is maximum than final expiry date
   * @name validateCampaignDateMaxExpiry
   * @param leadRecordId
   * @return Boolean true if campaign End Date is maximum than final expiry date
   */
  private static Boolean validateCampaignDateMaxExpiry(String leadRecordId) {
    CampaignMember campaignMemberRecord = LOG_A_RESPONSE_REPO.getCampaignMemberRecord(
      leadRecordId
    );
    if (campaignMemberRecord == null) {
      return false;
    }
    return campaignMemberRecord.Lead.Expiry_Date__c ==
      campaignMemberRecord.Campaign.EndDate;
  }

  /**
   * @description Wrapper Class for CCRM Lead Response Task Record.
   * @name LeadResponseWrapper
   */
  public class LeadResponseWrapper {
    /**
     * @description Response Status
     */
    @AuraEnabled
    public String responseStatus { get; set; }
    /**
     * @description Lead Quality
     */
    @AuraEnabled
    public String leadQuality { get; set; }
    /**
     * @description Outcome Reason
     */
    @AuraEnabled
    public String outcomeReason { get; set; }
    /**
     * @description Follow-Up Date
     */
    @AuraEnabled
    public Date followUpDate { get; set; }
    /**
     * @description Comment
     */
    @AuraEnabled
    public String commentVal { get; set; }
    /**
     * @description Lead Id
     */
    @AuraEnabled
    public String leadId { get; set; }
    /**
     * @description Response Type Value
     */
    @AuraEnabled
    public String responseTypeValue { get; set; }
    /**
     * @description Auto Create Activities Value
     */
    @AuraEnabled
    public Boolean autoCreateActivities { get; set; }
    /**
     * @description Due Date
     */
    @AuraEnabled
    public Date dueDate { get; set; }
  }

  /**
   * @description wrapper class to store lead guidance details
   */
  @TestVisible
  private class LeadGuidance {
    @TestVisible
    String campaignLeadsLink;
    @TestVisible
    String customerConversationGuideLink;
    @TestVisible
    Map<String, String> mapOfLeadStatusReasonAndNextDetail;

    /**
     * @description Constructor.
     * @name LeadGuidance
     * @param campaignLeadsLink get campaign leads link
     * @param customerConversationGuideLink get customer converstaion huide link
     * @param mapOfLeadStatusReasonAndNextDetail get map of lead status and next detail
     */
    private LeadGuidance(
      String campaignLeadsLink,
      String customerConversationGuideLink,
      Map<String, String> mapOfLeadStatusReasonAndNextDetail
    ) {
      this.campaignLeadsLink = campaignLeadsLink;
      this.customerConversationGuideLink = customerConversationGuideLink;
      this.mapOfLeadStatusReasonAndNextDetail = mapOfLeadStatusReasonAndNextDetail;
    }
  }
}
