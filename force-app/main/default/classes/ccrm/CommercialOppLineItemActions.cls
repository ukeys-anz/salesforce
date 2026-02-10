/**
 * @author Naman Garg
 * @since  Jun 2025
 * @description This is the action class for CommercialOppLineItemTriggerHandler
 */
public with sharing class CommercialOppLineItemActions {
  private static final CommercialOppLineItemRepository OLI_REPOSITORY = (CommercialOppLineItemRepository) Lib_InstanceProvider.forType(
    CommercialOppLineItemRepository.class
  );

  private static final String OLI_DELETION_ERROR = 'This Opportunity Product is associate with the Application Form Product so you cannot delete it.';

  /**
   * @description This will prevent OLI deletion if there exist an AFP
   * @name preventOLIDeletion
   * @param records List of records
   * @param oldMap Map of old records
   */
  public static void preventOLIDeletion(
    List<OpportunityLineItem> records,
    Map<Id, OpportunityLineItem> oldMap
  ) {
    List<OpportunityLineItem> filteredOliList = OLI_REPOSITORY.getOliRecords(
      oldMap?.keySet()
    );

    Set<Id> oppIdsSet = ListUtil.getIds(
      filteredOliList,
      OpportunityLineItem.OpportunityId
    );

    List<ApplicationFormProduct> afpList = OLI_REPOSITORY.getAppFormProduct(
      oppIdsSet
    );

    Map<Id, Set<Id>> oppIdToAfpProdIdMap = formOppIdToAfpProdIdMap(afpList);

    preventDeletion(oldMap, filteredOliList, oppIdToAfpProdIdMap);
  }

  /**
   * @description This will form a map of Opp Id and Set of AFP Products ids
   * @name formOppIdToAfpProdIdMap
   * @param afpList List of Appplication form product records
   * @return Map<Id, Set<Id>> Opp Id to ADP's Product Id set
   */
  @TestVisible
  private static Map<Id, Set<Id>> formOppIdToAfpProdIdMap(
    List<ApplicationFormProduct> afpList
  ) {
    Map<Id, Set<Id>> oppIdToAfpProdIdMap = new Map<Id, Set<Id>>();
    for (ApplicationFormProduct afpRecord : afpList) {
      if (
        !oppIdToAfpProdIdMap.containsKey(
          afpRecord.ApplicationForm.OpportunityId
        )
      ) {
        oppIdToAfpProdIdMap.put(
          afpRecord.ApplicationForm.OpportunityId,
          new Set<Id>()
        );
      }
      oppIdToAfpProdIdMap.get(afpRecord.ApplicationForm.OpportunityId)
        .add(afpRecord.ProductId);
    }
    return oppIdToAfpProdIdMap;
  }

  /**
   * @description This will prevent OLI deletion if there exist an AFP
   * @name preventDeletion
   * @param oldMap Map of old records
   * @param filteredOliList List of filtered oli records
   * @param oppIdToAfpProdIdMap OppId to ADP's Product Id set
   */
  @TestVisible
  private static void preventDeletion(
    Map<Id, OpportunityLineItem> oldMap,
    List<OpportunityLineItem> filteredOliList,
    Map<Id, Set<Id>> oppIdToAfpProdIdMap
  ) {
    for (OpportunityLineItem oliRec : filteredOliList) {
      Set<Id> afpProductIdsSet = oppIdToAfpProdIdMap.get(oliRec.OpportunityId);
      if (afpProductIdsSet == null) {
        continue;
      }
      if (afpProductIdsSet.contains(oliRec.Product2Id)) {
        oldMap.get(oliRec.Id).addError(OLI_DELETION_ERROR);
      }
    }
  }

  /**
   * @description This is to populate the derived Opp Product Name.
   * @name populateOppProductName
   * @param records List of OpportunityLineItem records from trigger
   */
  public static void populateOppProductName(List<OpportunityLineItem> records) {
    Set<Id> oppIdsSet = ListUtil.getIds(
      records,
      OpportunityLineItem.OpportunityId
    );
    List<Opportunity> oppList = OLI_REPOSITORY.getOpportunityRecords(oppIdsSet);
    Set<Id> oppIdSet = ListUtil.getIds(oppList, Opportunity.Id);
    List<OpportunityLineItem> filteredOliList = ListUtil.filter(records)
      .equals(OpportunityLineItem.OpportunityId, oppIdSet)
      .toList();
    List<OpportunityLineItem> existingOliList = OLI_REPOSITORY.getExistingOLIsList(
      oppIdSet
    );
    Set<Id> productIdsSet = ListUtil.getIds(
      filteredOliList,
      OpportunityLineItem.Product2Id
    );
    Map<Id, Product2> productMap = OLI_REPOSITORY.getProductMap(productIdsSet);
    Map<Id, Integer> oppIdToliCountMap = formOppIdToOliCountMap(
      existingOliList
    );
    updateOppProductName(filteredOliList, oppIdToliCountMap, productMap);
  }

  /**
   * @description Forms a map of OppId to OLI Count Map.
   * @name formOppIdToOliCountMap
   * @param oliList List of OpportunityLineItem
   * @return Map<Id, Integer> Map containing the Opp Id to Oli Count
   */
  @TestVisible
  private static Map<Id, Integer> formOppIdToOliCountMap(
    List<OpportunityLineItem> oliList
  ) {
    Map<Id, Integer> oppIdToliCountMap = new Map<Id, Integer>();
    for (OpportunityLineItem oliRec : oliList) {
      if (oliRec.Opp_Product_name__c == null) {
        continue;
      }
      Integer lastSequenceNumber = oliRec.Opp_Product_name__c.contains('-')
        ? Integer.valueOf(oliRec.Opp_Product_name__c.split('-')[0].trim())
        : 0;
      Integer sequenceNumber = oppIdToliCountMap.get(oliRec.OpportunityId) ?? 0;

      if (sequenceNumber > lastSequenceNumber) {
        continue;
      }
      oppIdToliCountMap.put(oliRec.OpportunityId, lastSequenceNumber);
    }
    return oppIdToliCountMap;
  }

  /**
   * @description To update Opp product name field.
   * @name updateOppProductName
   * @param filteredOliList List of filtered OLI records
   * @param oppIdToliCountMap Map of oppId and count of OLI.
   * @param productMap Map of Id and Product
   */
  @TestVisible
  private static void updateOppProductName(
    List<OpportunityLineItem> filteredOliList,
    Map<Id, Integer> oppIdToliCountMap,
    Map<Id, Product2> productMap
  ) {
    for (OpportunityLineItem oli : filteredOliList) {
      Integer lastSequenceNumber = oppIdToliCountMap.get(oli.OpportunityId) ??
        0;
      Integer nextCount = lastSequenceNumber + 1;
      oppIdToliCountMap.put(oli.OpportunityId, nextCount);
      String productName = productMap.get(oli.Product2Id).Name;
      oli.Opp_Product_name__c = nextCount + ' - ' + productName;
    }
  }
}
