/**
 * @author Naman Garg
 * @since 06/2024
 * @description This class provide SOQL and DML helper for class related to CCRMCLogInteractionController.
 */

public with sharing class CCRMLogInteractionRepository {
  /**
   * @description Retrieves CCRM_Log_Interaction_Comment__mdt
   * @return List<CCRM_Log_Interaction_Comment__mdt> List of CCRM_Log_Interaction_Comment__mdt records
   */
  public List<CCRM_Log_Interaction_Comment__mdt> queryCommentType() {
    return CCRM_Log_Interaction_Comment__mdt.getAll().values();
  }

  /**
   * @description Retrieves a list of Financial Account Role records
   * @param recordId The Id of customer
   * @param searchKey search key enter by user
   * @return List<FinServ__FinancialAccountRole__c> List of FinServ__FinancialAccountRole__c records
   */
  public List<FinServ__FinancialAccountRole__c> getFinancialAccountRole(
    String recordId,
    String searchKey
  ) {
    if (String.isBlank(recordId)) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    searchKey = String.isEmpty(searchKey) ? '%' : ('%' + searchKey + '%');
    return [
      SELECT
        Id,
        Name,
        FinServ__FinancialAccount__c,
        FinServ__FinancialAccount__r.Name,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__c = :recordId
        AND FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c LIKE :searchKey
      WITH USER_MODE
      LIMIT 10
    ];
  }
}
