/**
 * @author Ankita Nair
 * @since September 2024
 * @description Holds cached Product records
 */
public with sharing class QueryProducts {
  @TestVisible
  private static Map<Id, Product2> productsById = new Map<Id, Product2>();

  static {
    for (Product2 p : [
      SELECT
        Name,
        IDR_Product_Family__c,
        ANZ_Product_Code__c,
        IDR_Product_Family__r.IDR_ANZ_com_Product_Category__c
      FROM Product2
    ]) {
      productsById.put(p.Id, p);
    }
  }

  /**
   * @description Returns Product based on the Product Id.
   * @param productId Id of ProductFamily
   * @return Product Family associated with the provided product Family Id.
   */
  public static Product2 getById(Id productId) {
    return productsById.get(productId);
  }
}
