/**
 * @author Sahil S
 * @since 09/2021
 * @description This is controller class for leadLogAResponse Lightning Web Component.
 */
public with sharing class CCRMLogAResponseController {
  private static final String LOG_RESPONSE_ERROR_MESSAGE = 'Error Message: No permission to create Lead Response record. Lead Response is not logged.';

  /**
   * @description Fetch the list of Response Status and Outcome Reason dependent picklist..
   * @name responseStatusDependentValues
   * @param leadRecordId
   * @return String serialized Map<String, List<Response_Type__C>>.
   */
  @AuraEnabled(cacheable=true)
  public static String responseStatusDependentValues(String leadRecordId) {
    List<String> responseStatusValues = new List<String>();
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
    if (
      Schema.sObjectType.Lead.isQueryable() &&
      Schema.sObjectType.Lead_Stage_Automation__mdt.isQueryable()
    ) {
      Lead validateLeadState = [
        SELECT
          Id,
          Status,
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
      responseRecord.Response_Status__c = leadRespWrapper.responseStatus;
      responseRecord.Lead_Quality__c = leadRespWrapper.leadQuality;
      responseRecord.Status = CCRMConstants.STATUS_COMPLETED;
      responseRecord.Outcome_Reason__c = leadRespWrapper.outcomeReason;
      responseRecord.ActivityDate = leadRespWrapper.followUpDate;
      responseRecord.Subject =
        leadRespWrapper.responseStatus +
        ': ' +
        leadRespWrapper.outcomeReason;
      responseRecord.Description = leadRespWrapper.commentVal;
      responseRecord.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
      responseRecord.WhoId = Id.valueOf(leadRespWrapper.leadId);
      responseRecord.Response_Type__c = Id.valueOf(
        leadRespWrapper.responseTypeValue
      );
      Database.insert(responseRecord);
      return responseRecord.Id;
    } else {
      return LOG_RESPONSE_ERROR_MESSAGE;
    }
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
  }
}
