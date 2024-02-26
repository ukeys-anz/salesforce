/**
 * @author Ashish Kumar
 * @since  05/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMLeadActions is class to handle all the MLCRM (Mobile Lending CRM) Actions
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class MLCRMLeadActions {
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
    for (Lead objLead : records) {
      if (
        CCRMLeadUtil.isMLCRMLeadType(objLead) &&
        objLead.Lead_Originator__c == 'MLCRM'
      ) {
        String dayName = DateTimeUtils.getDay(
          System.today()
            .addDays(Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate))
        );
        switch on dayName {
          when 'Sat' {
            objLead.Expiry_Date__c = System.today()
              .addDays(
                Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate) + 2
              );
          }
          when 'Sun' {
            objLead.Expiry_Date__c = System.today()
              .addDays(
                Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate) + 1
              );
          }
          when else {
            objLead.Expiry_Date__c = System.today()
              .addDays(Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate));
          }
        }
      }
    }
  }

  /**
   * @description This method to set the primary franchise owner on lead
   * @name populatePrimaryFranchise
   * @param lstOfLead List of Lead records
   * @param oldMap old Map of Lead records
   * @author Ashish Kumar
   * @US CC-1550
   */
  public static void populatePrimaryFranchise(
    List<Lead> lstOfLead,
    Map<Id, Lead> oldMap
  ) {
    Set<Id> idsOfTerritory = new Set<Id>();
    for (Lead objLead : lstOfLead) {
      if (
        objLead.RecordTypeId == MLCRMConstants.MLCRM_LEAD_RT_ID &&
        oldMap != null &&
        objLead.Territory__c != null &&
        objLead.Territory__c != oldMap.get(objLead.Id).Territory__c
      ) {
        idsOfTerritory.add(objLead.Territory__c);
      }
    }
    if (!idsOfTerritory.isEmpty()) {
      Map<Id, Territory__c> mapOfUserTerritories;
      //getting list of territory records
      List<Territory__c> lstOfTerritory = [
        SELECT Primary_Franchise_Owner__c
        FROM Territory__c
        WHERE Id IN :idsOfTerritory
      ];
      if (!lstOfTerritory.isEmpty()) {
        mapOfUserTerritories = new Map<Id, Territory__c>();
        for (Territory__c objTerritory : lstOfTerritory) {
          mapOfUserTerritories.put(objTerritory.Id, objTerritory);
        }
      }

      for (Lead objLead : lstOfLead) {
        if (
          objLead.RecordTypeId == MLCRMConstants.MLCRM_LEAD_RT_ID &&
          objLead.Territory__c != null &&
          mapOfUserTerritories.containsKey(objLead.Territory__c)
        ) {
          objLead.Primary_Franchise_Owner__c = mapOfUserTerritories.get(
              objLead.Territory__c
            )
            .Primary_Franchise_Owner__c;
        }
      }
    }
  }
}
