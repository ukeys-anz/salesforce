/**
 * @author Nagendra Singh
 * @since  07/2023
 * @description A Picklist Cache builder for object, which returns Record Type Dependent picklist values.
 */
public class PicklistCache implements Cache.CacheBuilder {
  /**
   * @description Methdo to load the data to cache after doing a callout of the data is not found in cache
   * @param keyForCache Unique key for cache against which data is stored.
   * @return `Object` API data would be returned back to the caller class with dependent picklist values.
   */
  public Object doLoad(String keyForCache) {
    Integer indexOfFirstDot = keyForCache.indexOf('.');
    Integer indexOfSecondDot = keyForCache.indexOf('.', indexOfFirstDot + 1);

    String recordTypeId = keyForCache.substring(indexOfSecondDot + 1);

    RecordType recordTypeInfo = [
      SELECT SObjectType
      FROM RecordType
      WHERE Id = :recordTypeId
    ];

    String endpoint =
      'callout:Salesforce_Internal_API/' +
      recordTypeInfo.SobjectType +
      '/picklist-values/' +
      recordTypeId;

    // Create the endpoint dynamically for your org
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('Content-Type', 'application/json');
    HttpCalloutResponse res = calloutService.makeRestCallout(
      endpoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(
      res.body
    );
    System.debug('root -> ' + root);
    if (Test.isRunningTest()) {
      Cache.Org.put(
        'local.Utility.' + keyForCache,
        root.get('picklistFieldValues')
      );
    }
    return (Map<String, Object>) root.get('picklistFieldValues');
  }
}
