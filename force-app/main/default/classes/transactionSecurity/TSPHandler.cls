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
      when LoginEvent reportLoginEvent {
        return loginEventEvaluation(reportLoginEvent);
      }
      when FileEventStore fileEventStoreBlock {
        eventName = 'Block user for downloading content version records';
        uId = fileEventStoreBlock.UserId;
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

  @testVisible
  /**
   * @description to validate loginEvent Type
   * @param  event `LoginEvent` event developer name
   * @return result `Boolean`
   */
  private static Boolean loginEventEvaluation(LoginEvent event) {
    return (checkBreakGlassUser(event) || checkLoginType(event));
  }

  @testVisible
  /**
   * @description to validate BreakGlassUser Login Event
   * @param  event `LoginEvent` event developer name
   * @return result `Boolean` whether login user is Break Glass User
   */
  private static Boolean checkBreakGlassUser(LoginEvent event) {
    String breakGlassUser = 'anzx.user@anzx.com';

    if (!(event.Username.toLowerCase().contains(breakGlassUser))) {
      return false;
    }
    String breakGlassMessage =
      'Login Event on System User or BreakGlass User (' +
      event.Username +
      ' | Id:' +
      event.UserId +
      ' ) has been detected';

    Logger.error(breakGlassMessage, Logger.Severity.CRITICAL);
    Logger.saveLog(Logger.SaveMethod.QUEUEABLE);
    return true;
  }

  @testVisible
  /**
   * @description to provision LoginType of the Login Event
   * @param  event `LoginEvent` event developer name
   * @return result `Boolean` whether loginType is allowed
   */
  private static Boolean checkLoginType(LoginEvent event) {
    if (isAllowedLoginType(event)) {
      return false;
    }
    String nonSSOMessage =
      'Login Event without using Single-Sign-On has been done by ' +
      event.Username +
      '( Id:' +
      event.UserId +
      ')';
    Logger.info(nonSSOMessage);
    Logger.saveLog(Logger.SaveMethod.QUEUEABLE);
    return true;
  }

  /**
   * @description to validate isAllowedLoginType Type
   * @param  event `LoginEvent` LoginEvent
   * @return result `Boolean` isAllowedLoginType
   */
  private static Boolean isAllowedLoginType(LoginEvent event) {
    Set<String> allowedTypes = new Set<String>{
      'Third Party SSO',
      'Remote Access 2.0'
    };
    return (allowedTypes.contains(event.loginType));
  }
}
