/**
 * @author       : Advait Yermalkar
 * @since        : 12-01-2025
 * @description  : Repository class for CloneLeadController
 **/
public with sharing class CloneLeadRepository {
  /**
   * @description Executes a dynamic SOQL query built externally
   * @name getLeadRecordByQuery
   * @param queryString - The full dynamic SOQL query
   * @param leadId - The Lead record Id to fetch
   * @return Lead record (or null)
   **/
  public Lead getLeadRecordByQuery(String queryString, String leadId) {
    if (String.isBlank(queryString) || String.isBlank(leadId)) {
      return null;
    }
    String rtId = RTLead.commercialLead;

    try {
      List<Lead> leads = Database.queryWithBinds(
        String.escapeSingleQuotes(queryString),
        new Map<String, Object>{ 'leadId' => leadId, 'rtId' => rtId },
        AccessLevel.SYSTEM_MODE
      );
      return leads.isEmpty() ? null : leads[0];
    } catch (Exception e) {
      Logger.error('Error executing Lead query in CloneLeadRepository', e)
        .save();
      throw e;
    }
  }
}
