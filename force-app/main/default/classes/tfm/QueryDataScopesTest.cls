/**
 * @author Shivraj Kadam
 * @since Dec 2024
 * @description Test class for {@link QueryDataScopes}
 */
@IsTest
public with sharing class QueryDataScopesTest {
  @isTest
  static void testGet() {
    List<TFM_Data_Scopes__mdt> dataScopeList = [
      SELECT
        ID,
        Scope_ID__c,
        Data_Cluster_Title__c,
        Data_Cluster_Details__c,
        Open_Accounts_Disclaimer__c,
        Closed_Accounts_Disclaimer__c,
        Open_and_Closed_Accounts_Disclaimer__c
      FROM TFM_Data_Scopes__mdt
    ];

    TFM_Data_Scopes__mdt dataScopeRecord = QueryDataScopes.getByScopeId(
      dataScopeList[0].Scope_ID__c
    );
    TFM_Data_Scopes__mdt dataScopeRecord1 = QueryDataScopes.getByScopeId(
      dataScopeList[1].Scope_ID__c
    );
    Assert.areEqual(
      dataScopeList[0].Scope_ID__c,
      dataScopeRecord.Scope_ID__c,
      'Metadata Scope_ID__c does not match the Scope ID'
    );
    Assert.areEqual(
      dataScopeList[1].Scope_ID__c,
      dataScopeRecord1.Scope_ID__c,
      'Metadata Scope_ID__c does not match the Scope ID'
    );
  }
}