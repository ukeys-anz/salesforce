/**
 * @author Ashwin Mohan
 * @since 06/2025
 * @description Task Actions consists of all the Task related methods.
 */
public with sharing class LeadResponseTaskActions {
  @TestVisible
  private static final String RESPONSE_DELETE_ERROR_MESSAGE = 'You cannot delete Responses.';
  @TestVisible
  private static final String ABN_ACN_VALIDATION_MESSAGE = 'Capture valid ABN / ACN details';
  private static final TaskActionRepository TASK_REPOSITORY = (TaskActionRepository) Lib_InstanceProvider.forType(
    TaskActionRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static List<Lead_Stage_Automation__mdt> leadStageAutomationMetadata = QueryLeadStageAutomation.getAll()
    .values();

  /**
   * @description Update Commercial/Mobile Lending Leads based on Logged Response (Task).
   * @name updateLeadsBasisLogResponse
   * @param listOfLeadResponses List of User Ids to fetch Name.
   */
  public static void updateLeadsBasisLogResponse(
    List<Task> listOfLeadResponses
  ) {
    List<Task> filteredTasks = ListUtil.filter(listOfLeadResponses)
      .isNotNull(Task.WhoId)
      .toList();
    Map<Id, Task> mapLeadResponses = (Map<Id, Task>) ListUtil.mapBy(
      filteredTasks,
      Task.WhoId
    );
    if (mapLeadResponses.isEmpty()) {
      return;
    }
    Set<Id> selectedResponseTypeIds = ListUtil.getIds(
      filteredTasks,
      Task.Response_Type__c
    );
    Map<Id, Response_Type__c> responseTypeMap = new Map<Id, Response_Type__c>(
      TASK_REPOSITORY.getResponseTypeData(selectedResponseTypeIds)
    );
    Set<String> selectedLeadStatus = ListUtil.getStringsWithSplit(
      leadStageAutomationMetadata,
      Lead_Stage_Automation__mdt.Lead_Status__c,
      ','
    );

    List<Lead> leadRecordList = TASK_REPOSITORY.getLeadRecords(
      mapLeadResponses.keySet(),
      selectedLeadStatus
    );
    List<Lead> updatedLeads = populateLeadDetails(
      leadRecordList,
      mapLeadResponses,
      responseTypeMap
    );
    setExpiryDateFromLogResponse(
      mapLeadResponses,
      responseTypeMap,
      updatedLeads
    );
    DML.doUpdate(updatedLeads, new DMLConfig().systemMode());
  }

  /**
   * @description Populate lead details basis Lead stage metadata and task
   * @name populateLeadDetails
   * @param leadRecordList List of lead records
   * @param mapLeadResponses Map of lead id Vs Task
   * @param responseTypeMap Map of Id and Response type
   * @return List<Lead> list of populated leads
   */
  @TestVisible
  private static List<Lead> populateLeadDetails(
    List<Lead> leadRecordList,
    Map<Id, Task> mapLeadResponses,
    Map<Id, Response_Type__c> responseTypeMap
  ) {
    List<Lead> updatedLeads = new List<Lead>();
    Map<String, List<Lead_Stage_Automation__mdt>> leadStageMdtMap = getMapofLeadStageMetadata();
    for (Lead leadRecord : leadRecordList) {
      Task relatedTask = mapLeadResponses.get(leadRecord.Id);
      Response_Type__c responseTypeRecord = responseTypeMap.get(
        relatedTask.Response_Type__c
      );
      String keyToCheck =
        leadRecord.RecordType.DeveloperName +
        relatedTask.Response_Status__c +
        leadRecord.Status;
      List<Lead_Stage_Automation__mdt> leadStageMdtRecords = leadStageMdtMap.get(
        keyToCheck
      );
      for (Lead_Stage_Automation__mdt leadStageMdt : leadStageMdtRecords) {
        if (
          !String.isBlank(leadStageMdt.Response_Type_CreateOpportunity__c) &&
          (leadStageMdt.Response_Type_CreateOpportunity__c !=
          String.valueOf(responseTypeRecord.Create_Opportunity__c))
        ) {
          continue;
        }
        leadRecord.Status = leadStageMdt.Next_Lead_Status__c;
        leadRecord.Lead_Outcome__c = leadStageMdt.Outcome_Type__c;
        leadRecord.SubStatus__c = leadStageMdt.Response_Status__c;
        leadRecord.Lead_Quality__c = relatedTask.Lead_Quality__c;
        leadRecord.Skip_Validations__c = leadRecord.Skip_Validations__c !=
          'SkipValidation'
          ? 'SkipValidation'
          : 'Validate';
        if (leadRecord.Followup_Date__c != relatedTask.ActivityDate) {
          leadRecord.Followup_Date__c = relatedTask.ActivityDate;
        }
        updatedLeads.add(leadRecord);
      }
    }
    return updatedLeads;
  }

  /**
   * @description Set exipry date when response log created without follow up date
   * @name setExpiryDateFromLogResponse
   * @param mapLeadResponses Map of Task
   * @param responseTypeMap Map of response Type
   * @param updatedLeads List of Leads.
   */
  @TestVisible
  private static void setExpiryDateFromLogResponse(
    Map<Id, Task> mapLeadResponses,
    Map<Id, Response_Type__c> responseTypeMap,
    List<Lead> updatedLeads
  ) {
    List<CampaignMember> campaignMemberRecords = TASK_REPOSITORY.getCampaignMemberRecords(
      ListUtil.getIds(updatedLeads, Lead.Id)
    );
    Map<Id, CampaignMember> mapLeadWithCampaignMembers = (Map<Id, CampaignMember>) ListUtil.mapBy(
      campaignMemberRecords,
      CampaignMember.LeadId
    );
    Integer extendLeadExpiryDate = Integer.valueOf(
      Label.CommercialExtendLeadExpiryDateForLogResponse
    );
    Integer extendTodaysDate = Integer.valueOf(
      Label.CommercialExtendTodaysDate
    );
    for (Lead leadRecord : updatedLeads) {
      Task relatedTask = mapLeadResponses.get(leadRecord.Id);
      Response_Type__c responseTypeRecord = responseTypeMap.get(
        relatedTask.Response_Type__c
      );

      //Set lead expiry only when Log response status is Accepted and Create Opportunity is set to true
      if (
        relatedTask.ActivityDate != null ||
        leadRecord.RecordTypeId == RTLead.mlcrmLead ||
        (!responseTypeRecord.Create_Opportunity__c ||
        responseTypeRecord.Response_Status__c != 'Accepted')
      ) {
        continue;
      }
      Date campaignExpiryDate = mapLeadWithCampaignMembers.get(leadRecord.Id)
        .Campaign.EndDate;
      Date extendedDate = System.today()
        .addDays(extendTodaysDate + extendLeadExpiryDate);
      Date updatedDate = DateTimeUtils.getWeekday(extendedDate, false, true);
      leadRecord.Expiry_Date__c = (campaignExpiryDate < updatedDate)
        ? campaignExpiryDate
        : updatedDate;
      leadRecord.Followup_Date__c = null;
    }
  }

  /**
   * @description Validate ABN ACN when task reponse status is referral made
   * @param records list of task records from the trigger
   */
  public static void validateLeadABNACN(List<Task> records) {
    List<Task> filteredTasks = ListUtil.filter(records)
      .isNotNull(Task.WhoId)
      .equals(Task.Response_Status__c, 'Referral Made')
      .toList();
    Set<Id> leadIds = ListUtil.getIds(filteredTasks, Task.WhoId);

    Map<Id, Lead> leadMap = new Map<Id, Lead>(
      TASK_REPOSITORY.getLeadRecordsWithABNACN(leadIds)
    );

    List<Task> errorABNACNTaskRecords = getABNACNErrorTaskRecords(
      filteredTasks,
      leadMap
    );
    ListUtil.addError(errorABNACNTaskRecords, ABN_ACN_VALIDATION_MESSAGE);
  }

  /**
   * @description Validate ABN ACN for task records
   * @param records list of task records from the trigger
   * @param leadMap Map of Id vs Lead
   * @return List<Task> filtered tasks for ABN ACN Error
   */
  private static List<Task> getABNACNErrorTaskRecords(
    List<Task> records,
    Map<Id, Lead> leadMap
  ) {
    List<Task> errorABNACNTaskRecords = new List<Task>();
    for (Task taskRec : records) {
      Lead leadRecord = leadMap.get(taskRec.WhoId);
      Boolean isABNValStatusNotActive = (String.isNotBlank(leadRecord.ABN__c) &&
      leadRecord.ABN_Validation_Status__c != 'Active');
      Boolean isACNValStatusNotActive = (String.isNotBlank(leadRecord.ACN__c) &&
      leadRecord.ACN_Validation_Status__c != 'Active');
      if (isABNValStatusNotActive || isACNValStatusNotActive) {
        errorABNACNTaskRecords.add(taskRec);
      }
    }
    return errorABNACNTaskRecords;
  }

  /**
   * @description Prevent deletion of tasks that is a response logged to a lead
   * @name preventDelete
   * @param records tasks to check for preventing deletion
   */
  public static void preventDelete(List<Task> records) {
    if (USER_INFO.checkProfile('System Administrator')) {
      return;
    }
    ListUtil.addError(records, RESPONSE_DELETE_ERROR_MESSAGE);
  }

  /**
   * @description Get map of lead stage automation metadata with key as (Recordtype + Response Status + Status) of the lead
   * @return Map<String, List<Lead_Stage_Automation__mdt>>
   */
  private static Map<String, List<Lead_Stage_Automation__mdt>> getMapofLeadStageMetadata() {
    Map<String, List<Lead_Stage_Automation__mdt>> leadStageMdtMap = new Map<String, List<Lead_Stage_Automation__mdt>>();
    for (
      Lead_Stage_Automation__mdt leadStageMdt : leadStageAutomationMetadata
    ) {
      for (String leadStatus : leadStageMdt.Lead_Status__c.split(',')) {
        String key =
          leadStageMdt.Lead_Record_Type__c +
          leadStageMdt.Response_Status__c +
          leadStatus;
        if (!leadStageMdtMap.containsKey(key)) {
          leadStageMdtMap.put(key, new List<Lead_Stage_Automation__mdt>());
        }
        leadStageMdtMap.get(key).add(leadStageMdt);
      }
    }
    return leadStageMdtMap;
  }
}
