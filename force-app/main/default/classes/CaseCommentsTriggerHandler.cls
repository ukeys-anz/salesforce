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
    List<Id> caseIdList = new List<Id>();
    for (CaseComment record : (List<CaseComment>) records) {
      caseIdList.add(record.parentId);
    }
    Map<Id, Case> relatedCaseMap = new Map<Id, Case>(
      [
        SELECT Id, CaseNumber, RecordTypeId, Origin
        FROM Case
        WHERE Id IN :caseIdList
      ]
    );
    for (CaseComment record : (List<CaseComment>) records) {
      Case relatedCase = relatedCaseMap.get(record.parentId);
      if (
        relatedCase != null &&
        (GetHelpCaseActionsHelper.isANZPlusCaseType(relatedCase) ||
        IDRCaseActions.isIDRComplaintType(relatedCase) ||
        relatedCase.RecordTypeId == IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID ||
        relatedCase.RecordTypeId == IDRConstants.SI_RT_ID)
      ) {
        TextUtils.maskAndLog(
          (String) record.get('CommentBody'),
          'CommentBody',
          record
        );
      } else {
        record.CommentBody = TextUtils.maskData(record.CommentBody);
      }
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
