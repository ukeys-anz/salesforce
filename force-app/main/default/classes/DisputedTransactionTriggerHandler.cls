/**
 * @description Handler for Dispute Trigger which extends Lib_TriggerHandler framework.
 * @author Karen Valeriano
 * @since Aug 2025
 */

public with sharing class DisputedTransactionTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public DisputedTransactionTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, return true if .
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Dispute) record).RecordTypeId == RTDispute.disputedTransaction;
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_After_Update started: ' + DateTimeUtils.timeString);
    DisputedTransactionActions.processDisputesForRollup(
      records,
      (Map<Id, Dispute>) oldMap
    );
    Logger.debug('On_After_Update finished: ' + DateTimeUtils.timeString);
    Logger.saveLog();
  }

  /**
   * @description onBeforeDelete to handle before delete trigger actions.
   */
  public override void onBeforeDelete() {
    Logger.debug('On_Before_Delete started: ' + DateTimeUtils.timeString);
    DisputedTransactionActions.processCaseComments((List<Dispute>) records);
    Logger.debug('On_Before_Delete finished: ' + DateTimeUtils.timeString);
    Logger.saveLog();
  }

  /**
   * @description onAfterDelete to handle after delete trigger actions.
   */
  public override void onAfterDelete() {
    Logger.debug('On_After_Delete started: ' + DateTimeUtils.timeString);
    DisputedTransactionActions.calculateDisputeTotalAmounts(
      (List<Dispute>) records
    );
    Logger.debug('On_After_Delete finished: ' + DateTimeUtils.timeString);
    Logger.saveLog();
  }
}
