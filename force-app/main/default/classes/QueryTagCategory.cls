/**
 * @author Hrushikesh
 * @since May 2025
 * @description Holds cached TagCategory records
 */
public with sharing class QueryTagCategory {
  @testVisible
  private static Map<Id, TagCategory> tagCategories = new Map<Id, TagCategory>();
  static {
    for (TagCategory tagCategoryRecord : [
      SELECT Id, Name
      FROM TagCategory
      WITH USER_MODE
    ]) {
      tagCategories.put(tagCategoryRecord.Id, tagCategoryRecord);
    }
  }

  /**
   * @description Get TagCategory by id
   * @param recordId id of tag category
   * @return TagCategory
   */
  public static TagCategory getById(Id recordId) {
    return tagCategories.get(recordId);
  }
}
