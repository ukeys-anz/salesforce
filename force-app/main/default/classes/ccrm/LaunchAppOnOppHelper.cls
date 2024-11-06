/**
 * @author Ayushi Gupta
 * @since  08/2024
 * @description Helper class for launch application lwc.
 */
public with sharing class LaunchAppOnOppHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description create opp line item wrapper
   * @name createOppLineItemWrapper
   * @param items opp line items
   * @return List<LaunchAppOnOppController.OppLineItemWrapper> wrapper list
   */
  public static List<LaunchAppOnOppController.OppLineItemWrapper> createOppLineItemWrapper(
    List<OpportunityLineItem> items
  ) {
    List<LaunchAppOnOppController.OppLineItemWrapper> itemWrapper = new List<LaunchAppOnOppController.OppLineItemWrapper>();
    for (OpportunityLineItem record : items) {
      LaunchAppOnOppController.OppLineItemWrapper item = new LaunchAppOnOppController.OppLineItemWrapper();
      item.productURL = '/lightning/r/Product2/' + record.Product2Id + '/view';
      item.productName = record.Product2?.Name;
      item.unitPrice = record.UnitPrice;
      item.fundingPurpose = record.Funding_purpose__c;
      item.productId = record.Product2Id;
      itemWrapper.add(item);
    }
    return itemWrapper;
  }

  /**
   * @description create productId  amount map
   * @name createProductAmountMap
   * @param items opp line items
   * @return Map<Id, Decimal> productIdToAmountMap
   */
  public static Map<Id, Decimal> createProductAmountMap(
    List<OpportunityLineItem> items
  ) {
    Map<Id, Decimal> productIdToAmountMap = new Map<Id, Decimal>();
    for (OpportunityLineItem item : items) {
      productIdToAmountMap.put(item.Product2Id, item.UnitPrice);
    }
    return productIdToAmountMap;
  }

  /**
   * @description create application form
   * @name createApplicationForm
   * @param oppId opportunityId
   * @param recordTypeId record type Id
   * @return Id ap form Id
   */
  public static Id createApplicationForm(Id oppId, Id recordTypeId) {
    ApplicationForm appForm = new ApplicationForm(
      OpportunityId = oppId,
      UsageType = 'Other',
      RecordTypeId = recordTypeId
    );

    DML_REPOSITORY.doInsert(new List<ApplicationForm>{ appForm });
    return appForm.Id;
  }

  /**
   * @description create application form products
   * @name createApplicationFormProduct
   * @param appFormId appFormId
   * @param productAmountMap productIdAmountMap
   * @return Id app form product Id
   */
  public static List<Id> createApplicationFormProduct(
    Id appFormId,
    Map<Id, Decimal> productAmountMap
  ) {
    List<Id> appFormProductIds = new List<Id>();
    List<ApplicationFormProduct> appFormProducts = new List<ApplicationFormProduct>();
    for (Id productId : productAmountMap.keySet()) {
      ApplicationFormProduct appFormProduct = new ApplicationFormProduct(
        ApplicationFormId = appFormId,
        ProductId = productId,
        Stage = CCRMConstants.OPP_IDENTIFIED,
        Amount__c = productAmountMap.get(productId)
      );
      appFormProducts.add(appFormProduct);
    }
    List<Database.SaveResult> result = DML_REPOSITORY.doInsert(appFormProducts);
    for (Database.SaveResult sr : result) {
      if (sr.isSuccess()) {
        appFormProductIds.add(sr.getId());
      }
    }
    return appFormProductIds;
  }
}
