/**
 *
 * @author Your Name
 * @since 2026
 * @description CCRMAgentFetchMatchingProducts is an invocable Apex class that retrieves
 *              all Products matching a given search key and returns selected
 *              fields in JSON format for use in prompt-based Salesforce Agents.
 */
public with sharing class CCRMAgentFetchMatchingProducts {
  private static final CCRMAgentforceActionRepository AGENT_ACTION_REPOSITORY = (CCRMAgentforceActionRepository) Lib_InstanceProvider.forType(
    CCRMAgentforceActionRepository.class
  );

  /**
   * @description Wrapper class representing the input request containing the search key.
   */
  public class Request {
    @InvocableVariable(required=true)
    public String searchKey;
  }

  /**
   * @description Wrapper class representing the output returned by the invocable method.
   */
  public class Response {
    @InvocableVariable
    public String promptResponse;
  }

  /**
   * @description Fetches products matching the provided search key and returns
   *              selected product details in JSON format for Agent consumption.
   * @param requests List containing the search request with searchKey value.
   * @return List of Response objects containing the JSON formatted product results
   *         or a user-friendly message when no products are found.
   */
  @InvocableMethod(
    label='Agent Action to Fetch Products by Search Key'
    description='Returns matching products (Name, Product Code, Sub Code, Category, Business Area) in JSON format.'
  )
  public static List<Response> getProducts(List<Request> requests) {
    Response output = new Response();

    if (
      requests == null ||
      requests.isEmpty() ||
      String.isBlank(requests[0].searchKey)
    ) {
      output.promptResponse = 'No search key provided.';
      return new List<Response>{ output };
    }

    String searchKey = requests[0].searchKey;

    // Call repository method
    List<Product2> products = AGENT_ACTION_REPOSITORY.searchProducts(searchKey);

    if (products == null || products.isEmpty()) {
      output.promptResponse = 'No products found matching the search key.';
      return new List<Response>{ output };
    }

    List<Map<String, Object>> productList = new List<Map<String, Object>>();

    for (Product2 prod : products) {
      productList.add(
        new Map<String, Object>{
          'productName' => prod.Name,
          'productCode' => prod.ProductCode,
          'subProductCode' => prod.Sub_Product_Code__c,
          'category' => prod.Category__c
        }
      );
    }

    Map<String, Object> responseData = new Map<String, Object>{
      'matchingProducts' => productList
    };

    output.promptResponse = JSON.serializePretty(responseData);

    return new List<Response>{ output };
  }
}
