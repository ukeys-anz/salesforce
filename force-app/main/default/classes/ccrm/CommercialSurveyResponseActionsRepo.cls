/**
 * @author       : Nabia Nadir
 * @since        : 05-08-2024
 * @description  : This class contains public repository for all queries used in CommercialSurveyResponseActionHelper
 **/
public class CommercialSurveyResponseActionsRepo {
  /**
   * @description filterAccounts data based on customer Number
   * @param custNumbers set of customer numbers
   * @param sourceSystemName source system name
   * @return List<Account> list of account
   **/
  public List<Account> filterAccounts(
    set<String> custNumbers,
    String sourceSystemName
  ) {
    if (!Schema.sObjectType.Account.isQueryable()) {
      return new List<Account>();
    }
    if (custNumbers.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, Source_System_ID__c
      FROM Account
      WHERE
        Source_System_ID__c IN :custNumbers
        AND Source_System_Name__c = :sourceSystemName
    ];
  }
}
