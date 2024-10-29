/**
 * @author Ankita Nair
 * @since September 2024
 * @description Holds cached Product Family records
 */
public with sharing class QueryProductFamily {
  @TestVisible
  private static Map<Id, Product_Family__c> productFamilyById = new Map<Id, Product_Family__c>();
  @TestVisible
  private static Map<String, Product_Family__c> productFamilyByCategory = new Map<String, Product_Family__c>();

  static {
    for (Product_Family__c pf : [
      SELECT Name, IDR_ANZ_com_Product_Category__c, IDR_Workbasket__c
      FROM Product_Family__c
    ]) {
      productFamilyById.put(pf.Id, pf);
      productFamilyByCategory.put(pf.IDR_ANZ_com_Product_Category__c, pf);
    }
  }

  /**
   * @description Returns Product Family based on the Product Family Id.
   * @param productFamilyId  Id of ProductFamily
   * @return Product Family associated with the provided product Family Id.
   */
  public static Product_Family__c getById(Id productFamilyId) {
    return productFamilyById.get(productFamilyId);
  }

  /**
   * @description Returns Product Family based on the product Category .
   * @param productCategory name of Product Category.
   * @return Product Family associated with the provided Product Category name
   */
  public static Product_Family__c getByCategory(String productCategory) {
    return productFamilyByCategory.get(productCategory);
  }
}
