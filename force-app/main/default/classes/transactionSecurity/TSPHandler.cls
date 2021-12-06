/**
 * @author Farid Masjedi
 * @since Nov 2021
 * @description Transaction security policy to block/notify different events and according different conditions
 * Point: `PMD.ApexCRUDViolation` To get user record regardless of the executing user permissions
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.ApexCRUDViolation')
global with sharing class TSPHandler implements TxnSecurity.EventCondition {
  /**
   * @description Used to check what is the event that has been triggered and
   * according to that, will run the private evaluation method
   * @param event SObject which is the name of the event.
   * @return `Boolean` according to different conditions on different events
   */
  public static boolean evaluate(SObject event) {
    String eventName;
    switch on event {
      when BulkApiResultEventStore bulkApiResultEventStore {
        eventName = 'Bulk API event';
      }
      when ReportEvent reportEvent {
        eventName = 'Exporting report event';
      }
      when ReportAnomalyEventStore reportAnomalyEventStore {
        eventName = 'Report Anomaly event';
      }
      when null {
        return false;
      }
      when else {
        return false;
      }
    }
    return evaluation(event, eventName);
  }
  private static boolean evaluation(SObject event, String eventName) {
    if (Schema.SObjectType.User.fields.Username.isAccessible()) {
      String userId = UserInfo.getUserId();

      User u = [
        SELECT Username, Profile.Name
        FROM User
        WHERE Id = :userId
        LIMIT 1
      ];
      String username = u.Username;
      String profileName = u.Profile.Name;

      Boolean condition = TSPCondition.condition(profileName, event);
      if (condition) {
        lib_systemLog log = new lib_systemLog(TSPHandler.class.getName());
        log.error(
          eventName +
          ' has been done by ' +
          username +
          ' (Id: ' +
          userId +
          ' ) with ' +
          profileName +
          ' profile.'
        );
        log.publishEvent();
        return true;
      }
    }
    return false;
  }
}
