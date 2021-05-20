/**
 * @author Lance Shi
 * @since  March 2021
 * @description This class is called as a wrapper for all the case queries
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class CaseQueryHelper {
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
