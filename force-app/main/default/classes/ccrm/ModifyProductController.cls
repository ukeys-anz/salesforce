/**
 * @author Ayushi Gupta
 * @since  08/2025
 * @description Controller class for modify product lwc.
 */
public with sharing class ModifyProductController {
  private static final ModifyProductRepository PRODUCT_REPOSITORY = (ModifyProductRepository) Lib_InstanceProvider.forType(
    ModifyProductRepository.class
  );
  /**
   * @description get products
   * @name getProducts
   * @param recordId opportunityId
   * @return  List<OpportunityLineItem>
   */
  @AuraEnabled(cacheable=true)
  public static List<OpportunityLineItem> getProducts(String recordId) {
    return PRODUCT_REPOSITORY.getProducts(recordId);
  }
}
