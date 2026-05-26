/**
 * @author Nilesh Kalal
 * @since May 2026
 * @description Repository class for CTI Inbound Interaction queries
 */
public with sharing class CTI_InteractionRepository {
  /**
   * @description Query existing Interaction records by Chat or Call SID
   * @param queryId The contactId or originalContactId from CTI details
   * @return List of Interaction records matching the query ID
   */
  public Interaction queryInteractionBySID(String queryId) {
    return [
      SELECT Id
      FROM Interaction
      WHERE Chat_or_Call_SID_Formula__c = :queryId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }
}
