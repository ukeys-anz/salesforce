/**
 * @author MLCRM Developer
 * @since 10/07/2024
 * @description private without sharing class to bypass lead sharing setting in lead conversion process
 */
public without sharing class LeadConversionOperations {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );
  private static final A2ZReviewRepository A2ZREVIEW_REPOSITORY = (A2ZReviewRepository) Lib_InstanceProvider.forType(
    A2ZReviewRepository.class
  );

  private static final String CONVERT_LEAD = 'ConvertLead';
  private static final String MLCRM = 'MLCRM';
  private static final String INDIVIDUAL = 'Individual';
  private static final Set<String> LEAD_ORIGINATOR_FOR_PLATFORMEVENT = new Set<String>{
    'UNICA',
    'Adobe',
    'CCRM'
  };

  /**
   * @description convertLead convert leads
   * @param accountId get account id created/matched for lead conversion
   * @param leadRec The Lead records created/matched for lead conversion
   * @return Map<Id,Id> map Of lead and OpportunityId
   */
  public static Map<Id, Id> convertLead(ID accountId, Lead leadRec) {
    List<Task> leadTasksList = LEADCONV_REPOSITORY.getLeadTasks(leadRec.id);
    setLeadSkipValidation(leadRec); //as per CC-4248
    setTaskSkipValidation(leadTasksList); //as per CC-4248
    //create Opportunity
    Map<Id, Id> mapOfOpportunityId = createOpportunity(leadRec, accountId);
    AccountCommonActions.convertedAccountIds.add(accountId);
    //Lead conversion
    Database.LeadConvertResult lcResult = dmlConvertLeadRecord(
      accountId,
      leadRec.Id,
      mapOfOpportunityId.get(leadRec.id)
    );
    if (lcResult == null || !lcResult.isSuccess()) {
      generateLoggerErrors(lcResult);
      return new Map<Id, Id>();
    }
    //send platform event to unica/Adobe
    ID leadId = getLeadIdForUnicaAdobeOnLC(leadRec);
    CCRMLeadPlatformEventActions.sendUpdateToUnicaOrAdobeOnLeadConversion(
      leadId,
      mapOfOpportunityId,
      leadTasksList
    );
    //auto create mismatch task
    Boolean autoMisMatchTaskRequired = isAutoMisMatchTaskRequired(leadRec);
    if (autoMisMatchTaskRequired) {
      System.enqueuejob(
        new AutoTaskOnLeadConversionQueueable(mapOfOpportunityId)
      );
    }
    //transfer tasks
    transferTasksToOpportunity(mapOfOpportunityId, leadTasksList);
    //transfer A2Z Review to Opportunity
    Map<Id, Id> mapOfAccountIdWithLeadForA2ZReview = getMapOfAccountIdWithLeadForA2ZReview(
      lcResult,
      leadRec
    );
    ID leadToCreateOpportunityTeamMember = getLeadIdToCreateOpportunityTeamMember(
      lcResult,
      leadRec
    );
    ID convertedOppId = mapOfOpportunityId.get(leadRec.Id);
    createOpportunityTeamMemberRecord(
      leadToCreateOpportunityTeamMember,
      convertedOppId
    );
    transferA2ZReviewToOpportunity(
      mapOfAccountIdWithLeadForA2ZReview,
      mapOfOpportunityId
    );
    Set<ID> contactIds = getContactsToDelete(lcResult);
    deleteAutoCreatedContacts(contactIds);
    return mapOfOpportunityId;
  }

  /**
   * @description Set Lead Skip Validation.
   * @name setLeadSkipValidation
   * @param leadRecord Lead Record to update Skip Validation
   */
  @testVisible
  private static void setLeadSkipValidation(Lead leadRecord) {
    if (leadRecord.Skip_Validations__c == CONVERT_LEAD) {
      return;
    }
    leadRecord.Skip_Validations__c = CONVERT_LEAD;
    DML_REPOSITORY.doUpdate(
      leadRecord,
      new DmlConfig().allowPartial().systemMode()
    );
  }

  /**
   * @description Check Task Skip Validations
   * @name setTaskSkipValidation
   *  @param taskList list Of Tasks
   */
  @testVisible
  private static void setTaskSkipValidation(List<Task> taskList) {
    List<Task> newTasksList = new List<Task>();
    for (Task task : taskList) {
      if (task.Skip_Validations__c == CONVERT_LEAD) {
        continue;
      }
      task.Skip_Validations__c = CONVERT_LEAD;
      newTasksList.add(task);
    }
    DML_REPOSITORY.doUpdate(
      newTasksList,
      new DmlConfig().allowPartial().systemMode()
    );
  }

  /**
   * @description Create Opportunity for lead conversion
   * @param leadRecord lead from lead conversion
   * @param accountId  account id
   * @return mapOf lead and OpportunityId
   */
  @testVisible
  private static Map<Id, Id> createOpportunity(Lead leadRecord, Id accountId) {
    if (leadRecord == null) {
      return null;
    }
    Opportunity opportunityRecord = LeadMappingEngine.mapLeadToOpportunityFields(
      leadRecord,
      accountId
    );
    DML_REPOSITORY.doInsert(opportunityRecord, new DmlConfig().systemMode());
    // dummy inserted records does not have an Id during a test run
    if (Test.isRunningTest()) {
      opportunityRecord.Id = Lib_FakeIdGenerator.getMockId(
        Schema.Opportunity.getSObjectType()
      );
    }
    return new Map<Id, Id>{ leadRecord.id => opportunityRecord.Id };
  }

  /**
   * @description generateLoggerErrors to generate Errors if convert Lead unsuccessfull
   * @param lcResult lcResults Lead conversion result
   */
  public static void generateLoggerErrors(Database.LeadConvertResult lcResult) {
    if (lcResult == null || lcResult.isSuccess()) {
      return;
    }
    Logger.error(
      'Account_Id: ' +
        lcResult.getAccountId() +
        '; Lead_Id: ' +
        lcResult.getLeadId() +
        '; Error_Message: ' +
        lcResult.getErrors()[0].getMessage()
    );
    Logger.saveLog();
  }

  /**
   * @description insertLeadConvertRecord to convert the lead record
   * @param accountId get account id created/matched for lead conversion
   * @param leadId The Lead id for lead conversion
   * @param opportunityId The Opportunity id created before lead conversion
   * @return Database.LeadConvertResult Lead conversion result
   */
  @testVisible
  private static Database.LeadConvertResult dmlConvertLeadRecord(
    ID accountId,
    Id leadId,
    Id opportunityId
  ) {
    LeadStatus convertedStatus = LEADCONV_REPOSITORY.getLeadStatus();
    Database.LeadConvert convertRecord = new Database.LeadConvert();
    convertRecord.setLeadId(leadId);
    convertRecord.setAccountId(accountId);
    convertRecord.setOpportunityId(opportunityId);
    convertRecord.setConvertedStatus(convertedStatus.MasterLabel);
    Database.LeadConvertResult lcResult = LEADCONV_REPOSITORY.convertLeadRecord(
      convertRecord
    );
    return lcResult;
  }
  /**
   * @description getLeadIdForUnicaAdobeOnLC to filter out leads to send to unica and adobe
   * @param leadRecord Lead records
   * @return Id lead id to send to unica and adobe
   */
  @testVisible
  private static Id getLeadIdForUnicaAdobeOnLC(Lead leadRecord) {
    if (
      LEAD_ORIGINATOR_FOR_PLATFORMEVENT.contains(leadRecord.Lead_Originator__c)
    ) {
      return leadRecord.id;
    }
    return null;
  }
  /**
   * @description doesAutoMisMatchTaskRequired to check if auto auto Mismatch task creation is needed
   * @param leadRecord Lead records
   * @return autoMisMatchTaskRequired
   */
  @testVisible
  private static Boolean isAutoMisMatchTaskRequired(Lead leadRecord) {
    return (leadRecord.RecordTypeId != RTLead.commercialLead ||
    leadRecord.Entity_Type__c == INDIVIDUAL);
  }
  /**
   * @description getContactsToDelete to filter out contact to delete
   * @param lcResult Lead conversion result
   * @return contactIds contact Ids to delete
   */
  @testVisible
  private static Set<ID> getContactsToDelete(
    Database.LeadConvertResult lcResult
  ) {
    if (lcResult == null || lcResult.getContactId() == null) {
      return new Set<ID>();
    }
    return new Set<ID>{ lcResult.getContactId() };
  }
  /**
   * @description getMapOfAccountIdWithLeadforA2ZReview to filter out ccrm leads for transfer A2Z Review To Opportunity
   * @param lcResult Lead conversion result
   * @param leadRecord Lead record
   * @return mapOfAccountIdWithLead map CCRM lead id with AccountId
   */
  @testVisible
  private static Map<Id, Id> getMapOfAccountIdWithLeadforA2ZReview(
    Database.LeadConvertResult lcResult,
    Lead leadRecord
  ) {
    if (leadRecord.RecordTypeId != RTLead.commercialLead) {
      return new Map<Id, Id>();
    }
    return new Map<Id, Id>{ lcResult.getLeadId() => lcResult.getAccountId() };
  }

  /**
   * @description transfer tasks from lead to opportunity by updating WhatId
   * Used System Mode DML as the Reviews can updated only by Owners
   * @param mapOfAccountIdWithLeadId map of Account id with lead id
   * @param mapOfOpportunityId map of opportunity id with lead id
   */
  @TestVisible
  private static void transferA2ZReviewToOpportunity(
    Map<Id, Id> mapOfAccountIdWithLeadId,
    Map<Id, Id> mapOfOpportunityId
  ) {
    if (mapOfAccountIdWithLeadId.isEmpty()) {
      return;
    }
    List<A_Z_Review__c> listOfA2ZReviews = A2ZREVIEW_REPOSITORY.fetchReviewsByLead(
      mapOfAccountIdWithLeadId.KeySet()
    );
    for (A_Z_Review__c azRecord : listOfA2ZReviews) {
      if (mapOfOpportunityId.containsKey(azRecord.Lead__c)) {
        azRecord.Opportunity__c = mapOfOpportunityId.get(azRecord.Lead__c);
      }
      if (mapOfAccountIdWithLeadId.containsKey(azRecord.Lead__c)) {
        azRecord.Customer__c = mapOfAccountIdWithLeadId.get(azRecord.Lead__c);
      }
    }
    DML_REPOSITORY.doUpdate(
      listOfA2ZReviews,
      new DmlConfig().allowPartial().systemMode()
    );
  }
  /**
   * @description transfer tasks from lead to opportunity by updating WhatId
   * @param mapOfOpportunityId map of opportunity id with lead id
   * @param taskList list of tasks
   */
  @TestVisible
  private static void transferTasksToOpportunity(
    Map<Id, Id> mapOfOpportunityId,
    List<Task> taskList
  ) {
    for (Task taskRecord : taskList) {
      if (!mapOfOpportunityId.containsKey(taskRecord.WhoId)) {
        continue;
      }
      taskRecord.WhatId = mapOfOpportunityId.get(taskRecord.WhoId);
      taskRecord.WhoId = null;
      taskRecord.Skip_Validations__c = CONVERT_LEAD;
    }
    DML_REPOSITORY.doUpdate(
      taskList,
      new DmlConfig().allowPartial().systemMode().withoutSharing()
    );
  }
  /**
   * @description delete auto created contacts post lead conversion
   * @param contactIds list of contacts from lead conversion
   */
  @TestVisible
  private static void deleteAutoCreatedContacts(Set<ID> contactIds) {
    //Separate contactList into org contacts vs person accounts
    List<Contact> orgContactList = new List<Contact>();
    Set<Id> personContactsIdSet = new Set<Id>();
    for (Contact contactRec : LEADCONV_REPOSITORY.getContactList(contactIds)) {
      if (contactRec.isPersonAccount) {
        personContactsIdSet.add(contactRec.id);
      } else {
        orgContactList.add(contactRec);
      }
    }
    DML_REPOSITORY.doDelete(
      orgContactList,
      new DmlConfig().allowPartial().systemMode()
    );
  }

  /**
   * @description This is used to get the Lead Id
   * @param lcResult
   * @param leadRecord
   * @return ID Id of lead record
   */
  @testVisible
  private static ID getLeadIdToCreateOpportunityTeamMember(
    Database.LeadConvertResult lcResult,
    Lead leadRecord
  ) {
    if (
      lcResult == null ||
      lcResult.getLeadId() == null ||
      leadRecord.RecordTypeId != RTLead.commercialLead
    ) {
      return null;
    }
    return lcResult.getLeadId();
  }

  /**
   * @description This is used to add the Internal Referrer on Opportunity
   * @param leadId lead id
   * @param convertedOppId Id of opportunity
   */
  public static void createOpportunityTeamMemberRecord(
    Id leadId,
    Id convertedOppId
  ) {
    //Fetch the lead info
    Lead lead = LEADCONV_REPOSITORY.fetchLeadInfo(leadId);

    //Fix lead conversion issue as in case of ML the lead will not be fetched
    if (lead == null) {
      return;
    }

    //Generate the opp team member list that need to be created
    OpportunityTeamMember oppTeamMember = generateOppTeamMember(
      lead,
      convertedOppId
    );

    //Inserting opp team member
    DML_REPOSITORY.doInsert(oppTeamMember, new DmlConfig().systemMode());
  }

  /**
   * @description This is used to generate the Opp Team Member List.
   * @param leadRec lead record
   * @param convertedOpportunityId Map of Lead and Opp Id
   * @return opportunityTeamMember  Opp Team Members
   */
  @TestVisible
  private static OpportunityTeamMember generateOppTeamMember(
    Lead leadRec,
    Id convertedOpportunityId
  ) {
    //Form a map of Commercial Segment picklist values and label
    Map<String, String> userSegmentMap = CommonUtil.getPicklistLabelsByValues(
      User.Commercial_Segment__c
    );

    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
    oppTeamMember.OpportunityId = convertedOpportunityId;
    oppTeamMember.UserId = leadRec.FinServ__ReferredByUser__c;
    oppTeamMember.TeamMemberRole = userSegmentMap
      ?.get(leadRec?.FinServ__ReferredByUser__r?.Commercial_Segment__c);
    return oppTeamMember;
  }
}
