/**
 * @description CaseCommentsTriggerHandler to prevent case comments to be deleted
 * @author Pavan Kumar Ananta
 * @since 03/2020
 */
public with sharing class CaseCommentsTriggerHandler extends Lib_TriggerHandler {
  private static final String DELETE_ERROR = 'You cannot delete case comments';
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CaseCommentsTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeDelete to prevent case comments to be deleted
   */
  public override void onBeforeDelete() {
    for (CaseComment record : (List<CaseComment>) records) {
      record.addError(DELETE_ERROR);
    }
  }
}
