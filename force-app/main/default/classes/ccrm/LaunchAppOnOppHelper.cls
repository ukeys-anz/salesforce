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
      item.oppLineItemId = record.Id;
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
   * @param oppLineItems oppLineItems
   * @return Id app form product Id
   */
  public static List<Id> createApplicationFormProduct(
    Id appFormId,
    List<OpportunityLineItem> oppLineItems
  ) {
    List<Id> appFormProductIds = new List<Id>();
    List<ApplicationFormProduct> appFormProducts = new List<ApplicationFormProduct>();
    for (OpportunityLineItem item : oppLineItems) {
      ApplicationFormProduct appFormProduct = new ApplicationFormProduct(
        ApplicationFormId = appFormId,
        ProductId = item.Product2Id,
        Stage = CCRMConstants.OPP_IDENTIFIED,
        Amount__c = item.UnitPrice
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
