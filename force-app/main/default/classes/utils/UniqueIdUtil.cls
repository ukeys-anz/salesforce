/**
 * @author Lance Shi
 * @since June 2021
 * @description Get Unique Id for request usages
 * @group Utils
 */
public with sharing class UniqueIdUtil {
  private static String version = '';
  private static String traceId = '';
  private static String spanId = '';
  private static String traceFlag = '';

  /**
   * @description Assign 00 as a hardcoded value, scope to change this in future
   * @return a hex string which suits w3 standard
   */
  public static String getVersion() {
    if (String.isBlank(version)) {
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
    if (String.isBlank(traceId) && UserInfo.getSessionId() != null) {
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
  public static String getSpanId() {
    if (String.isBlank(spanId)) {
      return generateSpanId();
    }

    return spanId;
  }

  /**
   * @description Generate a random hex string
   * @return a random lowercase hex string
   */
  public static String generateSpanId() {
    final String chars = '0123456789abcdef';
    String randStr = '';
    while (randStr.length() < 16) {
      Integer idx = Math.mod(
        Math.abs(Crypto.getRandomInteger()),
        chars.length()
      );
      randStr += chars.substring(idx, idx + 1);
    }
    return randStr;
  }

  /**
   * @description Assign 01 as a hardcoded value, scope to change this in future
   * @return a hex string which suits w3 standard
   */
  public static String getTraceFlag() {
    if (String.isBlank(traceFlag)) {
      traceFlag = '01';
    }

    return traceFlag;
  }

  /**
   * @description Captures and stores the TraceId and SpanId from Mulesoft into Object for later use
   * @param request System.RestContext.Request | A System object which is the Request from the API Endpoint
   */
  public static void captureTraceAndSpanIdFromRestRequest(
    System.RestRequest request
  ) {
    //Note: Not a typo - SpanId and TraceId come from Mulesoft Lower Case
    if (request.headers.containsKey('spanid')) {
      spanId = request.headers.get('spanid');
    }

    if (request.headers.containsKey('traceid')) {
      traceId = request.headers.get('traceid');
    }
  }
}
