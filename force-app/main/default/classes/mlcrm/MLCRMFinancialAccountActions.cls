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
        if (String.isNotBlank(objFinancialAccount.Product_SubCode__c)) {
          setOfSubProductCode.add(objFinancialAccount.Product_SubCode__c);
        } else if (String.isNotBlank(objFinancialAccount.Product_Type__c)) {
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
        String.isNotBlank(objFinancialAccount.Product_SubCode__c) &&
        mapOfSubCodeToProduct.containsKey(
          objFinancialAccount.Product_SubCode__c
        )
      ) {
        objFinancialAccount.FinServ__ProductName__c = mapOfSubCodeToProduct.get(
            objFinancialAccount.Product_SubCode__c
          )
          .Id;
      } else if (
        String.isNotBlank(objFinancialAccount.Product_Type__c) &&
        mapOfSubCodeToProduct.containsKey(objFinancialAccount.Product_Type__c)
      ) {
        objFinancialAccount.FinServ__ProductName__c = mapOfSubCodeToProduct.get(
            objFinancialAccount.Product_Type__c
          )
          .Id;
      }
    }
  }

  /**
   * @description map Product to Finacial Account for Legacy/Existint Data. It will do value change in Place, update statement is inside batch.
   * @name populateANZProductForLegacyRecords
   * @param records The Financial Account records passed from FinAccountSetProductLookupBatch
   * @param mapOfSubCodeToProduct Map of ProductCode to Product
   * @param ignoreList  map productCode which are not found in existing Product records. ProductCode -> Total Occurance.
   * @return return totalMapped Records.
   */
  public static Integer populateANZProductForLegacyRecords(
    List<FinServ__FinancialAccount__c> records,
    Map<String, Product2> mapOfSubCodeToProduct,
    Map<string, integer> ignoreList
  ) {
    Integer totalRecordsMapped = 0;

    for (FinServ__FinancialAccount__c objFinancialAccount : records) {
      String accountPdtSubCode = objFinancialAccount.Product_SubCode__c;
      String accountPdtType = objFinancialAccount.Product_Type__c;

      // If ProductSubCode is populated in FinAcc
      if (accountPdtSubCode != null) {
        // There exists Product matching with Subcode, map this Product to FinAcc
        if (mapOfSubCodeToProduct.containsKey(accountPdtSubCode)) {
          objFinancialAccount.FinServ__ProductName__c = mapOfSubCodeToProduct.get(
              accountPdtSubCode
            )
            .Id;
          totalRecordsMapped += 1;
        } else {
          // Else: Move this productCode to ignoreList
          if (ignoreList.containsKey(accountPdtSubCode)) {
            ignoreList.put(
              accountPdtSubCode,
              ignoreList.get(accountPdtSubCode) + 1
            );
          } else {
            ignoreList.put(accountPdtSubCode, 1);
          }
        }
      } else if (accountPdtType != null) {
        // If ProductCode is not Populated and ProductType is Populated
        // If Product Exists with Matching ProductType then map FinAcc with this Product
        if (mapOfSubCodeToProduct.containsKey(accountPdtType)) {
          objFinancialAccount.FinServ__ProductName__c = mapOfSubCodeToProduct.get(
              accountPdtType
            )
            .Id;
          totalRecordsMapped += 1;
        } else {
          // Else Move Product Type to ignore list
          if (ignoreList.containsKey(accountPdtType)) {
            ignoreList.put(accountPdtType, ignoreList.get(accountPdtType) + 1);
          } else {
            ignoreList.put(accountPdtType, 1);
          }
        }
      }
    }
    return totalRecordsMapped;
  }
}