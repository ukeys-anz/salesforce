/**
 * @author Ashish Kumar
 * @since  05/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMLeadActions is class to handle all the MLCRM (Mobile Lending CRM) Actions
 */
public with sharing class MLCRMLeadActions {
  private static final LeadActionsRepository LA_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );
  private static final TerritoryActionsRepository TA_REPOSITORY = (TerritoryActionsRepository) Lib_InstanceProvider.forType(
    TerritoryActionsRepository.class
  );

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
   * @description This method to set the default value of expiry date for Manually created ML Lead
   * @name setDefaultValue
   * @param records List of Lead records
   * @author Ashish Kumar
   * @US CC-1057
   */
  public static void setDefaultValue(List<Lead> records) {
    Map<String, Integer> mapExpiryDays = new Map<String, Integer> {'Sat' => 2,'Sun' => 1};
    Integer expiryDays = Integer.valueOf(Label.ML_DefaultLeadExpiryDate);
    String dayName = DateTimeUtils.getDay(System.today().addDays(expiryDays));
    expiryDays += mapExpiryDays.get(dayName) ?? 0;
    Date expiryDate = System.today().addDays(expiryDays);

    List<Lead> lstOfMlLeads = getFilteredMLCRMLeads(records);
    for (Lead objLead : lstOfMlLeads) {
      if (
        objLead.Expiry_Date__c != null ||
        objLead.Lead_Originator__c != MLCRMConstants.ORIGINATOR_MLCRM
      ) {
        continue;
      }
      objLead.Expiry_Date__c = expiryDate;
    }
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
    if (oldMap == null || oldMap.isEmpty()) {
      return;
    }
    List<Lead> updatedTerritoryLeadList = getTerritoryUpdatedLeads(
      records,
      oldMap
    );
    Set<Id> idsOfTerritory = getRelatedTerritoryIds(updatedTerritoryLeadList);
    List<Territory__c> lstOfTerritory = TA_REPOSITORY.getTerrritories(
      idsOfTerritory
    );
    setLeadPrimaryFranchiseOwner(updatedTerritoryLeadList, lstOfTerritory);
  }

  /**
   * @description to check if the territory is updated on Leads
   * @name getTerritoryUpdatedLeads
   * @param records The Lead records passed from Trigger.new()
   * * @param oldMap The old Lead Map records passed from Trigger.oldMap()
   * @return List<Lead> updatedTerritoryLeadList
   */
  @testVisible
  private static List<Lead> getTerritoryUpdatedLeads(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> updatedTerritoryLeadList = new List<Lead>();
    for (Lead leadRecord : records) {
      if (
        leadRecord.RecordTypeId == MLCRMConstants.MLCRM_LEAD_RT_ID &&
        leadRecord.Territory__c != null &&
        leadRecord.Territory__c != oldMap.get(leadRecord.Id).Territory__c
      ) {
        updatedTerritoryLeadList.add(leadRecord);
      }
    }
    return updatedTerritoryLeadList;
  }

  /**
   * @description to get the territory ids of the lead which is updated
   * @name getRelatedTerritoryIds
   * @param records The Lead records passed from Trigger.new()
   * @return Set<ID> territoryIdsSet
   */
  @testVisible
  private static Set<ID> getRelatedTerritoryIds(List<Lead> records) {
    Set<ID> territoryIdsSet = new Set<ID>();
    for (Lead leadRecord : records) {
      territoryIdsSet.add(leadRecord.Territory__c);
    }
    return territoryIdsSet;
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
    if (lstOfTerritory.isEmpty()) {
      return;
    }
    Map<Id, Territory__c> mapOfTerritories = new Map<Id, Territory__c>(
      lstOfTerritory
    );
    for (Lead record : records) {
      if (!mapOfTerritories.containsKey(record.Territory__c)) {
        continue;
      }
      record.Primary_Franchise_Owner__c = mapOfTerritories.get(
          record.Territory__c
        )
        .Primary_Franchise_Owner__c;
    }
  }

  /**
   * @description CC-7689 to restrict MLCRM Lead Creation if the user don't have sufficient permission
   * i.e. User who does not have this Custom Permmision should not be able to create Lead
   * @name validateMLCRMLeadCreation
   * @param records The Lead records passed from Trigger.new()
   */
  public static void validateMLCRMLeadCreation(List<Lead> records) {
    // bypassed if current user is Unica/Adobe Integration  or is a system admin or having 'ML_Allow_Lead_Creation' custom permission
    if (LA_REPOSITORY.isCurrentUserAdmin()) {
      return;
    }
    if (LA_REPOSITORY.isAllowLeadCreationCustomPermission()) {
      return;
    }
    List<Lead> filteredMLCRMLeads = getFilteredMLCRMLeads(records);
    raiseLeadError(filteredMLCRMLeads, Label.MLCRM_Record_Creation_Error);
  }

  /**
   * @description CC-7689 to check if the records are MLCRM Leads
   * @name getFilteredMLCRMLeads
   * @param records The Lead records passed from Trigger.new()
   * @return List<Lead> filteredMLCRMLeads
   */
  public static List<Lead> getFilteredMLCRMLeads(List<Lead> records) {
    List<Lead> filteredMLCRMLeads = new List<Lead>();
    for (Lead rec : records) {
      if (rec.RecordTypeId == MLCRMConstants.MLCRM_LEAD_RT_ID) {
        filteredMLCRMLeads.add(rec);
      }
    }
    return filteredMLCRMLeads;
  }

  /**
   * @description CC-7689 to raise error on lead record
   * @name raiseLeadError
   * @param filteredMLCRMLeads The filtered MLCRM Lead records
   * @param errorMessage  Error Message to display to user
   */
  public static void raiseLeadError(
    List<Lead> filteredMLCRMLeads,
    String errorMessage
  ) {
    for (Lead rec : filteredMLCRMLeads) {
      rec.addError(errorMessage);
    }
  }
}
