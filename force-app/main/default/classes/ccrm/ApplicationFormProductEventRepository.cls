/**
 * @description Repository class responsible for retrieving related data
 *              used by ApplicationFormProduct event processing. This includes
 *              fetching qualifying ApplicationForm
 *              records related to given ApplicationFomProduct IDs.
 *
 * @author      Akanksha Kulkarni
 * @date        2025-11-18
 */
public class ApplicationFormProductEventRepository {
  /**
   * @description Fetches qualifying ApplicationForms related to given ApplicationFormProducts.
   *              Qualifying forms must have RecordType = 'AMBIT' and Sync_Status__c = 'Broker Org'.
   * @param products The list of ApplicationFormProduct records containing ApplicationFormId references.
   * @return A list of ApplicationForm records meeting qualification criteria.
   */
  @TestVisible
  public List<ApplicationForm> getQualifiedApplicationForms(
    List<ApplicationFormProduct> products
  ) {
    Set<Id> appFormIds = new Set<Id>();
    for (ApplicationFormProduct prod : products) {
      if (prod.ApplicationFormId != null) {
        appFormIds.add(prod.ApplicationFormId);
      }
    }

    if (appFormIds.isEmpty()) {
      return new List<ApplicationForm>();
    }

    return [
      SELECT
        Id,
        Reference_Number__c,
        AccountId,
        RecordType.DeveloperName,
        Sync_Status__c,
        Opportunity.Broker_Name__c,
        Opportunity.Broker_Name__r.AssetFinanceTPMISAO__c,
        Opportunity.AccountId,
        Source_System_Id__c,
        OpportunityId,
        Assisted_Broker__c,
        Assisted_Broker_TPMI_SAO__c
      FROM ApplicationForm
      WHERE Id IN :appFormIds AND RecordType.DeveloperName = 'AMBIT'
      WITH USER_MODE
    ];
  }
}
