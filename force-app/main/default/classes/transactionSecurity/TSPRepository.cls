/**
 * @description repository class for Transaction Security Policy {@link NonANZNetworkEventHandler}
 * @runTests NonANZNetworkEventHandlerTest
 * @author @hannah sainumkheaw
 * @since 22/07/2024
 */

public with sharing class TSPRepository {
  /**
   * @description to query eventuser's Profile
   * @param  userId `Id` An userId of the Event User
   * @return User `User` with Profile.Name of the Event User
   */
  public User queryProfilebyEventUserId(Id userId) {
    return [
      SELECT Id, Profile.Name
      FROM User
      WHERE Id = :userId
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description to query Permission Set Assignment by event's user Id and PSG name
   * @param  userId `Id` An userId of the Event User
   * @param  psgName `String` DeveloperName of the PSG
   * @return `List<PermissionSetAssignment>` with PSA of the Event User
   */
  public List<PermissionSetAssignment> queryPermissionSetAssignment(
    Id userId,
    String psgName
  ) {
    return [
      SELECT Id
      FROM PermissionSetAssignment
      WHERE AssigneeId = :userId AND PermissionSetGroup.DeveloperName = :psgName
      WITH USER_MODE
    ];
  }

  /**
   * @description get ContentVersion Record for TSP
   * @param fileEventStore fileEventStore event
   * @return List<ContentVersion>
   **/
  public List<ContentVersion> tspCVList(FileEventStore fileEventStore) {
    return [
      SELECT Id, TagCsv, ContentDocumentId, Description, RecordTypeId
      FROM ContentVersion
      WHERE
        ContentDocumentId = :fileEventStore.DocumentId
        AND RecordTypeId = :TFMConstants.DAON_FILE_RT_ID
      WITH USER_MODE
    ];
  }
}
