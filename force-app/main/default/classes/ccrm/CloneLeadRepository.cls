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
   * @return Lead record (or null)
   **/
  public Lead getLeadRecordByQuery(String queryString) {
    if (String.isBlank(queryString)) {
      return null;
    }

    try {
      List<Lead> leads = Database.query(queryString);
      return leads.isEmpty() ? null : leads[0];
    } catch (Exception e) {
      Logger.error('Error executing Lead query in CloneLeadRepository', e)
        .save();
      throw e;
    }
  }
}
