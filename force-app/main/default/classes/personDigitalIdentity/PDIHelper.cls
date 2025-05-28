/**
 * @description Helper class for handling operations related to Person Digital Identity.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
public with sharing class PDIHelper {
  /**
   * @description Retrieves the customer UUID based on the provided filter.
   * @param filter The filter containing the column name and value to identify the customer.
   * @return The customer UUID as a String.
   * @throws IllegalArgumentException if the filter field is invalid.
   */
  public static String getCustomerUuid(DataSource.Filter filter) {
    String filterField = filter.columnName ?? filter.subfilters[0].columnName;
    String filterValue = String.valueOf(
      filter.columnValue ?? filter.subfilters[0].columnValue
    );
    if (filterField == 'PersonId') {
      return filterValue;
    }
    if (filterField == 'ExternalId') {
      return parseResourcePath(filterValue, 'person');
    }
    throw new IllegalArgumentException('Invalid filter field ' + filterField);
  }

  /**
   * @description Parses the resource path to extract the value associated with the specified key.
   * @param path The resource path as a String.
   * @param key The key whose associated value needs to be extracted.
   * @return The value associated with the specified key in the path.
   * @throws IllegalArgumentException if the key is not found or is at the end of the path.
   */
  public static String parseResourcePath(String path, String key) {
    String[] tokens = path.split('/');
    Integer idx = tokens.indexOf(key);
    if (idx == -1) {
      throw new IllegalArgumentException(key + ' not found in ' + path);
    }
    if (++idx == tokens.size()) {
      throw new IllegalArgumentException(key + ' found at end of ' + path);
    }
    return tokens[idx];
  }
}
