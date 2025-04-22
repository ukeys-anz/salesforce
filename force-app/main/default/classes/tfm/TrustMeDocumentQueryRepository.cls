/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 04-15-2025
 **/
public with sharing class TrustMeDocumentQueryRepository {
 
  /**
   * @description fetching evaluation Id
   * @param caseId CaseId
   * @return  String (evaluation Id)
   */
  public Case getCaseRecordById(Id caseId) {
    return [SELECT Id, Evaluation_Id__c,CaseNumber FROM Case WHERE Id = :caseId WITH USER_MODE LIMIT 1] ?? null;
    }

  /**
   * @description fetching contentVersion Records
   * @param fileUUIDs (List of UUID)
   * @return  List<ContentVersion> (List of contentVersion Records)
   */
  public List<ContentVersion> contentVersionsByUUIDs(List<String> fileUUIDs) {
    if (fileUUIDs.isEmpty()) {
      return new List<ContentVersion>();
    }
    return [
      SELECT Id, Document_Flag__c, UUID__c
      FROM ContentVersion
      WHERE
        IsLatest = TRUE
        AND RecordTypeId = :RTContentVersion.daonTrustXFile
        AND UUID__c IN :fileUUIDs
      WITH USER_MODE
    ];
  }
}