/**
 * @author Mildeep Singh
 * @since 01/2026
 * @description This class provide SOQL and DML helper for class related to MLCRMFinancialAccountActions.
 */
public with sharing class FinancialAccountActionsRepository {
  /**
   * @description Returns Products matching OCV_Sub_Product_Key__c and. recordTypeId
   * @param ocvSubProductKey set of Product_type and Product_sub_code from financialAccount
   * @return Product records based on OCV_Sub_Product_Key__c && RecordTypeId
   */
  public List<Product2> getByOcvSubProductKey(Set<String> ocvSubProductKey) {
    if (ocvSubProductKey == null) {
      return new List<Product2>();
    }
    return [
      SELECT Id, OCV_Sub_Product_Key__c, Is_Portfolio__c
      FROM Product2
      WHERE
        RecordTypeId = :MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID
        AND OCV_Sub_Product_Key__c IN :ocvSubProductKey
      WITH USER_MODE
    ];
  }
}
