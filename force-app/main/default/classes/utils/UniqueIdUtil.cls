/**
 * @author Lance Shi
 * @since June 2021
 * @description Get Unique Id for request usages
 * @group Utils
 */
public with sharing class UniqueIdUtil {
  private static String version = '';
  private static String traceId = '';
  private static String parentId = '';
  private static String traceFlag = '';

  /**
   * @description Assign 00 as a hardcoded value, scope to change this in future
   * @return a hex string which suits w3 standard
   */
  public static String getVersion() {
    if (version == '') {
      version = '00';
    }

    return version;
  }
  /**
   * @description Get a unique w3 standard 16 byte hex string
   * @return a hex string which suits w3 standard
   */
  public static String getTraceId() {
    // if session id is null, we are in a session where Request class will fail with internal exception, such as SSO context
    if (traceId == '' && UserInfo.getSessionId() != null) {
      Request reqInfo = Request.getCurrent();
      String currentRequestId = reqInfo.getRequestId();
      if (!String.isBlank(currentRequestId)) {
        traceId = EncodingUtil.convertToHex(
          Crypto.generateDigest('MD5', Blob.valueOf(currentRequestId))
        );
      }
    }

    return traceId;
  }

  /**
   * @description Get a unique w3 standard 8 byte hex string
   * @return a hex string which suits w3 standard
   */
  public static String getParentId() {
    if (parentId == '') {
      String orgId = SFConstants.ORG_ID;
      String composedStr = orgId.subString(3, 5) + orgId.subString(9, 15);
      Blob sampleBlob = Blob.valueOf(composedStr);
      parentId = EncodingUtil.convertToHex(sampleBlob);
    }

    return parentId;
  }

  /**
   * @description Assign 01 as a hardcoded value, scope to change this in future
   * @return a hex string which suits w3 standard
   */
  public static String getTraceFlag() {
    if (traceFlag == '') {
      traceFlag = '01';
    }

    return traceFlag;
  }
}
