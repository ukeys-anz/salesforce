/**
 * @author Lance Shi
 * @since  March 2021
 * @description This class is to generate fake id for unit test mock data
 */
public with sharing class Lib_FakeIdGenerator {
  private static Map<String, Integer> counts;
  static {
    counts = new Map<String, Integer>();
  }

  /**
   * @description getMockId is generate type salesforce style id for mock sobjects
   * @param type SObject type
   * @return Id the generated id
   */
  public static Id getMockId(SObjectType type) {
    String objectName = String.valueOf(type);
    if (!counts.containsKey(objectName)) {
      counts.put(objectName, 0);
    }
    Integer currentCount = counts.get(objectName);
    counts.put(objectName, ++currentCount);
    String nextIdStub = String.valueOf(currentCount);

    //For use on Generic DAO
    if (type == null) {
      return '111' + fillId(nextIdStub) + nextIdStub;
    }

    return type.getDescribe().getKeyPrefix() + fillId(nextIdStub) + nextIdStub;
  }

  private static String fillId(String currentId) {
    return '0'.repeat(12 - currentId.length());
  }
}
