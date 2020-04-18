/**
 * @description ConcurrentSessionsPolicyCondition is a class to check if the user has concurrent sessions and if yes block the user from logging in as there is an existing session which is logged in as UI
 * @author Pavan Kumar Ananta
 * @since 03/2020
 */
public without sharing class ConcurrentSessionsPolicyCondition implements TxnSecurity.EventCondition {
  // Change the MAX SESSIONS limit values as needed for your org.
  public static final Integer MAX_ADMIN_USER_SESSIONS = 1;
  public static final Integer MAX_USER_SESSIONS = 1;
  public static final String ADMIN_PROFILE_NAME = 'System Administrator';
  public static final String INTEGRATION_PROFILE_NAME = 'Integration User';

  /**
   * @description evaluate method to check if the action needs to be executed. The action here is Block.
   * If the evaluate returns true it blocks the user from logging in.
   * @param event
   * @return `boolean` return true if action needs to be executed.
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public boolean evaluate(SObject event) {
    switch on event {
      when LoginEvent loginEvent {
        return evaluate(loginEvent);
      }
      when null {
        return false;
      }
      when else {
        return false;
      }
    }
  }

  /**
   * @description Evaluate login event based on users and their profile.
   * Control the max sessions of user and admin MAX_ADMIN_USER_SESSIONS and MAX_USER_SESSIONS
   * We want to keep unlimited sessions for Integration user as this is used both by cloud build and mulesoft
   * @param loginEvent
   * @return `boolean` If true block the user from loggin in.
   */
  private boolean evaluate(LoginEvent loginEvent) {
    // The users List only contains the profile ID of the user that created the event.
    List<User> users;
    if (User.sObjectType.getDescribe().isQueryable()) {
      users = [SELECT ProfileId FROM User WHERE Id = :loginEvent.UserId];
    }
    // profileId holds the user's profile ID as a simple, not List, value.
    String profileId = users != null
      ? (String) users.get(0).get('ProfileId')
      : null;
    // The profiles List only contains the name from the user's profile.
    List<Profile> profiles;
    if (Profile.sObjectType.getDescribe().isQueryable()) {
      profiles = profileId != null
        ? [SELECT Name FROM Profile WHERE Id = :profileId]
        : null;
    }
    // profileName holds the user's name as a simple value.
    if (profiles.isEmpty()) {
      return false;
    }
    String profileName = (String) profiles.get(0).get('Name');

    /*
     * Retrieve all the sessions for the user, using the user's ID from the
     * event e. The sessions List stores the session info we get.
     */
    List<AuthSession> sessions;

    if (AuthSession.sObjectType.getDescribe().isQueryable()) {
      sessions = [
        SELECT Id, CreatedDate, LastModifiedDate, NumSecondsValid, SessionType
        FROM AuthSession
        WHERE
          UsersId = :loginEvent.UserId
          AND SessionType = 'UI'
          AND ParentId = null
      ];
    }
    if (sessions.isEmpty()) {
      return false;
    }
    return evaluateSessionBasedOnProfile(profileName, sessions);
  }

  /**
   * @description Since Integration users and platform users have different session limits, check the maximum
   * number of sessions according to user type, and return whether or not
   * they are over the limit.
   * @param profileName
   * @param sessions
   * @return `boolean`
   */
  private boolean evaluateSessionBasedOnProfile(
    String profileName,
    List<AuthSession> sessions
  ) {
    if (profileName.equals(ADMIN_PROFILE_NAME)) {
      return evaluateMaxSession(sessions, MAX_ADMIN_USER_SESSIONS);
    } else if (profileName.equals(INTEGRATION_PROFILE_NAME)) {
      return false;
    } else {
      return evaluateMaxSession(sessions, MAX_USER_SESSIONS);
    }
  }

  /**
   * @description Check if the number of valid sessions in the list of user sessions passed
   * in is more than the number of maximum sessions allowed and if so return true.
   * @param sessions All sessions of the user
   * @param maxSession Max sessions which is configured using MAX_USER_SESSIONS, MAX_ADMIN_USER_SESSIONS
   * @return `boolean` If true block the session.
   */
  @TestVisible
  private boolean evaluateMaxSession(
    List<AuthSession> sessions,
    Integer maxSession
  ) {
    /*
     * Identify all the sessions that don't apply to the session limit and
     * store them in the sessionsToIgnore Map.
     */
    Map<String, String> sessionsToIgnore = (Map<String, String>) Auth.SessionManagement.ignoreForConcurrentSessionLimit(
      sessions
    );

    Integer activeSessions = 0; // No active sessions to start with.
    for (AuthSession s : sessions) {
      // Loop through all the sessions.
      DateTime d = (DateTime) s.get('LastModifiedDate');
      Integer n = (Integer) s.get('NumSecondsValid');
      String sessionId = (String) s.get('Id');

      /*
       * If this session s is not to be ignored, continue checking.
       * Otherwise get the next session.
       */
      if (
        sessionsToIgnore.isEmpty() ||
        sessionsToIgnore.get(sessionId).equals('false')
      ) {
        /*
         * If this session s is not to be ignored, continue checking.
         * Otherwise get the next session.
         */
        if (d.addSeconds(n) >= DateTime.now()) {
          // Otherwise tally one more active session.
          activeSessions = activeSessions + 1;
        }
        /*
         * If we've reached the maximum number of sessions, return true
         * to trigger the action. Since admins and users have different
         * session limits, there are two checks.
         */
        if (activeSessions >= maxSession) {
          return true;
        }
      }
    }

    /*
     * If execution reaches this point, no session limit was reached,
     * so return false to not trigger the policy.
     */
    return false;
  }
}
