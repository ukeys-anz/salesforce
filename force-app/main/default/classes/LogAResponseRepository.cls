/**
 * @author Ashwin Mohan
 * @since May 2025
 * @description This is repository class for LogAResponseController.
 */
public with sharing class LogAResponseRepository {
  private static List<Lead_Stage_Automation__mdt> leadStageAutomationMetadata = QueryLeadStageAutomation.getAll()
    .values();
  private static List<DCRM_Lead_Response_Conversation_Guide__mdt> leadeadResponseConvGuideMetadata = DCRM_Lead_Response_Conversation_Guide__mdt.getAll()
    .values();

  /**
   * @description to fetch Lead record instance
   * @param leadId record Id of lead
   * @return Lead
   */
  public Lead getLeadInstance(String leadId) {
    if (String.isBlank(leadId)) {
      return null;
    }
    return [
      SELECT
        Id,
        Owner.Profile.Name,
        Owner.UserRole.Name,
        RecordType.DeveloperName,
        Status,
        FinServ__RelatedAccount__c,
        FinServ__ExpressedInterest__c,
        Name,
        ABN__c,
        ACN__c,
        ABN_Validation_Status__c,
        ACN_Validation_Status__c,
        RecordTypeId
      FROM Lead
      WHERE Id = :leadId
      WITH SYSTEM_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description to get Lead stage automation metadata to get what's next info for the current lead response status
   * @return List<Lead_Stage_Automation__mdt>
   */
  public List<Lead_Stage_Automation__mdt> getLeadStageAutomationMetadata() {
    return leadStageAutomationMetadata;
  }

  /**
   * @description to get Lead Response conversation guide
   * @return List<DCRM_Lead_Response_Conversation_Guide__mdt>
   */
  public List<DCRM_Lead_Response_Conversation_Guide__mdt> getLeadResponseConvGuide() {
    return leadeadResponseConvGuideMetadata;
  }

  /**
   * @description to get Campaign Member record related to lead
   * @param leadRecordId Lead record id
   * @return CampaignMember
   */
  public CampaignMember getCampaignMemberRecord(Id leadRecordId) {
    if (String.isBlank(leadRecordId)) {
      return null;
    }
    return [
      SELECT LeadId, CampaignId, Campaign.EndDate, Lead.Expiry_Date__c
      FROM CampaignMember
      WHERE LeadId = :leadRecordId
      WITH USER_MODE
      ORDER BY LastModifiedDate DESC
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description to get Response type records
   * @param campaignId Campaign Record Id
   * @return List<Response_Type__c>
   */
  public List<Response_Type__c> getResponseTypeRecords(Id campaignId) {
    if (String.isBlank(campaignId)) {
      return new List<Response_Type__c>();
    }
    return [
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
      FROM Response_Type__c
      WHERE Campaign__c = :campaignId AND Is_Active__c = TRUE
      WITH USER_MODE
    ];
  }
}
