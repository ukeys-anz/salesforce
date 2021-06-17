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
    String parentId = UniqueIdUtil.getParentId();
    String traceId = UniqueIdUtil.getTraceId();

    System.assertEquals(16, parentId.length());
    System.assertEquals(32, traceId.length());
  }
}
