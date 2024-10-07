/**
 * @author       : Hitesh Wasdani
 * @since        : 08-2024
 * @description  : This class containspublic repository for all queries used in ComercialFinancialSummaryController
 **/
public with sharing class FinancialSummaryRepository {
  /**
   * @description retirive accound details by account id
   * @param customerId
   * @return Account
   **/
  public Account getAccountById(String customerId) {
    if (String.isEmpty(customerId)) {
      return new Account();
    }
    return [
      SELECT Id, External_Id__c, RecordType.DeveloperName
      FROM Account
      WHERE Id = :customerId
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description retirve active Clg financial account role records related to account
   * @param customerId
   * @return List<FinServ__AccountAccountRelation__c>
   **/
  public List<FinServ__AccountAccountRelation__c> getActiveClgAccAccRelations(
    String customerId
  ) {
    if (String.isEmpty(customerId)) {
      return new List<FinServ__AccountAccountRelation__c>();
    }
    return [
      SELECT Id, FinServ__RelatedAccount__r.External_Id__c
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__c = :customerId
        AND FinServ__Active__c = TRUE
        AND FinServ__Account__r.RecordType.DeveloperName = 'CLG'
        AND FinServ__RelatedAccount__r.External_Id__c != NULL
      WITH USER_MODE
    ];
  }

  /**
   * @description This method provides List of Financial_Summary_Setting__mdt Metadata Records
   * @return list of Financial_Summary_Setting__mdt records
   */
  public List<Financial_Summary_Setting__mdt> getFinSummaryMetadata() {
    return [
      SELECT Summary_Name__c, User_Profile__c
      FROM Financial_Summary_Setting__mdt
      WHERE Active__c = TRUE
    ];
  }
}
