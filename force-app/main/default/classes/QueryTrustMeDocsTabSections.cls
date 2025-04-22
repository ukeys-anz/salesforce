/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 04-16-2025
 **/
public with sharing class QueryTrustMeDocsTabSections {
  private static Map<String, List<TrustMe_Docs_Tab_Section_Detail__mdt>> tabSectionDetails = new Map<String, List<TrustMe_Docs_Tab_Section_Detail__mdt>>();
  static {
    for (TrustMe_Docs_Tab_Section_Detail__mdt tabSectionDetail : [
      SELECT
        Id,
        API_Node__c,
        Label,
        Sorting_Order__c,
        TrustMe_Docs_Tab_Section__r.DeveloperName
      FROM TrustMe_Docs_Tab_Section_Detail__mdt
      WITH SYSTEM_MODE
      ORDER BY TrustMe_Docs_Tab_Section__c, Sorting_Order__c
    ]) {
      String key = tabSectionDetail.TrustMe_Docs_Tab_Section__r.DeveloperName;
      if (!tabSectionDetails.containsKey(key)) {
        tabSectionDetails.put(
          key,
          new List<TrustMe_Docs_Tab_Section_Detail__mdt>()
        );
      }
      tabSectionDetails.get(key).add(tabSectionDetail);
    }
  }

  /**
   * @description Returns a list of section detail record
   * @param sectionName parent record name
   * @return Returns a section detail record
   */
  public static List<TrustMe_Docs_Tab_Section_Detail__mdt> getByDocTabSectionDeveloperName(
    String sectionName
  ) {
    return tabSectionDetails.get(sectionName);
  }

  /**
   * @description Returns sectionNames
   * @return Returns sectionNames
   */
  public static Set<String> getDocTabSectionDeveloperNames() {
    return tabSectionDetails.keySet();
  }
}
