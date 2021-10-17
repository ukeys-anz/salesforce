/**
 * @description CaseCommentsTriggerHandler to prevent case comments to be deleted
 * @author Pavan Kumar Ananta
 * @since 03/2020
 */
public with sharing class CaseCommentsTriggerHandler extends Lib_TriggerHandler {
  private static final String DELETE_ERROR = 'You cannot delete case comments';
  private static final String EDIT_ERROR = 'You cannot edit case comments';
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

  /**
   * @description  Mask the comments where applicable.
   * This is implemented for project Augur however as this is APRA requirements this will be same for ANZx.
   */
  public override void onApplyDefaults() {
    for (CaseComment record : (List<CaseComment>) records) {
      record.CommentBody = TextUtils.maskData(record.CommentBody);
    }
  }

  /**
   * @description onBeforeUpdate to prevent case comments to be modified
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    for (CaseComment record : (List<CaseComment>) records) {
      record.addError(EDIT_ERROR);
    }
  }

  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    IDRCaseCommentsNotificationManager.manageNotification(
      (List<CaseComment>) records
    );
  }
}
