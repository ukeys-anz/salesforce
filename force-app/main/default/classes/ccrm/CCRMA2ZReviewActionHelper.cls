/**
 * @author       : Advait Yermalkar
 * @since        : 22-05-2024
 * @description  : Helper methords to to work on A_Z_Review__c Automations
 **/
public with sharing class CCRMA2ZReviewActionHelper {
  /**
   * @description updates the ListofA2ZReview
   * @param listOfA2ZReviews ListOfA2Z Reviews to Be Updated
   * @return List<Database.SaveResult>
   **/
  public static List<Database.SaveResult> updateReviews(
    List<A_Z_Review__c> listOfA2ZReviews
  ) {
    if (listOfA2ZReviews == null || listOfA2ZReviews.isEmpty()) {
      return new List<Database.SaveResult>();
    }

    return DMLUtil.updateRecords(
      listOfA2ZReviews,
      DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
  }

  /**
   * @description query list of ccrmA2ZReview flterd by related Lead Id
   * @param setOfLeadIds
   * @return List<A_Z_Review__c>
   **/
  public static List<A_Z_Review__c> fetchReviewsByLead(Set<ID> setOfLeadIds) {
    if (setOfLeadIds == null || setOfLeadIds.isEmpty()) {
      return new List<A_Z_Review__c>();
    }
    return [
      SELECT
        Id,
        Name,
        Customer__c,
        Lead__c,
        Opportunity__c,
        Opportunity__r.AccountId,
        Lead__r.FinServ__RelatedAccount__c
      FROM A_Z_Review__c
      WHERE
        RecordTypeId = :CCRMConstants.AZ_REVIEW_RT_ID
        AND Lead__c IN :setOfLeadIds
    ];
  }

  /**
   * @description query the Opportunity
   * @param listOfA2ZReviews
   * @return Map<Id, Id> returns Map of Opportunity
   **/
  public static Map<Id, Id> fetchOpportunities(
    List<A_Z_Review__c> listOfA2ZReviews
  ) {
    if (listOfA2ZReviews == null || listOfA2ZReviews.isEmpty()) {
      return new Map<Id, Id>();
    }

    Set<Id> setOfOppIds = new Set<Id>();
    for (A_Z_Review__c azRecord : listOfA2ZReviews) {
      if (azRecord.Opportunity__c != null) {
        setOfOppIds.add(azRecord.Opportunity__c);
      }
    }

    Map<Id, Id> mapOfCustomerWithOppID = new Map<Id, Id>();
    if (setOfOppIds.isEmpty()) {
      return mapOfCustomerWithOppID;
    }

    for (Opportunity currOpp : [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE
        AccountId != NULL
        AND Id IN :setOfOppIds
        AND RecordTypeId = :CCRMConstants.CCRM_OPP_RT_ID
    ]) {
      mapOfCustomerWithOppID.put(currOpp.Id, currOpp.AccountId);
    }
    return mapOfCustomerWithOppID;
  }

  /**
   * @description  query the Lead
   * @param listOfA2ZReviews
   * @return Map<Id, Id>  returns Map of Lead
   **/
  public static Map<Id, Id> fetchLeads(List<A_Z_Review__c> listOfA2ZReviews) {
    if (listOfA2ZReviews == null || listOfA2ZReviews.isEmpty()) {
      return new Map<Id, Id>();
    }

    Set<Id> setOfLeadIds = new Set<Id>();
    for (A_Z_Review__c azRecord : listOfA2ZReviews) {
      if (azRecord.Lead__c != null) {
        setOfLeadIds.add(azRecord.Lead__c);
      }
    }

    Map<Id, Id> mapOfCustomerWithLeadID = new Map<Id, Id>();
    if (setOfLeadIds.isEmpty()) {
      return mapOfCustomerWithLeadID;
    }

    for (Lead currLead : [
      SELECT Id, FinServ__RelatedAccount__c
      FROM Lead
      WHERE
        FinServ__RelatedAccount__c != NULL
        AND Id IN :setOfLeadIds
        AND RecordTypeId = :CCRMConstants.CCRM_LEAD_RT_ID
    ]) {
      mapOfCustomerWithLeadID.put(
        currLead.Id,
        currLead.FinServ__RelatedAccount__c
      );
    }
    return mapOfCustomerWithLeadID;
  }

  /**
   * @description Populates opportunity lookup on reviews
   * @param listOfA2ZReviews
   * @param mapOfOppIdWithLeadId
   * @return List<A_Z_Review__c>
   **/
  public static List<A_Z_Review__c> associateReviewsToOpportunity(
    List<A_Z_Review__c> listOfA2ZReviews,
    Map<Id, Id> mapOfOppIdWithLeadId
  ) {
    if (mapOfOppIdWithLeadId == null || mapOfOppIdWithLeadId.isEmpty()) {
      return listOfA2ZReviews;
    }
    for (A_Z_Review__c azRecord : listOfA2ZReviews) {
      if (mapOfOppIdWithLeadId.containsKey(azRecord.Lead__c)) {
        azRecord.Opportunity__c = mapOfOppIdWithLeadId.get(azRecord.Lead__c);
      }
    }
    return listOfA2ZReviews;
  }

  /**
   * @description  Populates customer lookup on reviews
   * @param listOfA2ZReviews
   * @param mapOfCustomerIdWithLeadId
   * @return List<A_Z_Review__c>
   **/
  public static List<A_Z_Review__c> associateReviewsToCustomer(
    List<A_Z_Review__c> listOfA2ZReviews,
    Map<Id, Id> mapOfCustomerIdWithLeadId
  ) {
    if (
      mapOfCustomerIdWithLeadId == null || mapOfCustomerIdWithLeadId.isEmpty()
    ) {
      return listOfA2ZReviews;
    }

    for (A_Z_Review__c azRecord : listOfA2ZReviews) {
      if (mapOfCustomerIdWithLeadId.containsKey(azRecord.Lead__c)) {
        azRecord.Customer__c = mapOfCustomerIdWithLeadId.get(azRecord.Lead__c);
      }
      if (mapOfCustomerIdWithLeadId.containsKey(azRecord.Opportunity__C)) {
        azRecord.Customer__c = mapOfCustomerIdWithLeadId.get(
          azRecord.Opportunity__C
        );
      }
    }
    return listOfA2ZReviews;
  }

  /**
   * @description returns the Map of Customer Id With Lead
   * @param leadMap
   * @param setAccChangedCcrmLeadIds
   * @return Map<Id, Id>
   **/
  public static Map<Id, Id> fetchCustomerMapWithLead(
    Map<Id, Lead> leadMap,
    Set<Id> setAccChangedCcrmLeadIds
  ) {
    if (
      setAccChangedCcrmLeadIds == null || setAccChangedCcrmLeadIds.isEmpty()
    ) {
      return new Map<Id, Id>();
    }

    Map<Id, Id> mapOfCustomerWithLead = new Map<Id, Id>();
    for (Id currleadId : setAccChangedCcrmLeadIds) {
      if (leadMap.containsKey(currleadId)) {
        mapOfCustomerWithLead.put(
          currleadId,
          leadMap.get(currleadId).FinServ__RelatedAccount__c
        );
      }
    }
    return mapOfCustomerWithLead;
  }

  /**
   * @description gets the CCRM Lead Ids where Account is changed
   * @param oldMap
   * @param newMap
   * @return Set<Id>
   **/
  public static Set<Id> getAccountChangedLeadIds(
    Map<Id, Lead> oldMap,
    Map<Id, Lead> newMap
  ) {
    if (
      oldMap == null ||
      oldMap.isEmpty() ||
      newMap == null ||
      newMap.isEmpty()
    ) {
      return new Set<Id>();
    }
    Set<Id> setAccChangedCcrmLeadIds = new Set<Id>();
    for (Lead record : newMap.values()) {
      if (
        CCRMLeadUtil.isCCRMLeadType(record) &&
        CCRMLeadUtil.isLeadExistingAccountChanged(
          record,
          oldMap?.get(record.Id)
        )
      ) {
        setAccChangedCcrmLeadIds.add(record.Id);
      }
    }
    return setAccChangedCcrmLeadIds;
  }
}
