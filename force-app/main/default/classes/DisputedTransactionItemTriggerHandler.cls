/**
 * @description Handler for Disputed Transactions Trigger which extends Lib_TriggerHandler framework.
 * @author Karen Valeriano
 * @since 08/2025
 */

public with sharing class DisputedTransactionItemTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public DisputedTransactionItemTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, return true if .
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((DisputeItem) record).RecordTypeId ==
      RTDisputeItem.disputedTransaction;
  }

  /**
   * @description onAfterDelete to handle after delete trigger actions.
   */
  public override void onAfterDelete() {
    Logger.debug('On_After_Delete started: ' + DateTimeUtils.timeString);
    DisputedTransactionItemActions.processCaseComments(records);
    DisputedTransactionItemActions.processParentDisputeDeletion(records);
    Logger.debug('On_After_Delete finished: ' + DateTimeUtils.timeString);
    Logger.saveLog();
  }
}
