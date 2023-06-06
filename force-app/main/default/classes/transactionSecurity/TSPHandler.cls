/**
 * @author Farid Masjedi
 * @since Nov 2021
 * @description Transaction security policy to block/notify different events and according different conditions
 */
global with sharing class TSPHandler implements TxnSecurity.EventCondition, TxnSecurity.AsyncCondition {
  /**
   * @description Used to check what is the event that has been triggered and
   * according to that, will run the private evaluation method
   * @param event SObject which is the name of the event.
   * @return `Boolean` according to different conditions on different events
   */
  public static Boolean evaluate(SObject event) {
    String eventName;
    String uId;
    switch on event {
      when BulkApiResultEventStore bulkApiResultEventStore {
        eventName = 'Bulk API event';
        uId = bulkApiResultEventStore.UserId;
      }
      when ReportEvent reportEvent {
        eventName = 'Exporting report event';
        uId = reportEvent.UserId;
      }
      when ReportAnomalyEvent reportAnomalyEventStore {
        eventName = 'Report Anomaly event';
        uId = reportAnomalyEventStore.UserId;
      }
      when ApiEvent refreshTokenQueriedEvent {
        eventName = 'Block RefreshToken Queried APIEvent';
        uId = refreshTokenQueriedEvent.userId;
      }
      when null {
        return false;
      }
      when else {
        return false;
      }
    }
    return evaluation(event, eventName, uId);
  }
  private static Boolean evaluation(
    SObject event,
    String eventName,
    String userIdentity
  ) {
    String userId;
    if (Schema.SObjectType.User.fields.Username.isAccessible()) {
      if (Test.isRunningTest()) {
        userId = UserInfo.getUserId();
      } else {
        userId = userIdentity;
      }

      User u = [
        SELECT Username, Profile.Name
        FROM User
        WHERE Id = :userId
        LIMIT 1
      ];
      String username = u.Username;
      String profileName = u.Profile.Name;
      Boolean condition = TSPCondition.condition(userId, profileName, event);

      if (condition) {
        Logger.error(
          eventName +
          ' has been done by ' +
          username +
          ' (Id: ' +
          userId +
          ' ) with ' +
          profileName +
          ' profile.'
        );
        Logger.saveLog(Logger.SaveMethod.QUEUEABLE);
        return true;
      }
    }
    return false;
  }
}
