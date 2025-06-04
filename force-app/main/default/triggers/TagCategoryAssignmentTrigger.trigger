trigger TagCategoryAssignmentTrigger on TagCategoryAssignment(before insert) {
  InteractionTagCategoryAssignmentHandler handler = new InteractionTagCategoryAssignmentHandler();
}
