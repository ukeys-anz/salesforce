/**
 * @author Ayushi Gupta
 * @since  08/2024
 * @description Controller class for launch application lwc.
 */
public with sharing class LaunchAppOnOppController {
  private static final LaunchAppOnOppControllerRepository APP_REPOSITORY = (LaunchAppOnOppControllerRepository) Lib_InstanceProvider.forType(
    LaunchAppOnOppControllerRepository.class
  );
  /**
   * @description get opp line items related to opp
   * @name getOpportunityLineItems
   * @param oppId opportunity Id
   * @return List<OppLineItemWrapper> wrapper list
   */
  @AuraEnabled
  public static List<OppLineItemWrapper> getOpportunityLineItems(Id oppId) {
    try {
      List<OpportunityLineItem> items = APP_REPOSITORY.getOpportunityLineItems(
        oppId
      );
      List<OppLineItemWrapper> itemWrapper = LaunchAppOnOppHelper.createOppLineItemWrapper(
        items
      );
      return itemWrapper;
    } catch (Exception e) {
      Logger.error('Error occured', e).save();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description create app Form and app form product
   * @name createApplication
   * @param oppId opportunity Id
   * @param productIds string of product Ids
   * @param recordTypeId record type Id
   * @return List<Id> app form products Ids set
   */
  @AuraEnabled
  public static List<Id> createApplication(
    Id oppId,
    List<Id> productIds,
    Id recordTypeId
  ) {
    try {
      Id applicationFormId = LaunchAppOnOppHelper.createApplicationForm(
        oppId,
        recordTypeId
      );
      List<Id> appFormProductIds = LaunchAppOnOppHelper.createApplicationFormProduct(
        applicationFormId,
        productIds
      );
      return appFormProductIds;
    } catch (Exception e) {
      Logger.error('Error occured', e).save();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description wrapper class for OppLineItemWrapper
   */
  public class OppLineItemWrapper {
    @AuraEnabled
    public String productId;
    @AuraEnabled
    public String productURL;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public String fundingPurpose;
  }
}
