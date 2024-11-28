/**
 * @author Hrushikesh Pathak
 * @since Oct 2024
 * @description Holds cached AppDefinition records
 */
public with sharing class QueryAppDefinition {
  @TestVisible
  private static Map<Id, AppDefinition> appsByDurableId = new Map<Id, AppDefinition>();
  static {
    for (AppDefinition appDef : [
      SELECT DurableId, Label
      FROM AppDefinition
    ]) {
      appsByDurableId.put(appDef.DurableId, appDef);
    }
  }

  /**
   * @description return AppDefinition by durableId
   * @param durableId durableId of the app
   * @return AppDefinition for the durableId
   */
  public static AppDefinition getByDurableId(Id durableId) {
    return appsByDurableId.get(durableId);
  }
}
