/**
 * @description Test class for {@link UniqueIdUtil}
 * @author Lance Shi
 * @since June 2021
 * @group Utils
 */
@isTest
public with sharing class UniqueIdUtilTest {
  @isTest
  static void testGenerateIds() {
    String version = UniqueIdUtil.getVersion();
    String spanId = UniqueIdUtil.getSpanId();
    String traceId = UniqueIdUtil.getTraceId();
    String traceFlag = UniqueIdUtil.getTraceFlag();

    System.assertEquals(
      2,
      version.length(),
      'Version length should be as expected.'
    );
    System.assertEquals(
      16,
      spanId.length(),
      'The spanId length should be as expected.'
    );
    System.assertEquals(
      32,
      traceId.length(),
      'The traceId length should be as expected.'
    );
    System.assertEquals(
      2,
      traceFlag.length(),
      'The traceFlag length should be as expected.'
    );
  }
}
