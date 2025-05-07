/**
 * @author Hrushikesh
 * @since April 2025
 * @description Holds cached Tag Category Assignment
 */
public with sharing class QueryTagCategoryAssignment {
  public static Map<Id, String> tagToTagCategoryMap = new Map<Id, String>();
  static {
    for (TagCategoryAssignment tagCategoryAssign : [
      SELECT Id, TagId, TagCategory.Name
      FROM TagCategoryAssignment
      WITH USER_MODE
    ]) {
      tagToTagCategoryMap.put(
        tagCategoryAssign.TagId,
        tagCategoryAssign.TagCategory.Name
      );
    }
  }

  /**
   * @description returns Tag Category for the Tag Id
   * @param tagId Id of tag
   * @return Associated Tag Category Names
   */
  public static String getByTagId(String tagId) {
    return tagToTagCategoryMap.get(tagId);
  }
}
