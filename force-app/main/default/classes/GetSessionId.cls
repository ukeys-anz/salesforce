/**
 * @author Shivam Swaraj
 * @since  06/2023
 * @description This class helps in fetching the sessionid of the user while making the callout in DependentPicklistController
 */
public class GetSessionId {
  /**
   * @author Shivam Swaraj
   * @since  06/2023
   * @description  This is inner class to send the jsonstring for
   */
  public class SessionId {
    public String sessionId;
  }

  /**
   * @return session id of the user
   * @description get user sessionid from the SessionId VFPage
   */
  public static string getUserSessionId() {
    SessionId sessionJson = new SessionId();
    String sessionIdForUser = Test.isRunningTest()
      ? '{"sessionId":"' + UserInfo.getSessionId() + '"}'
      : Page.SessionId.getContent().toString();
    sessionJson = (SessionId) JSON.deserialize(
      sessionIdForUser,
      SessionId.class
    );
    return sessionJson.sessionId;
  }
}
