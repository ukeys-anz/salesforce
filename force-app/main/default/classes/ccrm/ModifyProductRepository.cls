/**
 * @author Ayushi Gupta
 * @since  08/2025
 * @description Repo class for ModifyProductController
 */
public with sharing class ModifyProductRepository {
  /**
   * @description get products
   * @name getProducts
   * @param oppId opportunityId
   * @return  List<OpportunityLineItem>
   */
  public List<OpportunityLineItem> getProducts(Id oppId) {
    if (oppId == null) {
      return new List<OpportunityLineItem>();
    }
    return [
      SELECT Id, Product2Id, Product2.Name, Opp_Product_name__c
      FROM OpportunityLineItem
      WHERE OpportunityId = :oppId
      WITH USER_MODE
      ORDER BY Product2.Name
    ];
  }
}
