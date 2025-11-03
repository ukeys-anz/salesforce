/**
 * @author Hrushikesh
 * @since February 2025
 * @description Abstract class enforcing child classes to implement data retrieval for select records.
 */
public with sharing abstract class SelectRecordsWizard {
  /**
   * @description Method to retrieve records
   * @param params A map of key-value parameters used for data filtering.
   * @return Map<String, Object> A map which can be used to get the data.
   */
  public abstract Map<String, Object> getRecords(Map<String, Object> params);

  /**
   * @description Method to update records
   * @param params A map of key-value parameters used for data.
   */
  public virtual void updateRecords(Map<String, Object> params) {
  }
}
