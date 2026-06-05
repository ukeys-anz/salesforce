/**
 * @author Amisha Gyani
 * @since February, 2026
 * @group CCRMAgent
 * @description CCRMAgentCreateProduct is an invocable Apex class that adds Products
 *              to an existing Opportunity by creating OpportunityLineItem records
 *              and returns their details.
 */
public with sharing class CCRMAgentCreateProduct {
  /**
   * Repository wrapper for DML operations to centralize error handling and user-mode execution.
   */
  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * Repository for all query operations (injectable for tests).
   * Using an interface-driven provider enables dependency injection and unit test isolation.
   */
  private static final CCRMAgentforceActionRepository REPO = (CCRMAgentforceActionRepository) Lib_InstanceProvider.forType(
    CCRMAgentforceActionRepository.class
  );

  /**
   * Repository for Agent Action History.
   */
  private static final AgentActionHistoryController AGENT_ACTION_REPO = (AgentActionHistoryController) Lib_InstanceProvider.forType(
    AgentActionHistoryController.class
  );

  private static final String PRODUCT_NOT_FOUND = 'Product not found for the provided details.';
  private static final String PRICEBOOK_ENTRY_NOT_FOUND = 'Pricebook entry not found for the selected product.';

  /**
   * @description Wrapper class for input details for adding a product to an Opportunity.
   */
  public class ProductInput {
    @InvocableVariable(required=true)
    public Id opportunityId;

    @InvocableVariable(required=true)
    public String productName;

    @InvocableVariable(required=false)
    public String productCode;

    @InvocableVariable(required=false)
    public String subProductCode;

    @InvocableVariable(required=true)
    public Decimal amount;

    @InvocableVariable(required=true)
    public Date settlementDate;
  }

  /**
   * @description Wrapper class for output details of created OpportunityLineItem.
   */
  public class ProductOutput {
    @InvocableVariable
    public Id opportunityLineItemId;

    @InvocableVariable
    public String resultJson;
  }

  /**
   * @description Factory method that constructs an OpportunityLineItem SObject from the provided input.
   * @param input Wrapper containing required fields and reference identifiers
   * @param pbe PricebookEntry to associate with the OpportunityLineItem
   * @param productId Id of the Product to associate with the OpportunityLineItem
   * @return OpportunityLineItem instance ready for insert
   */
  private static OpportunityLineItem buildOpportunityLineItem(
    ProductInput input,
    PricebookEntry pbe,
    Id productId
  ) {
    // Fetch Opportunity (with Pricebook) for pricebook context
    Opportunity opp = REPO.getOpportunityWithPricebook(input.opportunityId);

    // Construct OLI using the passed PricebookEntry
    return new OpportunityLineItem(
      OpportunityId = opp.Id,
      PricebookEntryId = pbe.Id,
      UnitPrice = input.amount,
      Product2Id = productId,
      Expected_Settlement_Date__c = input.settlementDate
    );
  }

  /**
   * @description Invocable entry point that adds Products to an Opportunity by creating
   *              OpportunityLineItem records.
   * @param inputs List of ProductInput records provided by Flow
   * @return List of ProductOutput containing Ids and JSON details of created OLIs
   */
  @InvocableMethod(
    label='Agent Action to Add Product to Opportunity'
    description='Adds a product to an existing opportunity.'
  )
  public static List<ProductOutput> addProduct(List<ProductInput> inputs) {
    Map<String, Object> resultMap = new Map<String, Object>();
    ProductOutput output = new ProductOutput();
    OpportunityLineItem oli;
    try {
      ProductInput input = inputs[0];
      Product2 product = REPO.getProductByCodes(
        input.productName,
        input.productCode,
        input.subProductCode
      );
      if (product == null) {
        throw new AuraHandledException(PRODUCT_NOT_FOUND);
      }
      PricebookEntry pbe = REPO.getPricebookEntry(product.Id);
      if (pbe == null) {
        throw new AuraHandledException(PRICEBOOK_ENTRY_NOT_FOUND);
      }
      oli = buildOpportunityLineItem(input, pbe, product.Id);
      DML_REPO.doInsert(new List<OpportunityLineItem>{ oli });

      oli = REPO.getOpportunityLineItemsByIds(new List<Id>{ oli.Id })[0];
      resultMap.put('opportunityLineItem', oli);
      resultMap.put('opportunityLineItem Name', oli.Name);
      resultMap.put('productName', product.Name);
      resultMap.put('productId', product.Id);

      output.opportunityLineItemId = oli.Id;
      Logger.debug('Successfully created OpportunityLineItem. Id: ' + oli.Id);

      AGENT_ACTION_REPO.createAgentActionHistory(
        'OpportunityLineItem',
        'CRM AI Agent',
        'Created',
        new List<String>{ oli.Id }
      );
    } catch (Exception e) {
      resultMap.put('success', false);
      resultMap.put(
        'errorMessage',
        'Product creation failed: ' + e.getMessage()
      );
      Logger.error('Error creating OpportunityLineItem: ' + e.getMessage());
    }

    output.resultJson = JSON.serializePretty(resultMap);
    if (oli != null) {
      Logger.debug('Successfully created OpportunityLineItem. Id: ' + oli.Id);
    }
    Logger.saveLog();

    return new List<ProductOutput>{ output };
  }
}
