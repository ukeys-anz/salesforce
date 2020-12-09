/**
 * @author Pavan Kumar Ananta
 * @since December 2020
 * @description RequestUtils class holds the util functions for all the apex callout requests
 */
public with sharing class RequestUtils {
  private static Request reqInfo;
  /**
   * @description get the unique correlation id for each execution context
   * @return string the unique correlation id
   */
  public static String getRequestId() {
    if (reqInfo == null) {
      reqInfo = Request.getCurrent();
    }
    return reqInfo.getRequestId();
  }
}
