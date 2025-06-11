/**
 * @author Hrushikesh
 * @since 04/2025
 * @description This acts as a tigger handler for Interactions Tag Category Assignment
 */
public with sharing class InteractionTagCategoryAssignmentHandler extends Lib_TriggerHandler {
  private static final Set<String> ALLOWED_TAG_CATEGORIES = new Set<String>{
    'Actual Topic',
    'Reason for visit',
    'Product'
  };
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public InteractionTagCategoryAssignmentHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of topic assignments for Interactions
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    TagCategoryAssignment tagCategoryAssignmentRecord = (TagCategoryAssignment) record;
    String tagCategory = QueryTagCategory.getById(
        tagCategoryAssignmentRecord.TagCategoryId
      )
      .Name;
    return ALLOWED_TAG_CATEGORIES.contains(tagCategory);
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    InteractionTagCategoryAssignmentActions.validatePermissionForInterestTagCreation(
      records
    );
  }
}
