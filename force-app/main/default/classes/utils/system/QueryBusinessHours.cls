/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached BusinessHours records
 */
public with sharing class QueryBusinessHours {
  private static Map<String, BusinessHours> bHoursMap = (Map<String, BusinessHours>) ListUtil.mapBy(
    [SELECT Id, Name FROM BusinessHours WITH SYSTEM_MODE],
    BusinessHours.Name
  );

  public static BusinessHours anzXBusinessHours = get(
    'ANZx Case Business Hours'
  );

  /**
   * @description Get BusinessHours by BusinessHours Name
   * @param name name of the BusinessHours
   * @return BusinessHours
   */
  public static BusinessHours get(String name) {
    return bHoursMap.get(name);
  }
}
