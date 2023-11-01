/**
 * @author Peter Charalambous
 * @since Wed Nov 01 2023
 * @description class for settlement actions
 */
public with sharing class SettlementActions {
  private static final String SETTLEMENTS_QUEUE = 'Settlements_Queue';
  private static final String QUEUE_TYPE = 'Queue';
  private static Group settlementsQueue;

  /**
   * @description get settlements queue
   * @return Group settlements queue
   */
  public static Group getSettlementQueue() {
    if (settlementsQueue != null) {
      return settlementsQueue;
    }

    settlementsQueue = [
      SELECT Id
      FROM Group
      WHERE developername = :SETTLEMENTS_QUEUE AND Type = :QUEUE_TYPE
    ];
    return settlementsQueue;
  }

  /**
   * @description Assign Settlements Queue as owner
   * @param settlementRecords records to assign owner
   */
  public static void assignSettlementQueue(
    List<Settlement__c> settlementRecords
  ) {
    for (Settlement__c settlement : settlementRecords) {
      settlement.OwnerId = getSettlementQueue().Id;
    }
  }
}
