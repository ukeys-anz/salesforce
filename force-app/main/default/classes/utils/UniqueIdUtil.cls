/**
 * @author Lance Shi
 * @since June 2021
 * @description Get Unique Id for request usages
 * @group Utils
 */
public with sharing class UniqueIdUtil {
  private static String traceId = '';
  private static String parentId = '';

  /**
   * @description Get a unique w3 standard 16 byte hex string
   * @return a hex string which suits w3 standard
   */
  public static String getTraceId() {
    if (traceId == '' && UserInfo.getSessionId() != null) {
      Request reqInfo = Request.getCurrent();
      String currentRequestId = reqInfo.getRequestId();
      traceId = EncodingUtil.convertToHex(
        Crypto.generateDigest('MD5', Blob.valueOf(currentRequestId))
      );
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
}
