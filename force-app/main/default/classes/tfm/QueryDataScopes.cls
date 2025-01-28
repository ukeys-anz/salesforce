/**
 * @author Shivraj Kadam
 * @since Dec 2024
 * @description holds cached TFM Data Scopes metadata records
 */
public with sharing class QueryDataScopes {

  private static Map<String, TFM_Data_Scopes__mdt> dataScopeRecords = new Map<String, TFM_Data_Scopes__mdt>();
  static {
    for (TFM_Data_Scopes__mdt dataScope : [
      SELECT
        ID,
        Scope_ID__c,
        Data_Cluster_Title__c,
        Data_Cluster_Details__c,
        Open_Accounts_Disclaimer__c,
        Closed_Accounts_Disclaimer__c,
        Open_and_Closed_Accounts_Disclaimer__c
      FROM TFM_Data_Scopes__mdt
      WITH SYSTEM_MODE
    ]) {
      dataScopeRecords.put(dataScope.Scope_ID__c, dataScope);
    }
  }

  /**
   * @description Returns a datascope for the scope Id
   * @param scopeId The scope Id.
   * @return The metadata record associated with scope Id
   */
  public static TFM_Data_Scopes__mdt getByScopeId(String scopeId) {
    return dataScopeRecords.get(scopeId);
  }
}