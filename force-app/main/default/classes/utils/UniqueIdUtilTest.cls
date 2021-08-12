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
    String parentId = UniqueIdUtil.getParentId();
    String traceId = UniqueIdUtil.getTraceId();
    String traceFlag = UniqueIdUtil.getTraceFlag();

    System.assertEquals(2, version.length());
    System.assertEquals(16, parentId.length());
    System.assertEquals(32, traceId.length());
    System.assertEquals(2, traceFlag.length());
  }
}
