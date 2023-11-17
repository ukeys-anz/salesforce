/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description to handle all ML CRM financial account actions
 */
public class MLCRMFinancialAccountActions {
  /**
   * @description checks if there is any change in source status field to populate source status display field for the end users
   * @name populateANZProduct
   * @param records The Financial Account records passed from beforeUpdate()
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onBeforeUpdate.
   */
  public static void populateANZProduct(
    List<FinServ__FinancialAccount__c> records,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    Set<String> setOfSubProductCode = new Set<String>();
    Map<String, Product2> mapOfSubCodeToProduct = new Map<String, Product2>();
    Id crmProductId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID;

    for (FinServ__FinancialAccount__c objFinancialAccount : records) {
      if (
        oldMap == null ||
        (oldMap != null &&
        oldMap.get(objFinancialAccount.Id).Product_SubCode__c !=
        objFinancialAccount.Product_SubCode__c)
      ) {
        if(String.isNotBlank(objFinancialAccount.Product_SubCode__c)){
          setOfSubProductCode.add(objFinancialAccount.Product_SubCode__c);
        }
        else if(String.isNotBlank(objFinancialAccount.Product_Type__c) ){
          setOfSubProductCode.add(objFinancialAccount.Product_Type__c);
        }
      }
    }

    if (!setOfSubProductCode.isEmpty()) {
      List<Product2> lstOfProduct2 = [
        SELECT Id, OCV_Sub_Product_Key__c
        FROM Product2
        WHERE
          OCV_Sub_Product_Key__c IN :setOfSubProductCode
          AND recordtypeId = :crmProductId
      ];
      if (!lstOfProduct2.isEmpty()) {
        for (Product2 objProduct : lstOfProduct2) {
          mapOfSubCodeToProduct.put(
            objProduct.OCV_Sub_Product_Key__c,
            objProduct
          );
        }
      }
    }

    for (FinServ__FinancialAccount__c objFinancialAccount : records) {
      if (
        mapOfSubCodeToProduct.containsKey(
          objFinancialAccount.Product_SubCode__c
        )
      ) {
        objFinancialAccount.FinServ__ProductName__c = mapOfSubCodeToProduct.get(
            objFinancialAccount.Product_SubCode__c
          )
          .Id;
      }
    }
  }
}