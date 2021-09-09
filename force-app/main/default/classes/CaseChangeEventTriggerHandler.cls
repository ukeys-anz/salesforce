/**
 * @description Handler class for the Case asynchronous trigger
 * @author Olivier Saier
 * @since 06/2021
 */
public with sharing class CaseChangeEventTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CaseChangeEventTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    IDRCaseChangeEventActions.updateCaseRestrictions(
      (CaseChangeEvent[]) records
    );
  }
}
