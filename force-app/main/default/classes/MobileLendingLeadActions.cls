/**
 * @author Ashish Kumar
 * @since  05/2023
 * @description MobileLendingLeadActions is class to handle all the  Mobile Lending Lead Actions
 */
public with sharing class MobileLendingLeadActions {
  private static final String ORIGINATOR_MLCRM = 'MLCRM';
  private static final LeadActionsRepository LA_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  private static final TerritoryActionsRepository TA_REPOSITORY = (TerritoryActionsRepository) Lib_InstanceProvider.forType(
    TerritoryActionsRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  private static set<String> setOfFollowUpForContactAttempted = new Set<String>{
    'Call Back',
    'Contact Attempted',
    'Accepted',
    'Appointment Booked'
  };
  private static set<String> setOfFollowUpForAppointment = new Set<String>{
    'Accepted',
    'Appointment Booked'
  };
  @TestVisible
  private static final String LEAD_ORIGINATOR_LENDER_ENGAGE = 'Lender Engage';
  /**
   * @description This method to update is new flag checkbox to false during implicit update while lead creation
   * @name noLongerNewLeads
   * @param oldMap Map of old map
   * @param records List of Lead records
   * @author Ashish Kumar
   * @US CC-1609
   */
  public static void noLongerNewLeads(
    Map<Id, Lead> oldMap,
    List<Lead> records
  ) {
    for (Lead record : records) {
      if (
        record.Skip_Validations__c == oldMap.get(record.Id).Skip_Validations__c
      ) {
        record.isNewLead__c = false;
      }
    }
  }

  /**
   * @description This method to set the default value of expiry date for Manually created ML Leads
   * @name setDefaultValue
   * @param records List of Lead records
   * @author Ashish Kumar
   * @US CC-1057
   */
  public static void setDefaultValue(List<Lead> records) {
    Map<String, Integer> mapExpiryDays = new Map<String, Integer>{
      'Sat' => 2,
      'Sun' => 1
    };
    Integer expiryDays = Integer.valueOf(Label.DefaultLeadExpiryDate);
    String dayName = DateTimeUtils.getDay(System.today().addDays(expiryDays));
    expiryDays += mapExpiryDays.get(dayName) ?? 0;
    Date expiryDate = System.today().addDays(expiryDays);
    List<Lead> filteredLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, ORIGINATOR_MLCRM)
      .isNull(Lead.Expiry_Date__c)
      .toList();
    ListUtil.setField(filteredLeads, Lead.Expiry_Date__c, expiryDate);
  }

  /**
   * @description This method to set the primary franchise owner on lead
   * @name populatePrimaryFranchise
   * @param records List of Lead records
   * @param oldMap old Map of Lead records
   * @author Ashish Kumar
   * @US CC-1550
   */
  public static void populatePrimaryFranchise(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredRecords = ListUtil.filter(records, oldMap)
      .isNotNull(Lead.Territory__c)
      .changed(Lead.Territory__c)
      .toList();
    Set<Id> idsOfTerritory = ListUtil.getIds(
      filteredRecords,
      Lead.Territory__c
    );
    List<Territory__c> lstOfTerritory = TA_REPOSITORY.getTerrritories(
      idsOfTerritory
    );
    setLeadPrimaryFranchiseOwner(filteredRecords, lstOfTerritory);
  }

  /**
   * @description to populate Primary Franchise Owner on Leads
   * @name setLeadPrimaryFranchiseOwner
   * @param records The Lead records passed from Trigger.new()
   * @param lstOfTerritory The list of territory records
   */
  @testVisible
  private static void setLeadPrimaryFranchiseOwner(
    List<Lead> records,
    List<Territory__c> lstOfTerritory
  ) {
    Map<Id, Territory__c> mapOfTerritories = new Map<Id, Territory__c>(
      lstOfTerritory
    );

    for (Lead record : records) {
      Territory__c territoryRec = mapOfTerritories.get(record.Territory__c);
      if (territoryRec == null) {
        continue;
      }
      record.Primary_Franchise_Owner__c = territoryRec.Primary_Franchise_Owner__c;
    }
  }

  /**
   * @description CC-7689 to restrict MLCRM Lead Creation if the user don't have sufficient permission
   * i.e. User who does not have this Custom Permmision should not be able to create Lead
   * @name validateLeadCreation
   * @param records The Lead records passed from Trigger.new()
   */
  public static void validateLeadCreation(List<Lead> records) {
    // bypassed if current user is Unica/Adobe Integration  or is a system admin or having 'ML_Allow_Lead_Creation' custom permission
    if (USER_INFO.checkProfile('System Administrator')) {
      return;
    }
    if (USER_INFO.checkCustomPermission('ML_Allow_Lead_Creation')) {
      return;
    }
    ListUtil.addError(records, Label.Lead_Record_Creation_Error);
  }

  /**
   * @description Check and update expiry date for leads.
   *  - lead ownership changed
   *  - follow-up date changed
   *  - expiry date are set after campaign end date
   * @name setExpiryDate
   * @param records List of lead NEW records.
   * @param oldMap Map of leads with Id.
   */
  public static void setExpiryDate(List<Lead> records, Map<Id, Lead> oldMap) {
    List<Lead> unExpiredLeads = LeadExpiryActions.getUnexpiredLeads(records);
    Map<Id, CampaignMember> mapCampaigns = LeadExpiryActions.getMapOfCampaign(
      unExpiredLeads
    );
    Map<Id, Task> mapTask = LeadExpiryActions.getMapOfTask(
      unExpiredLeads,
      oldMap
    );
    List<Lead> leadsToUpdateExpiryDate = updateExpiryDateWhenFollowUpChanged(
      unExpiredLeads,
      mapTask
    );
    List<Lead> ownerChangedLeads = ListUtil.filter(unExpiredLeads, oldMap)
      .changed(Lead.OwnerId)
      .toList();
    List<Lead> filteredLeadsBasedOnExpiryDate = ListUtil.filter(
        ownerChangedLeads
      )
      .equals(
        Lead.Expiry_Date__c,
        new Set<Date>{ Date.today(), Date.today() + 1 }
      )
      .toList();
    Map<Id, Boolean> leadWithIncludeFridayMap = LeadExpiryActions.getLeadsWithIncludeFridayMap(
      filteredLeadsBasedOnExpiryDate
    );
    List<Lead> filteredLeadsForWeekEndExpiry = ListUtil.filter(
        filteredLeadsBasedOnExpiryDate
      )
      .equals(Lead.Id, leadWithIncludeFridayMap.keySet())
      .toList();
    leadsToUpdateExpiryDate.addAll(filteredLeadsForWeekEndExpiry);
    LeadExpiryActions.validateExpiryDateWithCampaignDate(
      leadsToUpdateExpiryDate,
      mapCampaigns
    );
    LeadExpiryActions.populateExpiryDaysBasedOnWeekDays(
      leadsToUpdateExpiryDate,
      leadWithIncludeFridayMap
    );
    LeadExpiryActions.updateExpiryDateForNextDay(
      filteredLeadsBasedOnExpiryDate
    );
    List<Lead> leadsToUpdateFollowUpDate = ListUtil.filter(
        leadsToUpdateExpiryDate
      )
      .isNotNull(Lead.Followup_Date__c)
      .toList();
    updateFollowupdate(leadsToUpdateFollowUpDate, mapCampaigns);
  }

  /**
   * @description This method extends the expiry date when:
   * Log Response created with Follow up date AND Follow up date is changed
   * @name updateExpiryDateWhenFollowUpChanged
   * @param records Lead record.
   * @param mapTask Map of Task
   * @return Date
   */
  @testVisible
  private static List<Lead> updateExpiryDateWhenFollowUpChanged(
    List<Lead> records,
    Map<Id, Task> mapTask
  ) {
    Integer minDays = integer.valueOf(Label.ML_MinDaysExpiryDateExtends);
    Integer maxdays = integer.valueOf(Label.ML_MaxDaysExpiryDateExtends);
    List<Lead> updatedLeads = new List<Lead>();
    for (Lead record : records) {
      Task task = mapTask.get(record.Id);
      if (task == null) {
        continue;
      }
      if (
        setOfFollowUpForContactAttempted.contains(task.Response_Status__c) &&
        record.Followup_Date__c != null
      ) {
        Date minActivityDate = record.Followup_Date__c.addDays(minDays);
        Date maxExpiryDate = record.Expiry_Date__c.addDays(maxdays);
        record.Expiry_Date__c = minActivityDate > maxExpiryDate
          ? maxExpiryDate
          : minActivityDate;
      } else if (
        setOfFollowUpForAppointment.contains(task.Response_Status__c) &&
        record.Followup_Date__c == null
      ) {
        record.Expiry_Date__c = record.Expiry_Date__c.addDays(minDays);
      } else {
        continue;
      }
      updatedLeads.add(record);
    }
    return updatedLeads;
  }

  /**
   * @description Get Map of Campaign related to Lead
   * @name updateFollowupdate
   * @param records List of lead new records.
   * @param mapCampaigns List of lead new records.
   */
  @testVisible
  private static void updateFollowupdate(
    List<Lead> records,
    Map<Id, CampaignMember> mapCampaigns
  ) {
    Integer followUpExtension = Integer.valueOf(Label.FollowUpDateExtends);
    Integer followUpReduction = Integer.valueOf(
      Label.FollowUpDateLessThanToday
    );
    Date followUpExtensionDate = System.today().addDays(followUpExtension);
    for (Lead record : records) {
      if (!mapCampaigns.containsKey(record.Id)) {
        continue;
      }
      Date campaignEndDate = mapCampaigns.get(record.Id)?.Campaign.Enddate;
      if (record.Followup_Date__c < campaignEndDate) {
        continue;
      }
      if (followUpExtensionDate <= record.Expiry_Date__c) {
        record.Followup_Date__c = record.Expiry_Date__c - followUpExtension;
      } else if (followUpExtensionDate > record.Expiry_Date__c) {
        record.Followup_Date__c = record.Expiry_Date__c - followUpReduction;
      }
    }
  }
  /**
   * @description This method to set the default expiry date of expiry date for AEM Leads
   * @name setExpiryDateforAEM
   * @param records List of Lead records
   */
  public static void setExpiryDateforAEM(List<Lead> records) {
    Map<String, Integer> mapExpiryDays = new Map<String, Integer>{
      'Sat' => 2,
      'Sun' => 1
    };
    Integer expiryDays = Integer.valueOf(Label.DefaultAEMLeadExpiryDate);
    String dayName = DateTimeUtils.getDay(System.today().addDays(expiryDays));
    expiryDays += mapExpiryDays.get(dayName) ?? 0;
    Date expiryDate = System.today().addDays(expiryDays);
    List<Lead> filteredLeads = ListUtil.filter(records)
      .equals(Lead.Lead_Originator__c, LEAD_ORIGINATOR_LENDER_ENGAGE)
      .isNull(Lead.Expiry_Date__c)
      .toList();
    ListUtil.setField(filteredLeads, Lead.Expiry_Date__c, expiryDate);
  }
}
