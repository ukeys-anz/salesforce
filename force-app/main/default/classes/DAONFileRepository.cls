/**
 * @author Tan Phan
 * @since 01/2025
 * @description Repository class for DAONFile related operations
 */
public with sharing class DAONFileRepository {
  /**
   * @description Retrieves a list of ContentVersion records by their UUIDs.
   * @param fileUUIDs List of file UUIDs to query.
   * @return List of ContentVersion records.
   */
  public List<ContentVersion> contentVersionsByUUIDs(List<String> fileUUIDs) {
    if (fileUUIDs.isEmpty()) {
      return new List<ContentVersion>();
    }
    return [
      SELECT Document_Flag__c
      FROM ContentVersion
      WHERE
        IsLatest = TRUE
        AND RecordTypeId = :RTContentVersion.daonFile
        AND UUID__c IN :fileUUIDs
      WITH USER_MODE
    ];
  }
}
