/**
 * @author Ayushi Gupta
 * @since 08/2024
 * @description  CommercialAppFormProductActions is the orchestrator class for commercial app form product Trigger handler.
 */
public with sharing class CommercialAppFormProductActions {
  private static final CommercialAppFormProductActionsRepo AFP_REPOSITORY = (CommercialAppFormProductActionsRepo) Lib_InstanceProvider.forType(
    CommercialAppFormProductActionsRepo.class
  );

  /**
   * @description checkd stage of AFP on insert
   * @name checkStageOnInsert
   * @param records List<ApplicationFormProduct>
   */
  public static void checkStageOnInsert(List<ApplicationFormProduct> records) {
    Set<Id> appFormIds = ListUtil.getIds(
      records,
      ApplicationFormProduct.ApplicationFormId
    );
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = CommercialAppFormProductActionsHelper.getAppFormProductsRelatedToCommercialOpportunity(
      appFormIds,
      records
    );
    //checks for validations on AFP
    CommercialAppFormProductActionsHelper.validateCommercialAppFormProducts(
      appFormProductWrapper,
      true
    );
  }

  /**
   * @description check if stage is skipped
   * @name checkSkipStage
   * @param records List<ApplicationFormProduct>
   * @param oldMap map of old recordsList
   */
  public static void checkSkipStage(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldMap
  ) {
    Set<Id> appFormIds = ListUtil.getIds(
      records,
      ApplicationFormProduct.ApplicationFormId
    );
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = CommercialAppFormProductActionsHelper.getAppFormProductsRelatedToCommercialOpportunity(
      appFormIds,
      records
    );
    CommercialAppFormProductActionsHelper.mandatoryFieldAndSkipStageCheck(
      appFormProductWrapper,
      (Map<Id, ApplicationFormProduct>) oldMap,
      false
    );
  }

  /**
   * @description setFieldOnRelatedOpportunity to set fields of Opportunity
   * @param records List of ApplicationFormProduct
   * @param oldAppFormMap Map of Id and ApplicationFormProduct
   */
  public static void setFieldsOnRelatedOpportunity(
    List<ApplicationFormProduct> records,
    Map<Id, ApplicationFormProduct> oldAppFormMap
  ) {
    Set<Id> validAppFormRecordId = CommercialAppFormProductActionsHelper.fetchvalidRecordId(
      records,
      oldAppFormMap
    );
    List<ApplicationForm> filteredAppForms = AFP_REPOSITORY.getApplicationForms(
      validAppFormRecordId
    );
    List<Opportunity> oppToUpdate = CommercialAppFormProductActionsHelper.setOpportunityCloseDateField(
      filteredAppForms,
      records
    );
    CommercialOpportunityHelper.processUpdate(oppToUpdate);
  }

  /**
   * @description populateCloseDate This is to populate close date on AFP based on OLI
   * @param records applicationFormProduct records list
   */
  public static void populateCloseDate(List<ApplicationFormProduct> records) {
    try {
      Map<String, OpportunityLineItem> oppLineItemsMap = new Map<String, OpportunityLineItem>();
      Set<Id> appFormIds = ListUtil.getIds(
        records,
        ApplicationFormProduct.ApplicationFormId
      );
      CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = CommercialAppFormProductActionsHelper.getAppFormProductsRelatedToCommercialOpportunity(
        appFormIds,
        records
      );
      Set<Id> afpProductIds = ListUtil.getIds(
        appFormProductWrapper.filteredAppFormProducts,
        ApplicationFormProduct.ProductId
      );
      Set<Id> opportunityIdsSet = new Set<Id>(
        appFormProductWrapper.apFormToOppIdMap.values()
      );
      List<OpportunityLineItem> fetchOpportunityLineItems = AFP_REPOSITORY.getOppProductRelatedToAFP(
        afpProductIds,
        opportunityIdsSet
      );
      for (OpportunityLineItem oppLineItem : fetchOpportunityLineItems) {
        oppLineItemsMap.put(
          oppLineItem.OpportunityId + '-' + oppLineItem.Product2Id,
          oppLineItem
        );
      }
      CommercialAppFormProductActionsHelper.populateCloseDateOnAFP(
        appFormProductWrapper,
        oppLineItemsMap
      );
    } catch (Exception e) {
      Logger.error('Error while populating close date on AFP', e).save();
    }
  }
}
