/**
 * @author Hrushikesh
 * @since April 2025
 * @description holds cached Tag Category Validation metadata records
 */
public with sharing class QueryTagCategoryValidation {
  private static Map<String, List<String>> allowedTagCateegoryByRT = new Map<String, List<String>>();
  static {
    for (
      Interaction_Tag_Category_Validation__mdt record : Interaction_Tag_Category_Validation__mdt.getAll()
        .values()
    ) {
      if (
        allowedTagCateegoryByRT.containsKey(
          record.Interaction_Record_Type__c
        ) == false
      ) {
        allowedTagCateegoryByRT.put(
          record.Interaction_Record_Type__c,
          new List<String>()
        );
      }
      allowedTagCateegoryByRT.get(record.Interaction_Record_Type__c)
        .add(record.Allowed_Tag_Category__c);
    }
  }

  /**
   * @description Returns a List of valid tag categories
   * @param recordTypeDevName record type developer name
   * @return List of valid tag categories
   */
  public static List<String> getByRecordType(String recordTypeDevName) {
    return allowedTagCateegoryByRT.get(recordTypeDevName);
  }
}
