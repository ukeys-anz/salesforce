/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached Queue records
 */
public with sharing class QueryQueue {
  public static final String GROUP_TYPE_QUEUE = 'Queue';

  private static Map<String, Group> queuesByDeveloperName = new Map<String, Group>();
  private static Map<Id, Group> queuesById = new Map<Id, Group>();
  static {
    for (Group g : [
      SELECT Id, Name, Type, DeveloperName, Email
      FROM Group
      WHERE Type = :GROUP_TYPE_QUEUE
      WITH USER_MODE
    ]) {
      queuesByDeveloperName.put(g.DeveloperName, g);
      queuesById.put(g.Id, g);
    }
  }

  public static Group cardDisputeGeneralQueue = get(
    'Card_Dispute_General_Queue'
  );
  public static Group cobFraudCheckQueue = get('COB_Fraud_Check_Queue');
  public static Group digitalFraudQueue = get('Digital_Fraud_Queue');
  public static Group pendingKYCQA = get('Pending_KYC_QA');
  public static Group accountClosure = get('Account_Closure_Queue');
  public static Group confirmationOfPayee = get('Confirmation_of_Payee_Queue');
  public static Group cqLeads = get('C_Q_Leads');

  /**
   * @description Returns a queue based on the provided name.
   * @param name The name of the queue.
   * @return The Group object associated with the provided name.
   */
  public static Group get(String name) {
    return queuesByDeveloperName.get(name);
  }

  /**
   * @description Returns a map of queue records based on the provided set of names.
   * @param names A set of names of the queues.
   * @return A map of Group objects associated with the provided names.
   */
  public static Map<String, Group> get(Iterable<String> names) {
    Map<String, Group> mapQueues = new Map<String, Group>();
    for (String name : names) {
      if (queuesByDeveloperName.containsKey(name)) {
        mapQueues.put(name, queuesByDeveloperName.get(name));
      }
    }
    return mapQueues;
  }

  /**
   * @description Returns a map of queue records based on the provided set of Ids.
   * @param queueIds A set of OwnerIds of task , case etc
   * @return A map of Group Id and Group details
   */
  public static Map<Id, Group> getByIds(Set<Id> queueIds) {
    Map<Id, Group> mapQueues = new Map<Id, Group>();
    for (String queueId : queueIds) {
      if (queuesById.containsKey(queueId)) {
        mapQueues.put(queueId, queuesById.get(queueId));
      }
    }
    return mapQueues;
  }
}