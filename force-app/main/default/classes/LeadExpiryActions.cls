/**
 * Helper class to manage Lead Expiry Actions.
 * @author Ashish Kumar
 * @since March 2025
 * @description Lead Trigger Actions.
 */
public with sharing class LeadExpiryActions {
  private static final Set<ID> LEAD_STATUS_CHANGE_ELIGIBLE_RT_ID = new Set<Id>{
    RTLead.mlcrmLead
  };
  private static final TaskActionRepository TASK_REPOSITORY = (TaskActionRepository) Lib_InstanceProvider.forType(
    TaskActionRepository.class
  );
  private static final CampaignMemberActionRepository CAMPAIGN_MEMBER_REPOSITORY = (CampaignMemberActionRepository) Lib_InstanceProvider.forType(
    CampaignMemberActionRepository.class
  );
  private static final Map<Id, String> RT_TO_DEFAULTDAY_MAP = new Map<Id, String>{
    RTLead.mlcrmLead => Label.ML_MinDaysExpiryDateExtends,
    RTLead.commercialLead => Label.DefaultLeadExpiryDate
  };

  /**
   * @description This method extends the expiry date when:
   * Log Response created with Follow up date AND Follow up date is changed
   * @name getUnexpiredLeads
   * @param lstOfRecords Lead record.
   * @return List<Lead>
   */
  public static List<Lead> getUnexpiredLeads(List<Lead> lstOfRecords) {
    List<Lead> lstOfUnexpiredLead = new List<Lead>();
    for (Lead record : lstOfRecords) {
      if (record.Expiry_Date__c < Date.today()) {
        continue;
      }
      lstOfUnexpiredLead.add(record);
    }
    return lstOfUnexpiredLead;
  }

  /**
   * @description This method extends the expiry date when:
   * Log Response created with Follow up date AND Follow up date is changed
   * @name populateExpiryDaysBasedOnWeekDays
   * @param lstOfRecords Lead record.
   * @param leadWithIncludeFridayMap map lead with Include friday = true or false
   */
  public static void populateExpiryDaysBasedOnWeekDays(
    List<Lead> lstOfRecords,
    Map<Id, Boolean> leadWithIncludeFridayMap
  ) {
    for (Lead record : lstOfRecords) {
      Boolean includeFriday = leadWithIncludeFridayMap.get(record.id) ?? false;
      record.Expiry_Date__c = DateTimeUtils.getWeekday(
        record.Expiry_Date__c,
        includeFriday,
        false
      );
    }
  }

  /**
   * @description Get Map of Campaign related to Lead
   * @name validateExpiryDateWithCampaignDate
   * @param records List of lead new records.
   * @param mapCampaigns List of lead new records.
   */
  public static void validateExpiryDateWithCampaignDate(
    List<Lead> records,
    Map<Id, CampaignMember> mapCampaigns
  ) {
    for (Lead objLead : records) {
      if (!mapCampaigns.containsKey(objLead.Id)) {
        continue;
      }
      Date endDate = mapCampaigns.get(objLead.Id).Campaign.Enddate;
      if (objLead.Expiry_Date__c > endDate) {
        objLead.Expiry_Date__c = endDate;
      }
    }
  }

  /**
   * @description Get Map of Campaign related to Lead
   * @name getMapOfCampaign
   * @param records List of lead new records.
   * @return Map<String, Date> where Key is Lead Id.
   */
  public static Map<Id, CampaignMember> getMapOfCampaign(List<Lead> records) {
    Set<Id> leadIds = new Set<Id>();
    leadIds = ListUtil.getIds(records, Lead.Id);
    List<CampaignMember> lstOfCampaignMember = CAMPAIGN_MEMBER_REPOSITORY.getCampaignMember(
      leadIds
    );
    return (Map<Id, CampaignMember>) ListUtil.mapBy(
      lstOfCampaignMember,
      CampaignMember.LeadId
    );
  }

  /**
   * @description Get Map of Task related to Lead
   * @name getMapOfTask
   * @param records List of lead new records.
   * @param oldMap Map of lead with key Id.
   * @return Map<String, Task> where Key is Lead Id.
   */
  public static Map<Id, Task> getMapOfTask(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> lstOfLeadWithFollowDateCriteria = ListUtil.filter(
        records,
        oldMap
      )
      .changed(Lead.Followup_Date__c)
      .isNotNull(Lead.Followup_Date__c)
      .toList();
    Set<Id> leadIds = new Set<Id>();
    for (Lead objLead : lstOfLeadWithFollowDateCriteria) {
      Integer defaultDays = Integer.valueOf(
        RT_TO_DEFAULTDAY_MAP.get(objLead.RecordTypeId)
      );
      Date followUpDate = objLead.Followup_Date__c.addDays(defaultDays);
      if (followUpDate > objLead.Expiry_Date__c) {
        leadIds.add(objLead.Id);
      }
    }
    leadIds.addAll(getAcceptedLeadIds(records, oldMap));

    List<Task> taskRecords = TASK_REPOSITORY.getTaskResponse(leadIds);
    //map of lead id to latest task response
    Map<Id, Task> mapLeadtoLatestTaskResponse = (Map<Id, Task>) ListUtil.mapBy(
      taskRecords,
      Task.WhoId
    );
    return mapLeadtoLatestTaskResponse;
  }

  /**
   * @description Get Accepted Lead(having status as Opportunity Identified) and proposed expiry date is greater than current expiry date)
   * @name getAcceptedLeadIds
   * @param records List of lead new records.
   * @param oldMap Map of lead with key Id.
   * @return Set<Id> set of lead Ids
   */
  @TestVisible
  private static Set<Id> getAcceptedLeadIds(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> lstOfLeadWithStatusChange = ListUtil.filter(records, oldMap)
      .equals(Lead.RecordTypeId, LEAD_STATUS_CHANGE_ELIGIBLE_RT_ID)
      .changedTo(Lead.status, 'Opportunity Identified')
      .toList();
    Set<Id> acceptedLeadIds = new Set<Id>();
    for (Lead objLead : lstOfLeadWithStatusChange) {
      if (objLead.Followup_Date__c == null) {
        acceptedLeadIds.add(objLead.Id);
        continue;
      }
      Integer defaultDays = Integer.valueOf(
        RT_TO_DEFAULTDAY_MAP.get(objLead.RecordTypeId)
      );
      Date newExpiryDate = objLead.Followup_Date__c.addDays(defaultDays);
      if (newExpiryDate > objLead.Expiry_Date__c) {
        acceptedLeadIds.add(objLead.Id);
      }
    }
    return acceptedLeadIds;
  }

  /**
   * @description Get Map of Task related to Lead
   * @name getMapOfTask
   * @param records List of lead new records.
   * @param oldMap Map of lead with key Id.
   * @return Map<String, Task> where Key is Lead Id.
   */
  public static Map<Id, Task> getMapOfLeadResponse(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredLeadsWithFollowDateChanged = ListUtil.filter(
        records,
        oldMap
      )
      .changed(Lead.Followup_Date__c)
      .toList();
    Set<Id> leadIds = ListUtil.getIds(
      filteredLeadsWithFollowDateChanged,
      Lead.Id
    );
    List<Task> taskRecords = TASK_REPOSITORY.getTaskResponse(leadIds);
    //map of lead id to latest task response
    Map<Id, Task> mapLeadtoLatestTaskResponse = (Map<Id, Task>) ListUtil.mapBy(
      taskRecords,
      Task.WhoId
    );
    return mapLeadtoLatestTaskResponse;
  }

  /**
   * @description to update lead Expiry date with next Day
   * @name updateExpiryDateForNextDay
   * @param records Lead record.
   */
  public static void updateExpiryDateForNextDay(List<Lead> records) {
    for (Lead record : records) {
      string dayName = DateTimeUtils.getDay(record.Expiry_Date__c);
      switch on dayName {
        when 'Mon', 'Tue', 'Wed', 'Thu' {
          record.Expiry_Date__c = record.Expiry_Date__c + 1;
        }
      }
    }
  }

  /**
   * @description to get Lead map with IncludeFriday to true if Expiry date is friday
   * @name getLeadsWithIncludeFridayMap
   * @param records Lead record.
   * @return Map<Id, Boolean> map of Lead with boolean include friday value
   */
  public static Map<Id, Boolean> getLeadsWithIncludeFridayMap(
    List<Lead> records
  ) {
    Map<Id, Boolean> leadWithIncludeFridayMap = new Map<Id, Boolean>();
    for (Lead record : records) {
      string dayName = DateTimeUtils.getDay(record.Expiry_Date__c);
      switch on dayName {
        when 'Fri' {
          leadWithIncludeFridayMap.put(record.id, true);
        }
        when 'Sat', 'Sun' {
          leadWithIncludeFridayMap.put(record.id, false);
        }
      }
    }
    return leadWithIncludeFridayMap;
  }

  /**
   * @description to get Lead map with IncludeFriday to true if Expiry date is in Future
   * @name getLeadsWithIncludeFridayMap
   * @param records Lead record.
   * @param  leadWithIncludeFridayMap map of lead with Include friday Boolean
   * @return Map<Id, Boolean> map of Lead with boolean value
   */
  public static Map<Id, Boolean> getLeadsWithIncludeFridayMapForFutureExpiry(
    List<Lead> records,
    Map<Id, Boolean> leadWithIncludeFridayMap
  ) {
    List<Lead> filteredFutureLead = ListUtil.filter(records)
      .notEquals(
        Lead.Expiry_Date__c,
        Date.today().addDays(Integer.valueOf(System.Label.CCRM_Today_Date))
      )
      .toList();
    for (Lead record : filteredFutureLead) {
      leadWithIncludeFridayMap.put(record.id, true);
    }
    return leadWithIncludeFridayMap;
  }
}
