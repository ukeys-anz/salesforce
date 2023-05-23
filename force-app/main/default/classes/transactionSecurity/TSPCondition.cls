/**
 * @author Farid Masjedi
 * @since Nov 2021
 * @description each event has a condition to check it and according to that it will notify/block an event
 */
public with sharing class TSPCondition {
  /**
   * @description to return true/false according to the condition for each event to be triggered
   * @param userId `Id` the user id.
   * @param profileName `String` the user profile name.
   * @param event `SObject` different event that has been triggered
   * @return `Boolean` according to different conditions on different events
   */
  public static Boolean condition(
    Id userId,
    String profileName,
    SObject event
  ) {
    Boolean result;
    switch on event {
      when BulkApiResultEventStore bulkApiResultEventStore {
        result =
          !profileName.contains('ANZ Standard User') &&
          !profileName.contains('Integration User') &&
          !profileName.contains('Minimum Access - External Apps');
      }
      when ReportEvent reportEvent {
        List<PermissionSetAssignment> joinLeadPSGAssigned = [
          SELECT Id
          FROM PermissionSetAssignment
          WHERE
            AssigneeId = :userId
            AND PermissionSetGroup.DeveloperName = 'Join_Lead'
        ];

        result =
          reportEvent.Operation == 'ReportExported' &&
          (!profileName.contains('ANZ Standard User') ||
          joinLeadPSGAssigned.size() > 0);
      }
      when ReportAnomalyEvent reportAnomalyEvent {
        result = reportAnomalyEvent.Score >= 50;
      }
      when else {
        return false;
      }
    }
    return result;
  }
}
