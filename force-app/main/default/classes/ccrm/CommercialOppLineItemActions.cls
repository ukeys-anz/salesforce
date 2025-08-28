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
      oldMap.keySet()
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
}
