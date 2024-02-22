/**
 * @author Sahil S
 * @since 09/2021
 * @description This is controller class for leadLogAResponse Lightning Web Component.
 */
public with sharing class CCRMLogAResponseController {
  private static final String LOG_RESPONSE_ERROR_MESSAGE = 'Error Message: No permission to create Lead Response record. Lead Response is not logged.';
  private static final String TASK_STATUS_NEW = 'Open';
  private static final String TASK_SUBJECT = 'Customer Meeting';

  /**
   * @description Fetch the list of DCRM Lead Response Conversation Guide metadata and Lead Stage Automation records
   * @name getLeadResponseGuidanceMapping
   * @param leadId
   * @return String serialized Map<String, List<Response_Type__C>>.
   */
  @AuraEnabled(cacheable=true)
  public static String getLeadResponseGuidanceMapping(String leadId) {
    Map<String, String> mapOfLeadStatusResponseAndNextStep = new Map<String, String>();
    Set<String> userRoleSet;
    Lead leadInstance = new Lead();
    LeadGuidance leadGuidanceInstance;

    if (Schema.sObjectType.Lead.isQueryable()) {
      //get lead profile and role name
      leadInstance = [
        SELECT
          Id,
          Owner.Profile.Name,
          Owner.UserRole.Name,
          RecordType.DeveloperName,
          Status
        FROM Lead
        WHERE OwnerId != NULL AND Id = :leadId
      ];
    }

    //get Load stage automation metadata to get what's next info for the current lead response status.
    for (Lead_Stage_Automation__mdt iterator : [
      SELECT
        Id,
        Response_Status__c,
        Response_Type_CreateOpportunity__c,
        isActive__c,
        What_happens_next__c,
        Lead_Record_Type__c,
        Lead_Status__c
      FROM Lead_Stage_Automation__mdt
      WHERE
        isActive__c = TRUE
        AND Lead_Record_Type__c = :leadInstance.RecordType.DeveloperName
    ]) {
      if (
        !mapOfLeadStatusResponseAndNextStep.containsKey(
          iterator.Response_Status__c +
          iterator.Response_Type_CreateOpportunity__c
        )
      ) {
        mapOfLeadStatusResponseAndNextStep.put(
          iterator.Response_Status__c +
          (leadInstance.RecordTypeId == CCRMConstants.CCRM_LEAD_RT_ID
            ? iterator.Response_Type_CreateOpportunity__c != null
                ? iterator.Response_Type_CreateOpportunity__c
                : 'false'
            : ''),
          iterator.What_happens_next__c
        );
      }
    }

    //get lead response conversation guide metadata for guidance urls
    List<DCRM_Lead_Response_Conversation_Guide__mdt> dcrmLeadResponseConverstaionGuidList = new List<DCRM_Lead_Response_Conversation_Guide__mdt>(
      [
        SELECT
          Id,
          Profile__c,
          User_Role__c,
          Campaign_Lead_URL__c,
          Conversation_Guide_URL__c
        FROM DCRM_Lead_Response_Conversation_Guide__mdt
        WHERE Profile__c = :leadInstance.Owner.Profile.Name
      ]
    );

    //get LeadGuidance class instance values to return to the calling method
    if (!dcrmLeadResponseConverstaionGuidList.isEmpty()) {
      if (dcrmLeadResponseConverstaionGuidList.size() > 1) {
        for (
          DCRM_Lead_Response_Conversation_Guide__mdt iterator : dcrmLeadResponseConverstaionGuidList
        ) {
          userRoleSet = iterator.User_Role__c.contains(',')
            ? new Set<String>(iterator.User_Role__c.split(','))
            : new Set<String>{ iterator.User_Role__c };
          if (userRoleSet.contains(leadInstance.Owner.UserRole.Name)) {
            leadGuidanceInstance = new LeadGuidance(
              iterator.Campaign_Lead_URL__c,
              iterator.Conversation_Guide_URL__c,
              mapOfLeadStatusResponseAndNextStep
            );
            break;
          }
        }
      } else {
        leadGuidanceInstance = new LeadGuidance(
          dcrmLeadResponseConverstaionGuidList[0].Campaign_Lead_URL__c,
          dcrmLeadResponseConverstaionGuidList[0].Conversation_Guide_URL__c,
          mapOfLeadStatusResponseAndNextStep
        );
      }
    }
    if (leadGuidanceInstance == null) {
      leadGuidanceInstance = new LeadGuidance(
        '',
        '',
        mapOfLeadStatusResponseAndNextStep
      );
    }
    return JSON.serialize(leadGuidanceInstance);
  }

  /**
   * @description Fetch the list of Response Status and Outcome Reason dependent picklist..
   * @name responseStatusDependentValues
   * @param leadRecordId
   * @return String serialized Map<String, List<Response_Type__C>>.
   */
  @AuraEnabled(cacheable=true)
  public static String responseStatusDependentValues(String leadRecordId) {
    Map<String, List<Response_Type__C>> responseStatusOutcomeReasonMap = new Map<String, List<Response_Type__C>>();
    Id linkedCampaignRecord;

    if (Schema.sObjectType.CampaignMember.isQueryable()) {
      List<CampaignMember> campaignMembers = [
        SELECT LeadId, CampaignId
        FROM CampaignMember
        WHERE LeadId = :leadRecordId
        ORDER BY LastModifiedDate DESC
        LIMIT 1
      ];
      if (campaignMembers.isEmpty()) {
        return JSON.serialize(responseStatusOutcomeReasonMap);
      }
      linkedCampaignRecord = campaignMembers[0].CampaignId;
    }

    if (Schema.sObjectType.Response_Type__C.isQueryable()) {
      for (Response_Type__C responseTypeRecords : [
        SELECT
          Id,
          Campaign__r.Id,
          Close_To_Do_Activities__c,
          Create_Activities_From_Template__c,
          Create_Opportunity__c,
          Create_To_Do_Activities__c,
          Display_Order__c,
          Follow_Up_State__c,
          Is_Active__c,
          Outcome_Reason__c,
          Response_Status__c,
          Name,
          UNICA_Lead_SubStatus__c
        FROM Response_Type__C
        WHERE Campaign__c = :linkedCampaignRecord AND Is_Active__c = TRUE
      ]) {
        List<Response_Type__C> outcomeReasonValues = new List<Response_Type__C>();
        outcomeReasonValues = responseStatusOutcomeReasonMap.containsKey(
            responseTypeRecords.Response_Status__c
          )
          ? responseStatusOutcomeReasonMap.get(
              responseTypeRecords.Response_Status__c
            )
          : new List<Response_Type__C>();
        outcomeReasonValues.add(responseTypeRecords);
        responseStatusOutcomeReasonMap.put(
          responseTypeRecords.Response_Status__c,
          outcomeReasonValues
        );
      }
    }
    return JSON.serialize(responseStatusOutcomeReasonMap);
  }

  /**
   * @description Create a CCRM Lead Response Task Record.
   * @name createResponseRecord
   * @param leadRespString
   * @return String of New Record Id.
   */
  @SuppressWarnings('PMD.CyclomaticComplexity')
  @AuraEnabled
  public static String createResponseRecord(String leadRespString) {
    LeadResponseWrapper leadRespWrapper = (LeadResponseWrapper) JSON.deserialize(
      leadRespString,
      LeadResponseWrapper.class
    );
    Lead validateLeadState = new Lead();
    if (
      Schema.sObjectType.Lead.isQueryable() &&
      Schema.sObjectType.Lead_Stage_Automation__mdt.isQueryable()
    ) {
      validateLeadState = [
        SELECT
          Id,
          Status,
          FinServ__RelatedAccount__c,
          FinServ__ExpressedInterest__c,
          Name,
          ABN__c,
          ACN__c,
          ABN_Validation_Status__c,
          ACN_Validation_Status__c
        FROM Lead
        WHERE Id = :leadRespWrapper.leadId
      ];
      if (Label.CCRM_NonEditableLeadStages.contains(validateLeadState.Status)) {
        return JSON.serialize(
          'Warning Message: Responses cannot be logged for Leads on ' +
          Label.CCRM_NonEditableLeadStages +
          ' Stages.'
        );
      }
      // Validate Lead before logging response of Referred Status.
      if (
        (validateLeadState.ABN__C != null &&
        validateLeadState.ABN_Validation_Status__c !=
        CCRMConstants.ABN_ACN_STATUS_ACTIVE) ||
        (validateLeadState.ACN__C != null &&
        validateLeadState.ACN_Validation_Status__c !=
        CCRMConstants.ABN_ACN_STATUS_ACTIVE)
      ) {
        for (Lead_Stage_Automation__mdt referredLeadMetadata : [
          SELECT Id, Response_Status__c
          FROM Lead_Stage_Automation__mdt
          WHERE
            isActive__c = TRUE
            AND Next_Lead_Status__c = :CCRMConstants.STATUS_REFERRED
        ]) {
          if (
            referredLeadMetadata.Response_Status__c ==
            leadRespWrapper.responseStatus
          ) {
            return JSON.serialize(
              'Error Message: ' + CCRMConstants.ABN_ACN_VALIDATION_MESSAGE
            );
          }
        }
      }
    }

    if (Schema.sObjectType.Task.isCreateable()) {
      Task responseRecord = new Task();
      if (
        leadRespWrapper.autoCreateActivities &&
        validateLeadState.FinServ__ExpressedInterest__c == null
      ) {
        validateLeadState.FinServ__ExpressedInterest__c = '';
      }
      responseRecord.Response_Status__c = leadRespWrapper.responseStatus;
      responseRecord.Lead_Quality__c = leadRespWrapper.leadQuality;
      responseRecord.Status = leadRespWrapper.autoCreateActivities
        ? TASK_STATUS_NEW
        : CCRMConstants.STATUS_COMPLETED;
      responseRecord.Outcome_Reason__c = leadRespWrapper.outcomeReason;
      responseRecord.ActivityDate = leadRespWrapper.autoCreateActivities
        ? leadRespWrapper.dueDate
        : leadRespWrapper.followUpDate;
      responseRecord.Subject = leadRespWrapper.autoCreateActivities
        ? TASK_SUBJECT + ' - ' + validateLeadState.FinServ__ExpressedInterest__c
        : leadRespWrapper.responseStatus + ': ' + leadRespWrapper.outcomeReason;
      responseRecord.Description = leadRespWrapper.commentVal;
      responseRecord.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
      responseRecord.WhoId = Id.valueOf(leadRespWrapper.leadId);
      responseRecord.Response_Type__c = Id.valueOf(
        leadRespWrapper.responseTypeValue
      );
      Database.insert(responseRecord);
      return JSON.serialize(
        new ResponseCapturedDataWrapper(
          responseRecord.Id,
          validateCampaignDateMaxExpiry(leadRespWrapper.leadId)
        )
      );
    } else {
      return JSON.serialize(
        new ResponseCapturedDataWrapper(LOG_RESPONSE_ERROR_MESSAGE, null)
      );
    }
  }

  /**
   * @description This method is used to validate if campaign End Date is maximun than final expiry date
   * @name validateCampaignDateMaxExpiry
   * @param leadRecordId
   * @return Boolean true if campaign End Date is maximun than final expiry date
   * @US CC-1057
   */
  @AuraEnabled
  public static Boolean validateCampaignDateMaxExpiry(String leadRecordId) {
    List<CampaignMember> lstOfCampignMember = [
      SELECT LeadId, Campaign.EndDate, Lead.Expiry_Date__c
      FROM CampaignMember
      WHERE LeadId = :leadRecordId
      LIMIT 1
    ];
    if (
      !lstOfCampignMember.isEmpty() &&
      lstOfCampignMember[0].Lead.Expiry_Date__c ==
      lstOfCampignMember[0].Campaign.EndDate
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Wrapper Class for CCRM Lead Response Task Record.
   * @name LeadResponseWrapper
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
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
  private class LeadGuidance {
    String campaignLeadsLink;
    String customerConversationGuideLink;
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
