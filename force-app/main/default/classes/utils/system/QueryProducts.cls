/**
 * @author Ankita Nair
 * @since September 2024
 * @description Holds cached Product records
 */
public with sharing class QueryProducts {
  @TestVisible
  private static Map<Id, Product2> productsById = new Map<Id, Product2>(
    [
      SELECT
        Id,
        Name,
        IDR_Product_Family__c,
        ANZ_Product_Code__c,
        IDR_Product_Family__r.IDR_ANZ_com_Product_Category__c,
        IDR_Product_Family__r.Name
      FROM Product2
    ]
  );

  public static Map<String, Product2> productsByProductCode = new Map<String, Product2>();
  static {
    for (Product2 product : productsById.values()) {
      productsByProductCode.put(product.ANZ_Product_Code__c, product);
    }
  }

  /**
   * @description Returns Product based on the Product Id.
   * @param productId Id of product
   * @return Product record based on Id.
   */
  public static Product2 getById(Id productId) {
    return productsById.get(productId);
  }
  /**
   * @description Returns Product based on the ANZ_Product_Code__c.
   * @param productCode ANZ_Product_Code__c of product.
   * @return Product on product code
   */
  public static Product2 getByProductCode(String productCode) {
    return productsByProductCode.get(productCode);
  }
}
