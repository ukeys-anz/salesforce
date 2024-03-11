/**
 * @author Lance Shi
 * @since  March 2021
 * @description This class is called as a wrapper for all the case queries
 */
public with sharing class CaseQueryHelper {
  private static final String NPP_CASE_QUERY_FILTER_ID_RECORDTYPEID = 'SELECT Id, Status, RecordTypeId FROM Case WHERE Id IN :idList AND RecordTypeId IN :recordTypeList';

  /**
   * @description to get the NPP Cases
   * @param bindVariableMap Map for bind variables in the query
   * @return List<Case> Npp case list
   */
  public static List<Case> getNppCases(Map<String, Object> bindVariableMap) {
    List<Case> caseList = Database.queryWithBinds(
      NPP_CASE_QUERY_FILTER_ID_RECORDTYPEID,
      bindVariableMap,
      AccessLevel.USER_MODE
    );
    return caseList;
  }

  /**
   * @description findChatCaseByCaseId is to query cases based on Id
   * @param caseId the id to be queried
   * @return List<Case> the queried case list
   */
  public List<Case> findChatCaseByCaseId(String caseId) {
    List<Case> cases = [
      SELECT Twilio_Channel_SID__c, Account.OCV_ID__c
      FROM Case
      WHERE Twilio_Channel_SID__c != NULL AND Id = :caseId
    ];
    return cases;
  }
}
