/**
 * @author Amisha Gyan
 * @since February 2026
 * @description Repository class for CCRMAgentforce Agentic Actions:
 */

public with sharing class CCRMAgentforceActionRepository {
  private static final String STANDARD_PRICEBOOK_NAME = 'Standard Price Book';

  /**
   * @description Returns the Standard Pricebook2 Id.
   * @return Id Pricebook2 Id of the Standard Pricebook, or null if inaccessible/not found.
   */
  public Id getStandardPricebookId() {
    PricebookEntry entry = [
      SELECT Pricebook2Id
      FROM PricebookEntry
      WHERE Pricebook2.Name = :STANDARD_PRICEBOOK_NAME
      WITH USER_MODE
      LIMIT 1
    ];
    return entry != null ? entry.Pricebook2Id : null;
  }

  /**
   * @description Fetch Product2 using Product Code and Sub Product Code.
   * @param opportunityId The opportunity Id.
   * @return Returns the Opportunity with its Pricebook2Id for the given Id.
   */
  public Opportunity getOpportunityWithPricebook(Id opportunityId) {
    Opportunity opp = [
      SELECT Id, Pricebook2Id
      FROM Opportunity
      WHERE Id = :opportunityId
      WITH USER_MODE
      LIMIT 1
    ];
    return opp;
  }

  /**
   * @description Fetch Product2 using Product Code and Sub Product Code.
   * @param productName The name of the product.
   * @param productCode The external product code.
   * @param subProductCode The sub-product code.
   * @return Product2 Active Product2 matching the codes.
   * @throws SObjectException when no matching active product is found.
   */
  public Product2 getProductByCodes(
    String productName,
    String productCode,
    String subProductCode
  ) {
    String query = 'SELECT Id, Name FROM Product2 WHERE Name = :productName AND IsActive = true';
    if (String.isNotBlank(productCode) && String.isNotBlank(subProductCode)) {
      query += ' AND ProductCode = :productCode AND Sub_Product_Code__c = :subProductCode';
    }
    query += ' WITH USER_MODE LIMIT 1';
    List<Product2> products = Database.query(query);
    if (products.isEmpty()) {
      throw new SObjectException(
        'No active product found for Product Name ' +
          productName +
          (String.isNotBlank(productCode)
            ? ' Product Code ' + productCode
            : '') +
          (String.isNotBlank(subProductCode)
            ? ' Sub-Product Code ' + subProductCode
            : '')
      );
    }

    return products[0];
  }

  /**
   * @description Fetch active PricebookEntry for given Product and Pricebook.
   * @param productId Product2 Id.
   * @return PricebookEntry Active entry for the Product in the specified Pricebook.
   * @throws SObjectException when product is not available in the Opportunity Pricebook.
   */
  public PricebookEntry getPricebookEntry(Id productId) {
    List<PricebookEntry> entries = [
      SELECT Id, Pricebook2Id, UnitPrice
      FROM PricebookEntry
      WHERE Product2Id = :productId AND IsActive = TRUE
      WITH USER_MODE
      LIMIT 1
    ];

    if (entries.isEmpty()) {
      throw new SObjectException(
        'No active PricebookEntry found for this product.'
      );
    }

    return entries[0];
  }

  /**
   * @description Fetch OpportunityLineItem records by Ids.
   * @param oliIds List of OpportunityLineItem Ids
   * @return List of OpportunityLineItem SObjects
   */
  public List<OpportunityLineItem> getOpportunityLineItemsByIds(
    List<Id> oliIds
  ) {
    return [
      SELECT
        Id,
        Name,
        OpportunityId,
        PricebookEntryId,
        UnitPrice,
        Expected_Settlement_Date__c
      FROM OpportunityLineItem
      WHERE Id IN :oliIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Products records by searchTerm.
   * @param searchKey The search term to filter products.
   * @return List of Product2 SObjects matching the search term.
   */
  public List<Product2> searchProducts(String searchKey) {
    if (String.isBlank(searchKey)) {
      return new List<Product2>();
    }

    String likePattern = '%' + searchKey.trim() + '%';

    return [
      SELECT
        Id,
        Name,
        ProductCode,
        Sub_Product_Code__c,
        Category__c,
        Business_area__c
      FROM Product2
      WHERE Name LIKE :likePattern
      WITH USER_MODE
    ];
  }

  /**
   * @description Query Agent Action History only if the user has read access to the parent record; history is fetched in system mode
   * @param recordId related record Id
   * @return list of Agent_Action_History__c
   */
  public List<Agent_Action_History__c> getAgentActionHistory(Id recordId) {
    if (recordId == null) {
      return new List<Agent_Action_History__c>();
    }

    List<UserRecordAccess> accessList = [
      SELECT RecordId, HasReadAccess
      FROM UserRecordAccess
      WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId
      LIMIT 1
    ];

    if (accessList.isEmpty() || !accessList[0].HasReadAccess) {
      return new List<Agent_Action_History__c>();
    }

    return [
      SELECT
        Id,
        Name,
        Action__c,
        Agent_Name__c,
        Related_Object_Type__c,
        Related_Record_Id__c,
        CreatedDate
      FROM Agent_Action_History__c
      WHERE Related_Record_Id__c = :recordId
      WITH SYSTEM_MODE
      ORDER BY CreatedDate DESC
    ];
  }
}
