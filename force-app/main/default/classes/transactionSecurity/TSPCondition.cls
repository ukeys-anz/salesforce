/**
 * @author Farid Masjedi
 * @since Nov 2021
 * @description each event has a condition to check it and according to that it will notify/block an event
 */
public with sharing class TSPCondition {
  private static final TSPRepository TSP_QUERY_REPOSITORY = (TSPRepository) Lib_InstanceProvider.forType(
    TSPRepository.class
  );
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
     List<String> profilesList = new List<String>{
      'ANZ Standard User',
      'Integration User',
      'Minimum Access - External Apps'
    };
    switch on event {
      when BulkApiResultEventStore bulkApiResultEventStore {
        result = !profilesList.contains(profileName);
      }
      when ReportEvent reportEvent {
        List<PermissionSetAssignment> joinLeadPSGAssigned = TSP_QUERY_REPOSITORY.queryPermissionSetAssignment(
          userId,
          'Join_Lead'
        );

        result =
          reportEvent.Operation == 'ReportExported' &&
          (!profileName.contains('ANZ Standard User') ||
          joinLeadPSGAssigned.size() > 0);
      }
      when ReportAnomalyEvent reportAnomalyEvent {
        result = reportAnomalyEvent.Score >= 50;
      }
      when ApiEvent refreshTokenQueriedEvent {
        result =
          refreshTokenQueriedEvent.QueriedEntities.toLowerCase()
            .contains('user') &&
          refreshTokenQueriedEvent.Query.toLowerCase()
            .contains('refresh_token__c');
      }
      when FileEventStore fileEventStore {
        if (fileEventStore.FileAction != 'UI_DOWNLOAD') {
          return false;
        }       
        List <ContentVersion> cvList = TSP_QUERY_REPOSITORY.tspCVList(fileEventStore);
        result = cvList.size() > 0;
      }
      when else {
        return false;
      }
    }
    return result;
  }
}