/**
 * @author Hrushikesh
 * @since April 2025
 * @description Holds cached Tag Category Assignment
 */
public with sharing class QueryTagCategoryAssignment {
  public static Map<Id, TagCategoryAssignment> tagToTagCategoryAssignMap = new Map<Id, TagCategoryAssignment>();
  static {
    for (TagCategoryAssignment tagCategoryAssign : [
      SELECT Id, TagId, TagCategoryId
      FROM TagCategoryAssignment
      WITH USER_MODE
    ]) {
      tagToTagCategoryAssignMap.put(tagCategoryAssign.TagId, tagCategoryAssign);
    }
  }

  /**
   * @description returns TagCategoryAssignment for the Tag Id
   * @param tagId Id of tag
   * @return Associated TagCategoryAssignment
   */
  public static TagCategoryAssignment getByTagId(String tagId) {
    return tagToTagCategoryAssignMap.get(tagId);
  }
}
