/**
 * @author Lance Shi
 * @since Nov 2024
 * @description Holds cached Content Version Record Types.
 */
public with sharing class CFaaSRepository {
  /**
   * @description To query all the Content Versions with uuid
   * @param uid uuid to query content version
  
   * @return List<ContentVersion> list of Content Versions
   */
  public static List<ContentVersion> queryContentVersionWithUid(String uid) {
    if (SObjectType.ContentVersion.isQueryable() == false) {
      return new List<ContentVersion>();
    }
    List<ContentVersion> cvList = [
      SELECT Id, ContentDocumentId, CreatedDate, Document_Flag__c
      FROM ContentVersion
      WHERE UUID__c = :uid AND RecordTypeId = :RTContentVersion.cfaasFile
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    return cvList;
  }

  /**
   * @description To query all the Content Versions with uuid
   * @param cvid content version id to query content version
  
   * @return List<ContentVersion> list of Content Versions
   */
  public static List<ContentVersion> queryContentVersionWithId(String cvid) {
    if (SObjectType.ContentVersion.isQueryable() == false) {
      return new List<ContentVersion>();
    }
    List<ContentVersion> cvList = [
      SELECT ContentDocumentId, CreatedDate, Document_Flag__c
      FROM ContentVersion
      WHERE Id = :cvid
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    return cvList;
  }
}
