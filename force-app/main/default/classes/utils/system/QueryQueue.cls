/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached Queue records
 */
public with sharing class QueryQueue {
  public static final String GROUP_TYPE_QUEUE = 'Queue';

  private static Map<String, Group> queues = new Map<String, Group>();
  static {
    for (Group g : [
      SELECT Id, Name, Type, DeveloperName
      FROM Group
      WHERE Type = :GROUP_TYPE_QUEUE
      WITH USER_MODE
    ]) {
      queues.put(g.DeveloperName, g);
    }
  }

  public static Group pendingKYCQA = get('Pending_KYC_QA');
  public static Group digitalFraudQueue = get('Digital_Fraud_Queue');
  public static Group cobFraudCheckQueue = get('COB_Fraud_Check_Queue');

  /**
   * @description Returns a queue based on the provided name.
   * @param name The name of the queue.
   * @return The Group object associated with the provided name.
   */
  public static Group get(String name) {
    return queues.get(name);
  }

  /**
   * @description Returns a map of queue records based on the provided set of names.
   * @param names A set of names of the queues.
   * @return A map of Group objects associated with the provided names.
   */
  public static Map<String, Group> get(Iterable<String> names) {
    Map<String, Group> mapQueues = new Map<String, Group>();
    for (String name : names) {
      if (queues.containsKey(name)) {
        mapQueues.put(name, queues.get(name));
      }
    }
    return mapQueues;
  }
}
