/**
 * @author Sahil Sachar
 * @since 12/2021
 * @description CCRM Task Actions consists of all the Task related methods.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMTaskActions {
  @TestVisible
  private static final String RESPONSE_DELETE_ERROR_MESSAGE = 'You cannot delete Responses.';
  private static final String LEAD_AUTO_UPDATE_ERROR_MESSAGE = 'Error Message: Lead cannot be auto updated. Please contact your System Administrator.';

  /**
   * @description Update CCRM Leads based on Logged Response (Task).
   * @name updateCCRMLeads
   * @param listOfLeadResponses List of User Ids to fetch Name.
   */
  public static void updateCCRMLeads(List<Task> listOfLeadResponses) {
    List<Lead> updatedLeads = new List<Lead>();
    Map<String, Task> mapLeadResponses = new Map<String, Task>();
    List<String> selectedLeadStatus = new List<String>();
    Set<String> selectedResponseType = new Set<String>();
    Map<Id, Response_Type__c> mapResponseTypeMeta;
    Boolean isLeadResponse = false;

    for (Task leadResponseRec : listOfLeadResponses) {
      if (
        leadResponseRec.WhoId != null &&
        leadResponseRec.WhoId.getSObjectType() == Lead.sObjectType &&
        leadResponseRec.RecordTypeId == CCRMConstants.LEAD_RESPONSE_RT_ID
      ) {
        mapLeadResponses.put(leadResponseRec.WhoId, leadResponseRec);
        selectedResponseType.add(leadResponseRec.Response_Type__c);
      }
    }
    mapResponseTypeMeta = new Map<Id, Response_Type__c>(
      [
        SELECT Id, Response_Status__c, Create_Opportunity__c
        FROM Response_Type__c
        WHERE Id IN :selectedResponseType
      ]
    );

    try {
      if (
        !mapLeadResponses.isEmpty() &&
        Schema.sObjectType.Lead_Stage_Automation__mdt.isQueryable() &&
        Schema.sObjectType.Lead.isQueryable()
      ) {
        List<Lead_Stage_Automation__mdt> mapLeadStageMetadata = [
          SELECT
            Id,
            Lead_Status__c,
            Next_Lead_Status__c,
            Response_Status__c,
            Response_Type_CreateOpportunity__c,
            isActive__c
          FROM Lead_Stage_Automation__mdt
          WHERE
            isActive__c = TRUE
            AND Lead_Status__c != ''
            AND Next_Lead_Status__c != ''
            AND Response_Status__c != ''
        ];
        for (
          Lead_Stage_Automation__mdt mapLeadStageConfig : mapLeadStageMetadata
        ) {
          if (mapLeadStageConfig.isActive__c) {
            selectedLeadStatus.addAll(
              mapLeadStageConfig.Lead_Status__c.split(',')
            );
          }
        }
        for (Lead leadRecord : [
          SELECT Id, Status, SubStatus__c, Followup_Date__c, Skip_Validations__c
          FROM Lead
          WHERE
            Id IN :mapLeadResponses.keySet()
            AND Status IN :selectedLeadStatus
            AND RecordTypeId = :CCRMConstants.CCRM_LEAD_RT_ID
        ]) {
          for (
            Lead_Stage_Automation__mdt checkAutoStages : mapLeadStageMetadata
          ) {
            if (
              checkAutoStages.Lead_Status__c.contains(leadRecord.Status) &&
              mapLeadResponses.get(leadRecord.Id).Response_Status__c ==
              checkAutoStages.Response_Status__c
            ) {
              if (
                String.valueOf(
                  mapResponseTypeMeta.get(
                      mapLeadResponses.get(leadRecord.Id).Response_Type__c
                    )
                    .Create_Opportunity__c
                ) == checkAutoStages.Response_Type_CreateOpportunity__c &&
                !String.isBlank(
                  checkAutoStages.Response_Type_CreateOpportunity__c
                )
              ) {
                leadRecord.Status = checkAutoStages.Next_Lead_Status__c;
              } else if (
                String.isBlank(
                  checkAutoStages.Response_Type_CreateOpportunity__c
                )
              ) {
                leadRecord.Status = checkAutoStages.Next_Lead_Status__c;
              }
              if (!updatedLeads.contains(leadRecord)) {
                leadRecord.Skip_Validations__c = leadRecord.Skip_Validations__c !=
                  'SkipValidation'
                  ? 'SkipValidation'
                  : 'Validate';
                leadRecord.SubStatus__c = checkAutoStages.Response_Status__c;
                leadRecord.Followup_Date__c = mapLeadResponses.get(
                      leadRecord.Id
                    )
                    .ActivityDate == leadRecord.Followup_Date__c
                  ? leadRecord.Followup_Date__c
                  : mapLeadResponses.get(leadRecord.Id).ActivityDate;
                leadRecord.Lead_Quality__c = mapLeadResponses.get(leadRecord.Id)
                  .Lead_Quality__c;
                updatedLeads.add(leadRecord);
              }
            }
          }
        }
      }
      if (Schema.sObjectType.Lead.isUpdateable() || !updatedLeads.isEmpty()) {
        setExpiryDateFromLogResponse(
          mapLeadResponses,
          mapResponseTypeMeta,
          updatedLeads
        );
        Database.update(updatedLeads);
      }
    } catch (Exception err) {
      String dmlErrorMsg = err.getDmlMessage(0);
      throw new AuraHandledException(
        String.isBlank(dmlErrorMsg)
          ? LEAD_AUTO_UPDATE_ERROR_MESSAGE
          : dmlErrorMsg
      );
    }
  }

  /**
   * @description Validate ABN ACN when task reponse status is referral made
   * @param records list of task records from the trigger
   */
  public static void validateLeadAbnACN(List<Task> records) {
    List<id> leadIds = new List<Id>();
    List<Task> taskList = new List<Task>();
    for (Task record : records) {
      if (
        String.isNotBlank(record.WhoId) &&
        record.Response_Status__c == 'Referral Made'
      ) {
        leadIds.add(record.WhoId);
        taskList.add(record);
      }
    }

    Map<Id, Lead> previousLeadMap = new Map<Id, Lead>(
      [
        SELECT
          Id,
          ABN__c,
          ACN__c,
          ABN_Validation_Status__c,
          ACN_Validation_Status__c
        FROM Lead
        WHERE Id IN :leadIds
      ]
    );

    for (Task taskRec : taskList) {
      Lead leadRec = previousLeadMap.containsKey(taskRec.WhoId)
        ? previousLeadMap.get(taskRec.WhoId)
        : new Lead();
      if (
        leadRec != null &&
        ((String.isNotBlank(leadRec.ABN__c) &&
        leadRec.ABN_Validation_Status__c != 'Active') ||
        (String.isNotBlank(leadRec.ACN__c) &&
        leadRec.ACN_Validation_Status__c != 'Active'))
      ) {
        taskRec.addError(CCRMConstants.ABN_ACN_VALIDATION_MESSAGE);
      }
    }
  }

  /**
   * @description Set exipry date when response log created without follow up date
   * @name setExpiryDateFromLogsResponse
   * @param mapLeadResponses Map of Task
   * @param mapResponseTypeMeta Map of response Type
   * @param updatedLeads List of Leads.
   */
  public static void setExpiryDateFromLogResponse(
    Map<String, Task> mapLeadResponses,
    Map<Id, Response_Type__c> mapResponseTypeMeta,
    List<Lead> updatedLeads
  ) {
    Set<Id> leadIds = new Map<Id, Lead>(updatedLeads).keySet();
    Map<Id, Date> mapOfCampaign = new Map<Id, Date>();

    //Get campaign end date for lead.
    //Lead relationship with Camapign is through junction object - Campaign member
    if (Schema.sObjectType.CampaignMember.isQueryable()) {
      for (CampaignMember cm : [
        SELECT Campaign.EndDate, LeadId
        FROM CampaignMember
        WHERE leadid = :leadIds
      ]) {
        mapOfCampaign.put(cm.LeadId, cm.Campaign.EndDate);
      }
    }

    for (Lead leadRecord : updatedLeads) {
      if (mapLeadResponses.get(leadRecord.Id).ActivityDate == null) {
        Boolean canCreateOpportunity = mapResponseTypeMeta.get(
            mapLeadResponses.get(leadRecord.Id).Response_Type__c
          )
          .Create_Opportunity__c;
        String responseStatus = mapResponseTypeMeta.get(
            mapLeadResponses.get(leadRecord.Id).Response_Type__c
          )
          .Response_Status__c;
        //Set lead expiry only when Log response status is Accepted and Create Opportunity is set to true
        if (canCreateOpportunity && responseStatus == 'Accepted') {
          Date campaignExpiryDate = mapOfCampaign.get(leadRecord.Id);
          leadRecord.Followup_Date__c = null;
          Date todaysDate = Date.valueOf(
            System.today() + Integer.valueOf(System.Label.CCRM_Today_Date)
          );
          Date updatedDate = DateTimeUtils.getWeekday(
            todaysDate
              .addDays(
                integer.valueOf(
                  System.Label.CCRM_ExtendLeadExpiryDateWhenResponseLogCreated
                )
              ),
            false,
            true
          );
          leadRecord.Expiry_Date__c = updatedDate > campaignExpiryDate
            ? campaignExpiryDate
            : updatedDate;
        }
      }
    }
  }

  /**
   * @description General function to populate fields
   * @name populateData
   * @param records tasks to populate
   * @param oldMap contains the map which holds the previous values of task records
   */
  public static void populateData(Task[] records, Map<Id, Task> oldMap) {
    for (Task record : records) {
      maskDescription(record);
      maskSubject(record);
    }
  }

  /**
   * @description Mask Description of Task
   * @name maskDescription
   * @param record Task to mask
   */
  public static void maskDescription(Task record) {
    if (!String.isBlank(record.Description)) {
      record.Description = TextUtils.maskData(record.Description);
    }
  }

  /**
   * @description Mask Subject of Task
   * @name maskSubject
   * @param record Task to mask
   */
  public static void maskSubject(Task record) {
    if (!String.isBlank(record.Subject)) {
      record.Subject = TextUtils.maskData(record.Subject);
    }
  }

  /**
   * @description Prevent deletion of tasks that is a response logged to a lead
   * @name preventDelete
   * @param records tasks to check for preventing deletion
   */
  public static void preventDelete(List<Task> records) {
    for (Task record : records) {
      if (record.RecordTypeId == CCRMConstants.LEAD_RESPONSE_RT_ID) {
        record.addError(RESPONSE_DELETE_ERROR_MESSAGE);
      }
    }
  }
}
