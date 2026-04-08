/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description to handle all ML CRM financial account actions
 */
public class MLCRMFinancialAccountActions {
  public static final String PORTFOLIO_INDICATOR_YES = 'Yes';
  public static final String PORTFOLIO_INDICATOR_NO = 'No';

  private static final FinancialAccountActionsRepository FINACC_ACTIONS_REPOSIITORY = (FinancialAccountActionsRepository) Lib_InstanceProvider.forType(
    FinancialAccountActionsRepository.class
  );
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
    Set<String> setForOcvSubProdKey = new Set<String>();

    List<FinServ__FinancialAccount__c> filteredResults = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(
        new Set<SObjectField>{
          FinServ__FinancialAccount__c.Product_SubCode__c,
          FinServ__FinancialAccount__c.Product_Type__c,
          FinServ__FinancialAccount__c.Portfolio_Indicator__c
        }
      )
      .toList();

    if (filteredResults.isEmpty()) {
      return;
    }

    for (FinServ__FinancialAccount__c eachRecord : filteredResults) {
      String ocvSubProdMatchingValue = getRequiredOcvKeyFromFinAcc(eachRecord);

      if (String.isNotBlank(ocvSubProdMatchingValue)) {
        setForOcvSubProdKey.add(ocvSubProdMatchingValue);
      }
    }

    // Get list of products having the the record type and matching the OCV sub product key
    List<Product2> productMatchingOcvSubProdKey = FINACC_ACTIONS_REPOSIITORY.getByOcvSubProductKey(
      setForOcvSubProdKey
    );

    if (productMatchingOcvSubProdKey.isEmpty()) {
      return;
    }

    // Map OcvSubProductKey, List<Product>
    Map<String, List<Product2>> mapOcvSubProductKeyToProduct = new Map<String, List<Product2>>();
    for (Product2 prod : productMatchingOcvSubProdKey) {
      String key = prod.OCV_Sub_Product_Key__c;

      if (!mapOcvSubProductKeyToProduct.containsKey(key)) {
        mapOcvSubProductKeyToProduct.put(key, new List<Product2>());
      }
      mapOcvSubProductKeyToProduct.get(key).add(prod);
    }

    // Assigning product to fin account
    for (FinServ__FinancialAccount__c fa : filteredResults) {
      // If there is only one record matching OcvSubProductKey then directly assing the product
      String ocvKeyFromFa = getRequiredOcvKeyFromFinAcc(fa);

      List<Product2> matchingProducts = mapOcvSubProductKeyToProduct.get(
        ocvKeyFromFa
      );
      if (matchingProducts == null) {
        continue;
      }

      // Only one match → assign directly
      if (matchingProducts.size() == 1) {
        fa.FinServ__ProductName__c = matchingProducts[0].Id;
        continue;
      }

      // Multiple matches → apply business rule
      for (Product2 p : matchingProducts) {
        if (shouldAssignProduct(fa, p, oldMap)) {
          fa.FinServ__ProductName__c = p.Id;
          break;
        }
      }
    }
  }

  /**
   * @description returns prioritised OcvSubProductKey from fa
   * @name getRequiredOcvKeyFromFinAcc
   * @param fa The Financial Account records
   * @return String prioritised OcvSubProductKey
   */
  private static String getRequiredOcvKeyFromFinAcc(
    FinServ__FinancialAccount__c fa
  ) {
    return String.isNotBlank(fa.Product_SubCode__c)
      ? fa.Product_SubCode__c
      : fa.Product_Type__c;
  }

  /**
   * @description returns boolean value to help assign/skip product to financial account
   * @name shouldAssignProduct
   * @param fa The Financial Account records
   * @param prod List of queried products
   * @param oldMap OldMap from Financial Account trigger
   * @return Boolean to calculdate whether to assign the product to fa
   */
  private static Boolean shouldAssignProduct(
    FinServ__FinancialAccount__c fa,
    Product2 prod,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    // 1. Portfolio-based matching
    if (isPortfolioMatch(fa, prod)) {
      return true;
    }

    // 3. Fallback: non-portfolio products only
    // If current product doesn't match under isPortfolioMatch
    // this will help skip the iteration to assing the product
    if (prod.Is_Portfolio__c != null) {
      return false;
    }

    // 4. Avoid overriding populated product
    return canOverrideProduct(fa, oldMap);
  }

  /**
   * @description method to check if isPortfolio field matches the current product
   * @name isPortfolioMatch
   * @param fa The Financial Account records
   * @param prod List of queried products
   * @return Boolean
   */
  private static Boolean isPortfolioMatch(
    FinServ__FinancialAccount__c fa,
    Product2 prod
  ) {
    return (fa.Portfolio_Indicator__c != null &&
      prod.Is_Portfolio__c == PORTFOLIO_INDICATOR_YES) ||
      (fa.Portfolio_Indicator__c == null &&
      (prod.Is_Portfolio__c == PORTFOLIO_INDICATOR_NO ||
      prod.Is_Portfolio__c == null));
  }

  /**
   * @description method to check if product shall be overridden onto financial account
   * @name canOverrideProduct
   * @param fa The Financial Account records
   * @param oldMap OldMap from Financial Account trigger
   * @return Boolean
   */
  private static Boolean canOverrideProduct(
    FinServ__FinancialAccount__c fa,
    Map<Id, FinServ__FinancialAccount__c> oldMap
  ) {
    if (oldMap == null) {
      return fa.FinServ__ProductName__c == null;
    }

    return oldMap.get(fa.Id).FinServ__ProductName__c ==
      fa.FinServ__ProductName__c;
  }
}
