/**
 * @author Ayushi Gupta
 * @since June 2025
 * @description Holds cached A2Z Record Types.
 */
public class RTA2ZReview {
  static QueryRT base = QueryRT.of(A_Z_Review__c.SObjectType);

  public static Id commercialA2ZReview = base.getId('Commercial_A_Z_Review');

  /**
   * @description Get the record type info for a given record type id
   * @param recordTypeId The record type id
   * @return The record type info
   */
  public static RecordTypeInfo get(Id recordTypeId) {
    return base.get(recordTypeId);
  }
}
